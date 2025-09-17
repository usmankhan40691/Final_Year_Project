from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from products.models import Category, Product
from decimal import Decimal
import random

class Command(BaseCommand):
    help = 'Populate the database with sample categories and products'

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('Creating sample categories and products...'))
        
        # Create categories
        categories_data = [
            {
                'name': 'Electronics',
                'description': 'Latest electronic gadgets and devices'
            },
            {
                'name': 'Clothing',
                'description': 'Fashion and apparel for all'
            },
            {
                'name': 'Home & Kitchen',
                'description': 'Home essentials and kitchen appliances'
            },
            {
                'name': 'Books',
                'description': 'Books and educational materials'
            },
            {
                'name': 'Sports & Fitness',
                'description': 'Sports equipment and fitness gear'
            },
            {
                'name': 'Beauty & Personal Care',
                'description': 'Beauty products and personal care items'
            }
        ]

        categories = {}
        for cat_data in categories_data:
            category, created = Category.objects.get_or_create(
                name=cat_data['name'],
                defaults={'description': cat_data['description']}
            )
            categories[cat_data['name']] = category
            if created:
                self.stdout.write(f'Created category: {category.name}')

        # Create products
        products_data = [
            # Electronics
            {
                'name': 'iPhone 15 Pro',
                'description': 'Latest iPhone with advanced features and powerful performance.',
                'category': 'Electronics',
                'price': Decimal('99999.00'),
                'old_price': Decimal('109999.00'),
                'stock_quantity': 50,
                'rating': 4.8,
                'reviews_count': 245,
                'is_featured': True
            },
            {
                'name': 'Samsung Galaxy S24',
                'description': 'Premium Android smartphone with excellent camera quality.',
                'category': 'Electronics',
                'price': Decimal('74999.00'),
                'old_price': Decimal('79999.00'),
                'stock_quantity': 30,
                'rating': 4.6,
                'reviews_count': 189,
                'is_featured': True
            },
            {
                'name': 'MacBook Pro 16"',
                'description': 'High-performance laptop for professionals and creatives.',
                'category': 'Electronics',
                'price': Decimal('249999.00'),
                'stock_quantity': 15,
                'rating': 4.9,
                'reviews_count': 87,
                'is_featured': True
            },
            {
                'name': 'Sony WH-1000XM5',
                'description': 'Premium noise-canceling wireless headphones.',
                'category': 'Electronics',
                'price': Decimal('29999.00'),
                'old_price': Decimal('32999.00'),
                'stock_quantity': 75,
                'rating': 4.7,
                'reviews_count': 324
            },
            {
                'name': 'iPad Air 5th Gen',
                'description': 'Versatile tablet for work, creativity, and entertainment.',
                'category': 'Electronics',
                'price': Decimal('59999.00'),
                'stock_quantity': 40,
                'rating': 4.5,
                'reviews_count': 156
            },
            
            # Clothing
            {
                'name': 'Levi\'s 501 Jeans',
                'description': 'Classic straight fit jeans in premium denim.',
                'category': 'Clothing',
                'price': Decimal('3999.00'),
                'old_price': Decimal('4999.00'),
                'stock_quantity': 100,
                'rating': 4.3,
                'reviews_count': 567
            },
            {
                'name': 'Nike Air Max Sneakers',
                'description': 'Comfortable and stylish sneakers for everyday wear.',
                'category': 'Clothing',
                'price': Decimal('8999.00'),
                'stock_quantity': 80,
                'rating': 4.4,
                'reviews_count': 234
            },
            {
                'name': 'Adidas Hoodie',
                'description': 'Comfortable cotton hoodie perfect for casual wear.',
                'category': 'Clothing',
                'price': Decimal('2999.00'),
                'old_price': Decimal('3999.00'),
                'stock_quantity': 120,
                'rating': 4.2,
                'reviews_count': 145
            },
            {
                'name': 'Formal Dress Shirt',
                'description': 'Premium cotton dress shirt for professional occasions.',
                'category': 'Clothing',
                'price': Decimal('1999.00'),
                'stock_quantity': 90,
                'rating': 4.1,
                'reviews_count': 98
            },
            {
                'name': 'Summer T-Shirt',
                'description': 'Lightweight and breathable t-shirt for hot weather.',
                'category': 'Clothing',
                'price': Decimal('799.00'),
                'old_price': Decimal('999.00'),
                'stock_quantity': 200,
                'rating': 4.0,
                'reviews_count': 456
            },
            
            # Home & Kitchen
            {
                'name': 'KitchenAid Stand Mixer',
                'description': 'Professional-grade stand mixer for all your baking needs.',
                'category': 'Home & Kitchen',
                'price': Decimal('35999.00'),
                'stock_quantity': 25,
                'rating': 4.8,
                'reviews_count': 123,
                'is_featured': True
            },
            {
                'name': 'Dyson V15 Vacuum',
                'description': 'Powerful cordless vacuum cleaner with advanced filtration.',
                'category': 'Home & Kitchen',
                'price': Decimal('45999.00'),
                'old_price': Decimal('49999.00'),
                'stock_quantity': 20,
                'rating': 4.7,
                'reviews_count': 89
            },
            {
                'name': 'Instant Pot Duo',
                'description': 'Multi-functional pressure cooker for quick and easy meals.',
                'category': 'Home & Kitchen',
                'price': Decimal('8999.00'),
                'stock_quantity': 60,
                'rating': 4.6,
                'reviews_count': 278
            },
            {
                'name': 'Coffee Maker',
                'description': 'Programmable coffee maker with thermal carafe.',
                'category': 'Home & Kitchen',
                'price': Decimal('5999.00'),
                'old_price': Decimal('6999.00'),
                'stock_quantity': 45,
                'rating': 4.3,
                'reviews_count': 167
            },
            
            # Books
            {
                'name': 'The Psychology of Money',
                'description': 'Bestselling book about financial wisdom and behavior.',
                'category': 'Books',
                'price': Decimal('399.00'),
                'stock_quantity': 150,
                'rating': 4.6,
                'reviews_count': 1234
            },
            {
                'name': 'Atomic Habits',
                'description': 'Proven ways to build good habits and break bad ones.',
                'category': 'Books',
                'price': Decimal('299.00'),
                'old_price': Decimal('399.00'),
                'stock_quantity': 200,
                'rating': 4.7,
                'reviews_count': 2345
            },
            {
                'name': 'Think and Grow Rich',
                'description': 'Classic self-help book about success and wealth building.',
                'category': 'Books',
                'price': Decimal('199.00'),
                'stock_quantity': 300,
                'rating': 4.4,
                'reviews_count': 567
            },
            
            # Sports & Fitness
            {
                'name': 'Yoga Mat Premium',
                'description': 'High-quality non-slip yoga mat for all fitness levels.',
                'category': 'Sports & Fitness',
                'price': Decimal('1999.00'),
                'old_price': Decimal('2499.00'),
                'stock_quantity': 100,
                'rating': 4.4,
                'reviews_count': 234
            },
            {
                'name': 'Adjustable Dumbbells',
                'description': 'Space-saving adjustable dumbbells for home workouts.',
                'category': 'Sports & Fitness',
                'price': Decimal('12999.00'),
                'stock_quantity': 30,
                'rating': 4.5,
                'reviews_count': 156,
                'is_featured': True
            },
            {
                'name': 'Resistance Bands Set',
                'description': 'Complete resistance bands set with different resistance levels.',
                'category': 'Sports & Fitness',
                'price': Decimal('999.00'),
                'stock_quantity': 150,
                'rating': 4.2,
                'reviews_count': 345
            },
            
            # Beauty & Personal Care
            {
                'name': 'Skincare Routine Set',
                'description': 'Complete skincare set with cleanser, toner, and moisturizer.',
                'category': 'Beauty & Personal Care',
                'price': Decimal('2999.00'),
                'old_price': Decimal('3999.00'),
                'stock_quantity': 80,
                'rating': 4.3,
                'reviews_count': 289
            },
            {
                'name': 'Hair Dryer Professional',
                'description': 'Salon-quality hair dryer with multiple heat settings.',
                'category': 'Beauty & Personal Care',
                'price': Decimal('4999.00'),
                'stock_quantity': 50,
                'rating': 4.4,
                'reviews_count': 178
            },
            {
                'name': 'Electric Toothbrush',
                'description': 'Smart electric toothbrush with app connectivity.',
                'category': 'Beauty & Personal Care',
                'price': Decimal('3999.00'),
                'old_price': Decimal('4999.00'),
                'stock_quantity': 70,
                'rating': 4.5,
                'reviews_count': 234
            }
        ]

        products_created = 0
        for product_data in products_data:
            category = categories[product_data.pop('category')]
            product_data['category'] = category
            
            product, created = Product.objects.get_or_create(
                name=product_data['name'],
                defaults=product_data
            )
            
            if created:
                products_created += 1
                self.stdout.write(f'Created product: {product.name}')

        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully created {len(categories_data)} categories and {products_created} products!'
            )
        )

        # Create a superuser if one doesn't exist
        if not User.objects.filter(is_superuser=True).exists():
            self.stdout.write('Creating superuser...')
            User.objects.create_superuser(
                username='admin',
                email='admin@example.com',
                password='admin123'
            )
            self.stdout.write(self.style.SUCCESS('Superuser created: username=admin, password=admin123'))
        else:
            self.stdout.write('Superuser already exists.')