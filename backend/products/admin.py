from django.contrib import admin
from django.utils.html import format_html
from .models import Category, Product, CartItem, Order, OrderItem, Payment, Wishlist

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'is_active', 'products_count', 'created_at')
    list_filter = ('is_active', 'created_at')
    search_fields = ('name', 'description')
    prepopulated_fields = {'name': ('name',)}
    readonly_fields = ('created_at', 'updated_at')

    def products_count(self, obj):
        return obj.products.count()
    products_count.short_description = 'Products Count'

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'price', 'old_price', 'stock_quantity', 'is_active', 'is_featured', 'rating')
    list_filter = ('category', 'is_active', 'is_featured', 'created_at')
    search_fields = ('name', 'description')
    list_editable = ('price', 'stock_quantity', 'is_active', 'is_featured')
    readonly_fields = ('created_at', 'updated_at', 'discount_percentage')
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'description', 'category', 'image')
        }),
        ('Pricing', {
            'fields': ('price', 'old_price', 'discount_percentage')
        }),
        ('Inventory', {
            'fields': ('stock_quantity', 'is_active', 'is_featured')
        }),
        ('Reviews', {
            'fields': ('rating', 'reviews_count')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )

    def discount_percentage(self, obj):
        if obj.discount_percentage > 0:
            return f"{obj.discount_percentage}%"
        return "No discount"
    discount_percentage.short_description = 'Discount %'

@admin.register(CartItem)
class CartItemAdmin(admin.ModelAdmin):
    list_display = ('user', 'product', 'quantity', 'total_price', 'created_at')
    list_filter = ('created_at', 'product__category')
    search_fields = ('user__username', 'user__email', 'product__name')
    readonly_fields = ('total_price', 'created_at', 'updated_at')

    def total_price(self, obj):
        return f"₹{obj.total_price}"
    total_price.short_description = 'Total Price'

class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('total',)

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('order_number', 'user', 'total_amount', 'order_status', 'payment_status', 'created_at')
    list_filter = ('order_status', 'payment_status', 'created_at', 'shipping_country')
    search_fields = ('order_number', 'user__username', 'user__email', 'shipping_email')
    readonly_fields = ('order_number', 'created_at', 'updated_at')
    inlines = [OrderItemInline]
    
    fieldsets = (
        ('Order Information', {
            'fields': ('order_number', 'user', 'order_status', 'payment_status')
        }),
        ('Shipping Information', {
            'fields': (
                'shipping_name', 'shipping_email', 'shipping_phone',
                'shipping_address_line1', 'shipping_address_line2',
                'shipping_city', 'shipping_state', 'shipping_postal_code', 'shipping_country'
            )
        }),
        ('Payment Details', {
            'fields': ('subtotal', 'tax_amount', 'shipping_cost', 'total_amount')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at', 'shipped_at', 'delivered_at'),
            'classes': ('collapse',)
        }),
    )

    def get_queryset(self, request):
        return super().get_queryset(request).select_related('user')

@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    list_display = ('order', 'product', 'quantity', 'price', 'total')
    list_filter = ('order__created_at', 'product__category')
    search_fields = ('order__order_number', 'product__name')
    readonly_fields = ('total',)

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ('id', 'order', 'payment_method', 'amount', 'status', 'transaction_id', 'created_at')
    list_filter = ('payment_method', 'status', 'created_at')
    search_fields = ('order__order_number', 'transaction_id', 'payment_intent_id')
    readonly_fields = ('created_at', 'updated_at', 'completed_at')

    fieldsets = (
        ('Payment Information', {
            'fields': ('order', 'payment_method', 'amount', 'currency', 'status')
        }),
        ('Gateway Details', {
            'fields': (
                'transaction_id', 'payment_intent_id', 
                'razorpay_payment_id', 'razorpay_order_id', 'razorpay_signature'
            )
        }),
        ('Additional Info', {
            'fields': ('failure_reason',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at', 'completed_at'),
            'classes': ('collapse',)
        }),
    )

    def colored_status(self, obj):
        colors = {
            'pending': 'orange',
            'processing': 'blue',
            'completed': 'green',
            'failed': 'red',
            'cancelled': 'gray',
            'refunded': 'purple',
        }
        color = colors.get(obj.status, 'black')
        return format_html(
            '<span style="color: {};">{}</span>',
            color,
            obj.get_status_display()
        )
    colored_status.short_description = 'Status'

@admin.register(Wishlist)
class WishlistAdmin(admin.ModelAdmin):
    list_display = ('user', 'product', 'created_at')
    list_filter = ('created_at', 'product__category')
    search_fields = ('user__username', 'user__email', 'product__name')
    readonly_fields = ('created_at',)

# Customize admin site header
admin.site.site_header = "E-Commerce Admin Panel"
admin.site.site_title = "E-Commerce Admin"
admin.site.index_title = "Welcome to E-Commerce Administration"
