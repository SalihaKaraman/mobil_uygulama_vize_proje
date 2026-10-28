"""
URL Yapılandırması - Kişi Yönetim Sistemi REST API
"""

from django.contrib import admin
from django.urls import path, include
from django.views.generic import RedirectView
from rest_framework.routers import DefaultRouter
from people.views import PersonViewSet

# trailing_slash=False:
# Yönergedeki URL şeması (/api/persons ve /api/persons/{id}) sonda eğik çizgi (/) içermez.
# Varsayılan Django davranışı 301 Redirect tetikleyeceği için bunu kapatıyoruz.
router = DefaultRouter(trailing_slash=False)
router.register('persons', PersonViewSet, basename='person')

urlpatterns = [
    # Ana dizine (/) gidildiğinde doğrudan /api/persons listesine yönlendir (404 almamak için)
    path('', RedirectView.as_view(url='/api/persons', permanent=False)),
    path('admin/', admin.site.urls),
    # /api/persons rotalarını router aracılığıyla ekliyoruz
    path('api/', include(router.urls)),
]
