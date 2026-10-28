"""
Kişi Yönetim Sistemi - Serializer (Serileştirici)
Django ORM modelleri ile JSON veri formatı arasındaki çift yönlü dönüşümü sağlar.
"""

from rest_framework import serializers
from .models import Person


class PersonSerializer(serializers.ModelSerializer):
    """
    Person modelini yönergede belirtilen JSON formatına dönüştüren sınıf.
    
    Python/Django standardında sütun isimleri snake_case (full_name, birth_place) iken,
    Mobil istemci ve REST JSON standardında camelCase (fullName, birthPlace) kullanılır.
    'source' parametresi bu iki yönlü eşleşmeyi kusursuz bir şekilde sağlar.
    """
    fullName = serializers.CharField(source='full_name')
    photoUrl = serializers.URLField(source='photo_url', required=False, allow_blank=True)
    birthPlace = serializers.CharField(source='birth_place')
    birthDate = serializers.DateField(source='birth_date')

    class Meta:
        model = Person
        fields = [
            'id',
            'fullName',
            'department',
            'photoUrl',
            'birthPlace',
            'birthDate',
            'email',
            'phone',
        ]
        read_only_fields = ['id']  # ID veritabanı tarafından otomatik atanır, kullanıcı değiştiremez
