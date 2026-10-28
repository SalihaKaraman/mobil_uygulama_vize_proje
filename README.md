# Kişi Yönetim Sistemi (Client-Server REST Mimarisi)
**Mobil Programlama Dersi — Vize Sınavı Proje Çalışması**

Bu proje; bağımsız bir backend web servisi (**Django REST Framework**) ile modern bir mobil kullanıcı arayüzünün (**Flutter**) HTTP/REST protokolü ve JSON veri formatı üzerinden entegre çalıştığı bir CRUD (Create, Read, Update, Delete) uygulamasıdır.

---

## 📁 Proje Dizin Yapısı

Proje, yönergede belirtilen teslim kurallarına uygun olarak kök dizinde iki bağımsız modül halinde yapılandırılmıştır:

```text
mobil_uygulama_vize_proje/
│
├── backend_api/                  # Django REST Framework Web API Servisi
│   ├── config/                   # Django ana ayarları ve URL yönlendirmeleri
│   │   ├── settings.py           # CORS, INSTALLED_APPS ve veritabanı ayarları
│   │   └── urls.py               # /api/persons rotaları (trailing_slash=False)
│   ├── people/                   # Kişi yönetimi uygulaması
│   │   ├── models.py             # Person veritabanı tablosu
│   │   ├── serializers.py        # Django ORM <-> JSON serileştirici (camelCase)
│   │   ├── views.py              # PersonViewSet (CRUD fonksiyonları)
│   │   └── admin.py              # Django yönetim paneli entegrasyonu
│   ├── db.sqlite3                # SQLite veritabanı dosyası
│   ├── manage.py                 # Django yönetim betiği
│   ├── seed_data.py              # Yönergedeki 3 örnek kişiyi yükleyen betik
│   └── requirements.txt          # Gerekli Python kütüphaneleri
│
├── mobile_app/                   # Flutter Mobil İstemci Uygulaması
│   ├── lib/
│   │   ├── models/
│   │   │   └── person.dart       # Dart Person modeli (fromJson, toJson)
│   │   ├── services/
│   │   │   └── person_service.dart # HTTP REST istemcisi (GET, POST, PUT, DELETE)
│   │   ├── screens/
│   │   │   ├── person_list_screen.dart   # 1. Ekran: Kişi Listesi (ListView, FAB, Refresh)
│   │   │   ├── person_detail_screen.dart # 2. Ekran: Kişi Detayı (url_launcher, Silme onayı)
│   │   │   └── person_form_screen.dart   # 3. Ekran: Yeni Kayıt / Düzenleme Formu
│   │   └── main.dart             # Uygulama başlangıç noktası ve tema
│   └── pubspec.yaml              # Paket bağımlılıkları (http, url_launcher, intl)
│
└── README.md                     # Kurulum ve çalıştırma kılavuzu (Bu dosya)
```

---

## 🚀 1. Backend API Servisinin Yerelde Kurulması ve Çalıştırılması

### Gereksinimler
- Python 3.10 veya üzeri
- pip paket yöneticisi

### Adım Adım Kurulum

1. **Backend dizinine gidin:**
   ```bash
   cd backend_api
   ```

2. **Python sanal ortamını (virtual environment) oluşturun:**
   - **macOS / Linux:**
     ```bash
     python3 -m venv venv
     source venv/bin/activate
     ```
   - **Windows:**
     ```cmd
     python -m venv venv
     venv\Scripts\activate
     ```

3. **Gerekli bağımlılıkları yükleyin:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Veritabanı tablolarını oluşturun (Migrate):**
   ```bash
   python manage.py migrate
   ```

5. **Yönergedeki örnek başlangıç verilerini yükleyin:**
   ```bash
   python seed_data.py
   ```
   *(Bu komut Ahmet Yılmaz, Ayşe Kaya ve Mehmet Demir kayıtlarını veritabanına ekler).*

6. **Sunucuyu başlatın:**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```
   API servisiniz artık `http://127.0.0.1:8000/api/persons` adresinde yayındadır.

---

## 📱 2. Flutter Mobil Uygulamasının Çalıştırılması

### Gereksinimler
- Flutter SDK (3.10 veya üzeri)
- Android Studio / Xcode / VS Code
- Android Emülatörü, iOS Simülatörü veya fiziksel test cihazı

### Kurulum ve Çalıştırma

1. **Mobil uygulama dizinine gidin:**
   ```bash
   cd mobile_app
   ```

2. **Paketleri indirin:**
   ```bash
   flutter pub get
   ```

3. **Cihazınızı seçip uygulamayı başlatın:**
   ```bash
   flutter run
   ```

### ⚠️ Önemli Ağ Yapılandırması (Base URL Mantığı)
`lib/services/person_service.dart` dosyası içinde platforma göre IP otomatik yönetilir:
- **Android Emülatörü:** Android emülatörleri kendi iç ağında çalıştığından bilgisayarın localhost'una `http://10.0.2.2:8000/api` adresi üzerinden erişir.
- **iOS Simülatörü ve Web:** Bilgisayarın yerel ağ bağdaştırıcısını doğrudan paylaştığı için `http://127.0.0.1:8000/api` kullanılır.
- **Fiziksel Cihaz (Wi-Fi):** Bilgisayarınızın yerel IP adresini (örn: `http://192.168.1.35:8000/api`) `baseUrl` kısmına yazarak test edebilirsiniz.

---

## 📡 3. REST API Uç Noktaları ve Veri Şeması

| Metot | Uç Nokta | Açıklama |
| :--- | :--- | :--- |
| `GET` | `/api/persons` | Tüm kişileri JSON dizisi (Array) olarak listeler. |
| `GET` | `/api/persons/{id}` | Belirtilen ID'ye sahip kişinin tüm detaylarını döner. |
| `POST` | `/api/persons` | Yeni kişi kaydı oluşturur (Gövdede JSON bekler). |
| `PUT` | `/api/persons/{id}` | Kişinin iletişim ve unvan bilgilerini günceller. |
| `DELETE` | `/api/persons/{id}` | İlgili kaydı veritabanından kalıcı olarak siler. |

### Örnek Kişi JSON Şeması
```json
{
  "id": 101,
  "fullName": "Ahmet Yılmaz",
  "department": "Yazılım Geliştirme Departmanı",
  "photoUrl": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300",
  "birthPlace": "Adana",
  "birthDate": "1994-04-12",
  "email": "ahmet.yilmaz@sirket.com",
  "phone": "+90 (555) 012 34 56"
}
```

---

## 🛡️ 4. Canlı Kod Savunması ve Mülakat Hazırlık Rehberi

### Sık Sorulan Sorular ve Yanıtları:

1. **"Neden FutureBuilder kullandınız?"**
   - Ağ istekleri (HTTP GET) asenkron çalışır ve yanıtın gelmesi zaman alır. `FutureBuilder`, verinin yüklenme anında `CircularProgressIndicator`, hata anında hata mesajı, veri hazır olduğunda ise listeyi dinamik olarak çizmemizi sağlar.
2. **"Neden `trailing_slash=False` tanımladınız?"**
   - Django varsayılan olarak URL'lerin sonuna eğik çizgi (`/`) bekler. Yönergede uç noktalar `/api/persons` ve `/api/persons/{id}` şeklinde belirtilmiştir. `trailing_slash=False` kullanılmadığında Django 301 Redirect döner ve mobil istemcilerde özellikle POST/PUT istekleri bozulabilir.
3. **"Neden utf8.decode(response.bodyBytes) kullandınız?"**
   - Dart'taki `response.body` bazı durumlarda Türkçe karakterleri (ş, ğ, ı, ö, ç, ü) bozuk gösterebilir. `utf8.decode(response.bodyBytes)` kullanılarak karakter setinin UTF-8 standardında kayıpsız işlenmesi garanti altına alınır.
4. **"Kişi silme işleminde neden onay diyaloğu kullandınız?"**
   - Yönerge Madde 2 gereğince, veritabanından kalıcı silme işlemi yapılmadan önce kullanıcıdan `AlertDialog` ile onay alınır. Onay verilirse `DELETE /api/persons/{id}` servisine asenkron istek yollanır ve `Navigator.pop(context, true)` ile ana listeye dönülüp liste güncellenir.

### Canlı Kod Müdahalesi İçin İpuçları:
- **"Kart üzerinde departman yerine telefon numarasını gösteriniz":**
  - `lib/screens/person_list_screen.dart` içindeki `ListTile`'ın `subtitle: Text(person.department)` satırını `subtitle: Text(person.phone)` yapmanız yeterlidir.
- **"Silme onayı uyarısının buton rengini değiştiriniz":**
  - `lib/screens/person_detail_screen.dart` dosyasında `FilledButton.styleFrom(backgroundColor: Colors.red.shade700)` satırındaki rengi (örn. `Colors.amber` veya `Colors.purple`) değiştiriniz.
