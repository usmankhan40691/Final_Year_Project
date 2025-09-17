from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'products', views.ProductViewSet, basename='product')
router.register(r'categories', views.CategoryViewSet, basename='category')

urlpatterns = [
    # Router URLs
    path('', include(router.urls)),
    
    # Cart Management
    path('cart/', views.cart_list, name='cart-list'),
    path('cart/add/', views.add_to_cart, name='add-to-cart'),
    path('cart/update/<int:item_id>/', views.update_cart_item, name='update-cart-item'),
    path('cart/remove/<int:item_id>/', views.remove_from_cart, name='remove-from-cart'),
    path('cart/clear/', views.clear_cart, name='clear-cart'),
    
    # Coupon Management
    path('coupons/validate/', views.validate_coupon, name='validate-coupon'),
    
    # Order Management
    path('checkout/', views.checkout, name='checkout'),
    path('orders/', views.order_list, name='order-list'),
    path('orders/<int:order_id>/', views.order_detail, name='order-detail'),
    
    # Payment Processing
    path('payment/process/', views.process_payment, name='process-payment'),
    
    # Wishlist Management
    path('wishlist/', views.wishlist_list, name='wishlist-list'),
    path('wishlist/add/', views.add_to_wishlist, name='add-to-wishlist'),
    path('wishlist/remove/<int:item_id>/', views.remove_from_wishlist, name='remove-from-wishlist'),
]
