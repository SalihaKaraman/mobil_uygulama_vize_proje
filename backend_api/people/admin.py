"""
Django Yönetim Paneli Yapılandırması
"""

from django.contrib import admin
from .models import Person


@admin.register(Person)
class PersonAdmin(admin.ModelAdmin):
    list_display = ('id', 'full_name', 'department', 'email', 'phone', 'birth_place')
    search_fields = ('full_name', 'department', 'email', 'phone')
    list_filter = ('department', 'birth_place')
