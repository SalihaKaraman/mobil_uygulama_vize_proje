"""
Django Ayarları - Kişi Yönetim Sistemi REST API
Mobil Programlama Dersi Vize Projesi
"""

from pathlib import Path

# Projenin temel dizini (backend_api klasörü)
BASE_DIR = Path(__file__).resolve().parent.parent

# Güvenlik Anahtarı (Geliştirme ortamı için)
SECRET_KEY = 'django-insecure-mobil-vize-projesi-kisi-yonetim-sistemi-key'

# Geliştirme aşamasında hataları detaylı görmek için True
DEBUG = True

# Mobil cihazlar, emülatörler (10.0.2.2) ve localhost'tan gelen tüm isteklere izin veriyoruz
ALLOWED_HOSTS = ['*']

# Projede kullanılan uygulamalar
INSTALLED_APPS = [
    # CORS (Cross-Origin Resource Sharing) desteği:
    # Mobil ve web istemcilerinin farklı IP/portlardan API'ye erişebilmesini sağlar.
    'corsheaders',

    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Django REST Framework (RESTful API oluşturmak için temel kütüphane)
    'rest_framework',

    # Kişi yönetimi model, serializer ve view'larını barındıran uygulamamız
    'people',
]

MIDDLEWARE = [
    # CorsMiddleware, istek geldiğinde en başta çalışmalı ki CORS başlıklarını ekleyebilsin.
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# Veritabanı: Ek bir sunucu kurulumu gerektirmeyen hafif SQLite veritabanı
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Şifre Doğrulama Kuralları
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# Dil ve Zaman Dilimi
LANGUAGE_CODE = 'tr-tr'
TIME_ZONE = 'Europe/Istanbul'
USE_I18N = True
USE_TZ = True

# Statik Dosyalar (CSS, JavaScript, Görseller)
STATIC_URL = 'static/'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# REST Framework Yapılandırması:
# Sayfalama (Pagination) kapatıldı; yönerge /api/persons ucunun direkt JSON dizisi (Array) dönmesini istiyor.
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': None,
}

# Mobil uygulamadan ve yerel tarayıcılardan gelen CORS isteklerine izin veriyoruz
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True
