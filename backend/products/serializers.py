from rest_framework import serializers
from django.contrib.auth.models import User
from django.utils import timezone
from .models import (
    Category, Product, ProductVariant, CartItem, Order, OrderItem, 
    Payment, Wishlist, Coupon, CouponUsage
)

class CategorySerializer(serializers.ModelSerializer):
    products_count = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ['id', 'name', 'description', 'image', 'is_active', 'products_count']

    def get_products_count(self, obj):
        return obj.products.filter(is_active=True).count()

class ProductVariantSerializer(serializers.ModelSerializer):
    final_price = serializers.ReadOnlyField()
    is_in_stock = serializers.ReadOnlyField()

    class Meta:
        model = ProductVariant
        fields = [
            'id', 'sku', 'size', 'color', 'material',
            'price_adjustment', 'final_price', 'stock_quantity',
            'image', 'is_active', 'is_in_stock'
        ]

class ProductSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    is_on_sale = serializers.ReadOnlyField()
    discount_percentage = serializers.ReadOnlyField()
    is_in_stock = serializers.ReadOnlyField()
    variants = ProductVariantSerializer(many=True, read_only=True)

    class Meta:
        model = Product
        fields = [
            'id', 'name', 'description', 'category', 'category_name',
            'price', 'old_price', 'stock_quantity', 'image',
            'rating', 'reviews_count', 'is_active', 'is_featured',
            'is_on_sale', 'discount_percentage', 'is_in_stock',
            'has_variants', 'variants', 'created_at', 'updated_at'
        ]

class CartItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    variant = ProductVariantSerializer(read_only=True)
    product_id = serializers.IntegerField(write_only=True)
    variant_id = serializers.IntegerField(write_only=True, required=False, allow_null=True)
    total_price = serializers.ReadOnlyField()
    unit_price = serializers.ReadOnlyField()
    available_stock = serializers.ReadOnlyField()
    is_out_of_stock = serializers.ReadOnlyField()

    class Meta:
        model = CartItem
        fields = [
            'id', 'product', 'variant', 'product_id', 'variant_id', 
            'quantity', 'unit_price', 'total_price', 'available_stock', 
            'is_out_of_stock', 'created_at', 'updated_at'
        ]

    def create(self, validated_data):
        user = self.context['request'].user
        product_id = validated_data.pop('product_id')
        variant_id = validated_data.pop('variant_id', None)
        
        try:
            product = Product.objects.get(id=product_id, is_active=True)
        except Product.DoesNotExist:
            raise serializers.ValidationError({'product_id': 'Product not found or inactive.'})
        
        variant = None
        if variant_id:
            try:
                variant = ProductVariant.objects.get(id=variant_id, product=product, is_active=True)
            except ProductVariant.DoesNotExist:
                raise serializers.ValidationError({'variant_id': 'Product variant not found or inactive.'})
        
        # Check stock availability
        available_stock = variant.stock_quantity if variant else product.stock_quantity
        if validated_data['quantity'] > available_stock:
            raise serializers.ValidationError({
                'quantity': f'Only {available_stock} items available in stock.'
            })
        
        # Check if item already in cart
        cart_item, created = CartItem.objects.get_or_create(
            user=user,
            product=product,
            variant=variant,
            defaults={'quantity': validated_data['quantity']}
        )
        
        if not created:
            # Update quantity if item already exists
            new_quantity = cart_item.quantity + validated_data['quantity']
            if new_quantity > available_stock:
                raise serializers.ValidationError({
                    'quantity': f'Only {available_stock} items available in stock. You already have {cart_item.quantity} in cart.'
                })
            cart_item.quantity = new_quantity
            cart_item.save()
        
        return cart_item

    def update(self, instance, validated_data):
        quantity = validated_data.get('quantity', instance.quantity)
        
        # Validate stock
        available_stock = instance.available_stock
        if quantity > available_stock:
            raise serializers.ValidationError({
                'quantity': f'Only {available_stock} items available in stock.'
            })
        
        instance.quantity = quantity
        instance.save()
        return instance

class OrderItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_image = serializers.ImageField(source='product.image', read_only=True)

    class Meta:
        model = OrderItem
        fields = ['id', 'product', 'product_name', 'product_image', 'quantity', 'price', 'total']

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    coupon_code = serializers.CharField(source='coupon.code', read_only=True)

    class Meta:
        model = Order
        fields = [
            'id', 'order_number', 'user', 'user_email',
            'shipping_name', 'shipping_email', 'shipping_phone',
            'shipping_address_line1', 'shipping_address_line2',
            'shipping_city', 'shipping_state', 'shipping_postal_code', 'shipping_country',
            'subtotal', 'discount_amount', 'coupon', 'coupon_code', 'tax_amount', 
            'shipping_cost', 'total_amount', 'order_status', 'payment_status', 'items',
            'created_at', 'updated_at', 'shipped_at', 'delivered_at'
        ]
        read_only_fields = ['order_number', 'user']

class CouponSerializer(serializers.ModelSerializer):
    is_valid = serializers.SerializerMethodField()

    class Meta:
        model = Coupon
        fields = [
            'id', 'code', 'description', 'discount_type', 'discount_value',
            'minimum_order_amount', 'maximum_discount_amount', 'usage_limit',
            'usage_limit_per_user', 'used_count', 'valid_from', 'valid_until',
            'is_active', 'is_valid'
        ]

    def get_is_valid(self, obj):
        return obj.is_valid()

class CouponValidationSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=50)
    order_amount = serializers.DecimalField(max_digits=10, decimal_places=2)

    def validate(self, data):
        code = data['code']
        order_amount = data['order_amount']
        user = self.context['request'].user
        
        try:
            coupon = Coupon.objects.get(code=code, is_active=True)
        except Coupon.DoesNotExist:
            raise serializers.ValidationError('Invalid coupon code.')
        
        if not coupon.is_valid():
            raise serializers.ValidationError('Coupon is not valid or has expired.')
        
        if order_amount < coupon.minimum_order_amount:
            raise serializers.ValidationError(
                f'Minimum order amount of ₹{coupon.minimum_order_amount} required for this coupon.'
            )
        
        # Check user-specific usage limit
        user_usage_count = CouponUsage.objects.filter(user=user, coupon=coupon).count()
        if user_usage_count >= coupon.usage_limit_per_user:
            raise serializers.ValidationError('You have exceeded the usage limit for this coupon.')
        
        data['coupon'] = coupon
        return data

class CheckoutSerializer(serializers.Serializer):
    shipping_name = serializers.CharField(max_length=100)
    shipping_email = serializers.EmailField()
    shipping_phone = serializers.CharField(max_length=20)
    shipping_address_line1 = serializers.CharField(max_length=255)
    shipping_address_line2 = serializers.CharField(max_length=255, required=False, allow_blank=True)
    shipping_city = serializers.CharField(max_length=100)
    shipping_state = serializers.CharField(max_length=100)
    shipping_postal_code = serializers.CharField(max_length=20)
    shipping_country = serializers.CharField(max_length=100, default='India')
    payment_method = serializers.ChoiceField(choices=Payment.PAYMENT_METHOD_CHOICES)
    coupon_code = serializers.CharField(max_length=50, required=False, allow_blank=True)

    def validate(self, data):
        # Validate that user has items in cart
        user = self.context['request'].user
        cart_items = CartItem.objects.filter(user=user)
        
        if not cart_items.exists():
            raise serializers.ValidationError('Cart is empty. Add items to cart before checkout.')
        
        # Validate stock availability and check for out of stock items
        out_of_stock_items = []
        for item in cart_items:
            if item.is_out_of_stock:
                out_of_stock_items.append(item.product.name)
            elif item.quantity > item.available_stock:
                raise serializers.ValidationError(
                    f'Insufficient stock for {item.product.name}. '
                    f'Available: {item.available_stock}, Requested: {item.quantity}'
                )
        
        if out_of_stock_items:
            raise serializers.ValidationError(
                f'The following items are out of stock: {", ".join(out_of_stock_items)}. '
                f'Please remove them from your cart to proceed.'
            )
        
        # Validate coupon if provided
        coupon_code = data.get('coupon_code')
        if coupon_code:
            subtotal = sum(item.total_price for item in cart_items)
            coupon_validator = CouponValidationSerializer(
                data={'code': coupon_code, 'order_amount': subtotal},
                context=self.context
            )
            if coupon_validator.is_valid():
                data['coupon'] = coupon_validator.validated_data['coupon']
            else:
                raise serializers.ValidationError({'coupon_code': coupon_validator.errors})
        
        return data

class PaymentSerializer(serializers.ModelSerializer):
    order_number = serializers.CharField(source='order.order_number', read_only=True)

    class Meta:
        model = Payment
        fields = [
            'id', 'order', 'order_number', 'payment_method', 'amount', 'currency',
            'transaction_id', 'payment_intent_id', 'razorpay_payment_id',
            'razorpay_order_id', 'razorpay_signature', 'status', 'failure_reason',
            'created_at', 'updated_at', 'completed_at'
        ]
        read_only_fields = ['transaction_id', 'payment_intent_id']

class WishlistSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Wishlist
        fields = ['id', 'product', 'product_id', 'created_at']

    def create(self, validated_data):
        user = self.context['request'].user
        product_id = validated_data.pop('product_id')
        
        try:
            product = Product.objects.get(id=product_id, is_active=True)
        except Product.DoesNotExist:
            raise serializers.ValidationError({'product_id': 'Product not found or inactive.'})
        
        wishlist_item, created = Wishlist.objects.get_or_create(
            user=user,
            product=product
        )
        
        if not created:
            raise serializers.ValidationError({'product_id': 'Product already in wishlist.'})
        
        return wishlist_item
