from django.contrib import admin
from django.contrib.auth.models import User
from django.contrib.auth.admin import UserAdmin

# Customize the User admin to show more fields
class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'is_active', 'date_joined')
    list_filter = ('is_staff', 'is_active', 'date_joined', 'last_login')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    ordering = ('-date_joined',)

# Unregister the default User admin
admin.site.unregister(User)
# Register our custom User admin
admin.site.register(User, CustomUserAdmin)

# Customize admin site headers
admin.site.site_header = "Final Year Project Admin"
admin.site.site_title = "FYP Admin Portal"
admin.site.index_title = "Welcome to Final Year Project Administration"
