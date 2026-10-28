"""
Kişi Yönetim Sistemi - Veri Modeli
Bu dosya, SQLite veritabanındaki 'Person' tablosunun şemasını tanımlar.
"""

from django.db import models


class Person(models.Model):
    """
    Kişi tablosunu temsil eden Django ORM modeli.
    Veritabanında her sütunun tipi, uzunluğu ve kısıtları burada belirlenir.
    """
    # Ad Soyad: En fazla 100 karakterlik metin alanı
    full_name = models.CharField(max_length=100, verbose_name="Ad Soyad")

    # Departman: En fazla 100 karakter (Örn: Yazılım Geliştirme, İnsan Kaynakları)
    department = models.CharField(max_length=100, verbose_name="Departman")

    # Profil Fotoğrafı URL'i: Web adresi (boş bırakılabilir)
    photo_url = models.URLField(max_length=500, blank=True, verbose_name="Fotoğraf URL")

    # Doğum Yeri: İl/İlçe bilgisi
    birth_place = models.CharField(max_length=100, verbose_name="Doğum Yeri")

    # Doğum Tarihi: YYYY-MM-DD formatında tarih
    birth_date = models.DateField(verbose_name="Doğum Tarihi")

    # E-posta: Format kontrolü sağlayan e-posta alanı
    email = models.EmailField(verbose_name="E-posta")

    # Telefon: Uluslararası veya yerel telefon formatı için metin alanı
    phone = models.CharField(max_length=20, verbose_name="Telefon")

    # Eklenme zamanı (Otomatik tutulur)
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="Oluşturulma Tarihi")

    class Meta:
        verbose_name = "Kişi"
        verbose_name_plural = "Kişiler"
        # Varsayılan sıralama: ID'ye göre sırala
        ordering = ['id']

    def __str__(self):
        """Kayıt yazdırıldığında veya Django Admin panelinde görünecek metin."""
        return f"{self.full_name} ({self.department})"
