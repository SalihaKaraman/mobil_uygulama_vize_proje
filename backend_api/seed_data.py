"""
Örnek Veri Yükleme Betiği (Seed Data)
Yönergedeki wireframe (Şekil 1) ve örnek JSON verilerini veritabanına otomatik ekler.
Kullanım:
    python seed_data.py
"""

import os
import django

# Django ayarlarını yükle
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from people.models import Person

INITIAL_DATA = [
    {
        "id": 101,
        "full_name": "Ahmet Yılmaz",
        "department": "Yazılım Geliştirme Departmanı",
        "photo_url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
        "birth_place": "Adana",
        "birth_date": "1994-04-12",
        "email": "ahmet.yilmaz@sirket.com",
        "phone": "+90 (555) 012 34 56",
    },
    {
        "id": 102,
        "full_name": "Ayşe Kaya",
        "department": "İnsan Kaynakları",
        "photo_url": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300&q=80",
        "birth_place": "Ankara",
        "birth_date": "1992-09-03",
        "email": "ayse.kaya@sirket.com",
        "phone": "+90 (555) 023 45 67",
    },
    {
        "id": 103,
        "full_name": "Mehmet Demir",
        "department": "Bilgi Teknolojileri",
        "photo_url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80",
        "birth_place": "İzmir",
        "birth_date": "1990-01-25",
        "email": "mehmet.demir@sirket.com",
        "phone": "+90 (555) 034 56 78",
    },
]


def seed():
    print("Veritabanına örnek veriler yükleniyor...")
    for item in INITIAL_DATA:
        person, created = Person.objects.update_or_create(
            id=item["id"],
            defaults={
                "full_name": item["full_name"],
                "department": item["department"],
                "photo_url": item["photo_url"],
                "birth_place": item["birth_place"],
                "birth_date": item["birth_date"],
                "email": item["email"],
                "phone": item["phone"],
            }
        )
        status = "Oluşturuldu" if created else "Güncellendi"
        print(f"[{status}] ID: {person.id} - {person.full_name}")
    print(f"Toplam {Person.objects.count()} kişi veritabanında hazır!")


if __name__ == '__main__':
    seed()
