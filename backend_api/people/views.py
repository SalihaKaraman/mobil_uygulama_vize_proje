"""
Kişi Yönetim Sistemi - API View Katmanı
İstemciden (Mobil Uygulama) gelen HTTP isteklerini karşılar ve yanıt üretir.
"""

from rest_framework import viewsets
from .models import Person
from .serializers import PersonSerializer


class PersonViewSet(viewsets.ModelViewSet):
    """
    ModelViewSet, RESTful CRUD işlemlerinin tamamını otomatik olarak sağlar:
    - GET    /api/persons       -> list()     : Tüm kişileri JSON dizisi olarak listeler
    - POST   /api/persons       -> create()   : Yeni bir kişi kaydı oluşturur (HTTP 201)
    - GET    /api/persons/{id}  -> retrieve() : ID'si verilen kişinin detayını döner (HTTP 200)
    - PUT    /api/persons/{id}  -> update()   : Belirtilen kişinin bilgilerini günceller (HTTP 200)
    - DELETE /api/persons/{id}  -> destroy()  : Belirtilen kişiyi veritabanından siler (HTTP 204)
    """
    queryset = Person.objects.all().order_by('id')
    serializer_class = PersonSerializer
