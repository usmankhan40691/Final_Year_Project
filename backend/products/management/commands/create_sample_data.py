from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from products.models import Category, Product
from decimal import Decimal

class Command(BaseCommand):
    help = 'Create sample data for testing'

    def handle(self, *args, **options):
        # Create superuser if it doesn't exist
        if not User.objects.filter(username='admin').exists():
            User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
            self.stdout.write(self.style.SUCCESS('Created superuser: admin/admin123'))

        # Create categories
        categories = [
            {'name': 'Electronics', 'description': 'Electronic devices and gadgets'},
            {'name': 'Clothing', 'description': 'Fashion and apparel'},
            {'name': 'Books', 'description': 'Books and literature'},
            {'name': 'Home & Garden', 'description': 'Home improvement and gardening'},
            {'name': 'Sports', 'description': 'Sports equipment and accessories'},
        ]

        for cat_data in categories:
            category, created = Category.objects.get_or_create(
                name=cat_data['name'],
                defaults={'description': cat_data['description']}
            )
            if created:
                self.stdout.write(f'Created category: {category.name}')

        # Get categories for products
        electronics = Category.objects.get(name='Electronics')
        clothing = Category.objects.get(name='Clothing')
        books = Category.objects.get(name='Books')

        # Create sample products
        products = [
            {
                'name': 'iPhone 15 Pro',
                'description': 'Latest iPhone with advanced camera system',
                'category': electronics,
                'price': Decimal('999.99'),
                'old_price': Decimal('1099.99'),
                'stock_quantity': 50,
                'is_featured': True,
            },
            {
                'name': 'MacBook Air M2',
                'description': 'Lightweight laptop with M2 chip',
                'category': electronics,
                'price': Decimal('1199.99'),
                'stock_quantity': 25,
                'is_featured': True,
            },
            {
                'name': 'Samsung Galaxy S24',
                'description': 'Premium Android smartphone',
                'category': electronics,
                'price': Decimal('899.99'),
                'old_price': Decimal('999.99'),
                'stock_quantity': 30,
            },
            {
                'name': 'Nike Air Max',
                'description': 'Comfortable running shoes',
                'category': clothing,
                'price': Decimal('149.99'),
                'stock_quantity': 100,
            },
            {
                'name': 'Levi\'s Jeans',
                'description': 'Classic denim jeans',
                'category': clothing,
                'price': Decimal('79.99'),
                'old_price': Decimal('99.99'),
                'stock_quantity': 75,
            },
            {
                'name': 'Python Programming Book',
                'description': 'Learn Python programming from scratch',
                'category': books,
                'price': Decimal('29.99'),
                'stock_quantity': 200,
            },
            {
                'name': 'Web Development Guide',
                'description': 'Complete guide to modern web development',
                'category': books,
                'price': Decimal('39.99'),
                'stock_quantity': 150,
            },
        ]

        for product_data in products:
            product, created = Product.objects.get_or_create(
                name=product_data['name'],
                defaults=product_data
            )
            if created:
                self.stdout.write(f'Created product: {product.name}')

        # Create a test user
        if not User.objects.filter(username='testuser').exists():
            User.objects.create_user('testuser', 'test@example.com', 'testpass123')
            self.stdout.write(self.style.SUCCESS('Created test user: testuser/testpass123'))

        self.stdout.write(self.style.SUCCESS('Sample data created successfully!'))