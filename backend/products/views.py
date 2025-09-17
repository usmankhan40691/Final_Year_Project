from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db import transaction
from decimal import Decimal
import stripe
from django.conf import settings

from .models import (
    Category, Product, ProductVariant, CartItem, Order, OrderItem, 
    Payment, Wishlist, Coupon, CouponUsage
)
from .serializers import (
    CategorySerializer, ProductSerializer, ProductVariantSerializer, CartItemSerializer,
    OrderSerializer, CheckoutSerializer, PaymentSerializer, WishlistSerializer,
    CouponSerializer, CouponValidationSerializer
)

# Configure Stripe
stripe.api_key = getattr(settings, 'STRIPE_SECRET_KEY', '')

class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.filter(is_active=True)
    serializer_class = CategorySerializer
    permission_classes = [AllowAny]

class ProductViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Product.objects.filter(is_active=True)
    serializer_class = ProductSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        queryset = super().get_queryset()
        category = self.request.query_params.get('category', None)
        featured = self.request.query_params.get('featured', None)
        search = self.request.query_params.get('search', None)

        if category:
            queryset = queryset.filter(category__id=category)
        if featured:
            queryset = queryset.filter(is_featured=True)
        if search:
            queryset = queryset.filter(name__icontains=search)

        return queryset

# Cart Management Views
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def cart_list(request):
    """Get user's cart items"""
    cart_items = CartItem.objects.filter(user=request.user).select_related('product', 'variant')
    serializer = CartItemSerializer(cart_items, many=True)
    
    # Calculate cart totals
    subtotal = sum(item.total_price for item in cart_items)
    tax_rate = Decimal('0.18')  # 18% GST
    tax_amount = subtotal * tax_rate
    shipping_cost = Decimal('50.00') if subtotal < 500 else Decimal('0.00')  # Free shipping above ₹500
    total = subtotal + tax_amount + shipping_cost
    
    return Response({
        'success': True,
        'cart_items': serializer.data,
        'summary': {
            'items_count': cart_items.count(),
            'subtotal': str(subtotal),
            'tax_amount': str(tax_amount),
            'shipping_cost': str(shipping_cost),
            'total': str(total)
        }
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_to_cart(request):
    """Add item to cart or update quantity if exists"""
    serializer = CartItemSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        cart_item = serializer.save()
        return Response({
            'success': True,
            'message': 'Item added to cart successfully',
            'cart_item': CartItemSerializer(cart_item).data
        }, status=status.HTTP_201_CREATED)
    
    return Response({
        'success': False,
        'message': 'Failed to add item to cart',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_cart_item(request, item_id):
    """Update cart item quantity"""
    try:
        cart_item = CartItem.objects.get(id=item_id, user=request.user)
    except CartItem.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Cart item not found'
        }, status=status.HTTP_404_NOT_FOUND)
    
    serializer = CartItemSerializer(cart_item, data=request.data, partial=True)
    
    if serializer.is_valid():
        updated_item = serializer.save()
        return Response({
            'success': True,
            'message': 'Cart item updated successfully',
            'cart_item': CartItemSerializer(updated_item).data
        })
    
    return Response({
        'success': False,
        'message': 'Failed to update cart item',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_from_cart(request, item_id):
    """Remove item from cart"""
    try:
        cart_item = CartItem.objects.get(id=item_id, user=request.user)
        cart_item.delete()
        return Response({
            'success': True,
            'message': 'Item removed from cart successfully'
        })
    except CartItem.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Cart item not found'
        }, status=status.HTTP_404_NOT_FOUND)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def clear_cart(request):
    """Clear all items from cart"""
    deleted_count = CartItem.objects.filter(user=request.user).delete()[0]
    return Response({
        'success': True,
        'message': f'Cart cleared successfully. {deleted_count} items removed.'
    })

# Coupon Management
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def validate_coupon(request):
    """Validate coupon code and return discount information"""
    serializer = CouponValidationSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        coupon = serializer.validated_data['coupon']
        order_amount = serializer.validated_data['order_amount']
        discount_amount = coupon.calculate_discount(order_amount)
        
        return Response({
            'success': True,
            'coupon': {
                'id': coupon.id,
                'code': coupon.code,
                'description': coupon.description,
                'discount_type': coupon.discount_type,
                'discount_value': coupon.discount_value,
                'discount_amount': discount_amount,
                'minimum_order_amount': coupon.minimum_order_amount
            }
        })
    
    return Response({
        'success': False,
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

# Checkout and Order Management
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def checkout(request):
    """Create order from cart items"""
    serializer = CheckoutSerializer(data=request.data, context={'request': request})
    
    if not serializer.is_valid():
        return Response({
            'success': False,
            'message': 'Invalid checkout data',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        with transaction.atomic():
            # Get cart items
            cart_items = CartItem.objects.filter(user=request.user).select_related('product', 'variant')
            
            if not cart_items.exists():
                return Response({
                    'success': False,
                    'message': 'Cart is empty'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Validate stock one more time for each item
            for cart_item in cart_items:
                if cart_item.is_out_of_stock:
                    return Response({
                        'success': False,
                        'message': f'{cart_item.product.name} is out of stock'
                    }, status=status.HTTP_400_BAD_REQUEST)
                
                if cart_item.quantity > cart_item.available_stock:
                    return Response({
                        'success': False,
                        'message': f'Insufficient stock for {cart_item.product.name}. Available: {cart_item.available_stock}'
                    }, status=status.HTTP_400_BAD_REQUEST)
            
            # Calculate totals
            subtotal = sum(item.total_price for item in cart_items)
            
            # Apply coupon discount if provided
            coupon = serializer.validated_data.get('coupon')
            discount_amount = Decimal('0.00')
            if coupon:
                discount_amount = coupon.calculate_discount(subtotal)
            
            # Calculate tax and shipping
            tax_rate = Decimal('0.18')  # 18% GST
            discounted_subtotal = subtotal - discount_amount
            tax_amount = discounted_subtotal * tax_rate
            shipping_cost = Decimal('50.00') if discounted_subtotal < 500 else Decimal('0.00')  # Free shipping above ₹500
            total_amount = discounted_subtotal + tax_amount + shipping_cost
            
            # Create order
            order_data = serializer.validated_data
            order = Order.objects.create(
                user=request.user,
                shipping_name=order_data['shipping_name'],
                shipping_email=order_data['shipping_email'],
                shipping_phone=order_data['shipping_phone'],
                shipping_address_line1=order_data['shipping_address_line1'],
                shipping_address_line2=order_data.get('shipping_address_line2', ''),
                shipping_city=order_data['shipping_city'],
                shipping_state=order_data['shipping_state'],
                shipping_postal_code=order_data['shipping_postal_code'],
                shipping_country=order_data.get('shipping_country', 'India'),
                subtotal=subtotal,
                discount_amount=discount_amount,
                coupon=coupon,
                tax_amount=tax_amount,
                shipping_cost=shipping_cost,
                total_amount=total_amount,
            )
            
            # Create order items and update stock
            for cart_item in cart_items:
                # Create order item
                OrderItem.objects.create(
                    order=order,
                    product=cart_item.product,
                    quantity=cart_item.quantity,
                    price=cart_item.unit_price,
                    total=cart_item.total_price
                )
                
                # Update stock (product or variant)
                if cart_item.variant:
                    cart_item.variant.stock_quantity -= cart_item.quantity
                    cart_item.variant.save()
                else:
                    cart_item.product.stock_quantity -= cart_item.quantity
                    cart_item.product.save()
            
            # Record coupon usage if applicable
            if coupon:
                CouponUsage.objects.create(
                    user=request.user,
                    coupon=coupon,
                    order=order,
                    discount_amount=discount_amount
                )
                # Update coupon usage count
                coupon.used_count += 1
                coupon.save()
            
            # Create payment record
            payment = Payment.objects.create(
                order=order,
                payment_method=order_data['payment_method'],
                amount=total_amount,
                currency='INR'
            )
            
            # Clear cart
            cart_items.delete()
            
            return Response({
                'success': True,
                'message': 'Order created successfully',
                'order': OrderSerializer(order).data,
                'payment': PaymentSerializer(payment).data
            }, status=status.HTTP_201_CREATED)
            
    except Exception as e:
        return Response({
            'success': False,
            'message': f'Checkout failed: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_list(request):
    """Get user's orders"""
    orders = Order.objects.filter(user=request.user).prefetch_related('items__product')
    serializer = OrderSerializer(orders, many=True)
    return Response({
        'success': True,
        'orders': serializer.data
    })

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def order_detail(request, order_id):
    """Get order details"""
    try:
        order = Order.objects.get(id=order_id, user=request.user)
        serializer = OrderSerializer(order)
        return Response({
            'success': True,
            'order': serializer.data
        })
    except Order.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Order not found'
        }, status=status.HTTP_404_NOT_FOUND)

# Payment Processing
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def process_payment(request):
    """Process payment using Stripe"""
    payment_id = request.data.get('payment_id')
    payment_method_id = request.data.get('payment_method_id')
    
    if not payment_id:
        return Response({
            'success': False,
            'message': 'Payment ID required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        payment = Payment.objects.get(id=payment_id, order__user=request.user)
        
        if payment.status == 'completed':
            return Response({
                'success': False,
                'message': 'Payment already completed'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Create Stripe payment intent
        intent = stripe.PaymentIntent.create(
            amount=int(payment.amount * 100),  # Convert to paise
            currency=payment.currency.lower(),
            payment_method=payment_method_id,
            confirmation_method='manual',
            confirm=True,
            return_url='https://your-app.com/return'
        )
        
        # Update payment record
        payment.payment_intent_id = intent.id
        payment.transaction_id = intent.id
        
        if intent.status == 'succeeded':
            payment.status = 'completed'
            payment.order.payment_status = 'paid'
            payment.order.order_status = 'processing'
            payment.order.save()
            
            return Response({
                'success': True,
                'message': 'Payment successful',
                'payment': PaymentSerializer(payment).data
            })
        else:
            payment.status = 'failed'
            payment.failure_reason = f'Stripe status: {intent.status}'
            
        payment.save()
        
        return Response({
            'success': False,
            'message': 'Payment failed',
            'requires_action': intent.status == 'requires_action',
            'client_secret': intent.client_secret if intent.status == 'requires_action' else None
        })
        
    except Payment.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Payment not found'
        }, status=status.HTTP_404_NOT_FOUND)
    except stripe.error.StripeError as e:
        return Response({
            'success': False,
            'message': f'Payment error: {str(e)}'
        }, status=status.HTTP_400_BAD_REQUEST)

# Wishlist Management
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def wishlist_list(request):
    """Get user's wishlist"""
    wishlist_items = Wishlist.objects.filter(user=request.user).select_related('product')
    serializer = WishlistSerializer(wishlist_items, many=True)
    return Response({
        'success': True,
        'wishlist_items': serializer.data
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_to_wishlist(request):
    """Add item to wishlist"""
    serializer = WishlistSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        wishlist_item = serializer.save()
        return Response({
            'success': True,
            'message': 'Item added to wishlist successfully',
            'wishlist_item': WishlistSerializer(wishlist_item).data
        }, status=status.HTTP_201_CREATED)
    
    return Response({
        'success': False,
        'message': 'Failed to add item to wishlist',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def remove_from_wishlist(request, item_id):
    """Remove item from wishlist"""
    try:
        wishlist_item = Wishlist.objects.get(id=item_id, user=request.user)
        wishlist_item.delete()
        return Response({
            'success': True,
            'message': 'Item removed from wishlist successfully'
        })
    except Wishlist.DoesNotExist:
        return Response({
            'success': False,
            'message': 'Wishlist item not found'
        }, status=status.HTTP_404_NOT_FOUND)
