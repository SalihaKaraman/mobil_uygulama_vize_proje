import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/person.dart';

/// Kişi Yönetim Sistemi - REST API Ağ Servisi
/// 
/// Bu sınıf, Flutter istemcisinin Django REST API ile HTTP protokolü
/// (GET, POST, PUT, DELETE) üzerinden haberleşmesini yönetir.
class PersonService {
  /// Çalışılan ortama göre API sunucusunun temel adresi (Base URL)
  /// 
  /// NEDEN FARKLI ADRESLER?
  /// 1. Android Emülatör: Emülatör kendi içinde sanal bir işletim sistemidir.
  ///    "127.0.0.1" emülatörün kendisini temsil eder.
  ///    Bilgisayarınızın (sunucunun) localhost'una erişmek için Google "10.0.2.2" IP'sini ayrılmıştır.
  /// 2. iOS Simülatörü ve Web: Doğrudan bilgisayarın ağ bağdaştırıcısını paylaştığı için "127.0.0.1" kullanılır.
  /// 3. Fiziksel Cihaz (Telefon): Bilgisayarınızın yerel Wi-Fi IP adresi (örn: 192.168.1.35) girilmelidir.
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  /// HTTP istek başlıkları (Headers)
  /// Sunucuya gönderilen gövdenin JSON olduğunu ve Türkçe karakterlerin doğru
  /// işlenmesi için UTF-8 karakter setini kullandığını belirtir.
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// 1. TÜM KİŞİLERİ LİSTELE (GET /api/persons)
  /// API'den dönen JSON dizisini `List<Person>` nesnelerine dönüştürür.
  Future<List<Person>> getPersons() async {
    final uri = Uri.parse('$baseUrl/persons');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // utf8.decode(response.bodyBytes): Türkçe karakterlerin (ğ, ü, ş, ı, ö, ç)
      // bozulmadan düzgün okunmasını sağlar.
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((item) => Person.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Kişi listesi alınamadı (HTTP Hata Kodu: ${response.statusCode})');
    }
  }

  /// 2. TEK BİR KİŞİNİN DETAYINI GETİR (GET /api/persons/{id})
  /// Verilen ID'ye sahip kişinin bilgilerini sunucudan çeker.
  Future<Person> getPerson(int id) async {
    final uri = Uri.parse('$baseUrl/persons/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(data);
    } else {
      throw Exception('Kişi detay bilgisi bulunamadı (HTTP Hata Kodu: ${response.statusCode})');
    }
  }

  /// 3. YENİ KİŞİ OLUŞTUR (POST /api/persons)
  /// Formdan girilen kişi verilerini JSON formatında sunucuya gönderir.
  /// Sunucu başarılı eklemede HTTP 201 Created döner.
  Future<Person> createPerson(Person person) async {
    final uri = Uri.parse('$baseUrl/persons');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(person.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(data);
    } else {
      final detail = _extractErrorMessage(response);
      throw Exception(detail);
    }
  }

  /// 4. KİŞİYİ GÜNCELLE (PUT /api/persons/{id})
  /// Var olan kişinin güncel bilgilerini sunucuya aktarır.
  /// Başarılı işlemde HTTP 200 OK döner.
  Future<Person> updatePerson(int id, Person person) async {
    final uri = Uri.parse('$baseUrl/persons/$id');
    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(person.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return Person.fromJson(data);
    } else {
      final detail = _extractErrorMessage(response);
      throw Exception(detail);
    }
  }

  /// Sunucudan dönen hata mesajını (örneğin geçersiz URL, eksik alan) ayrıştırır
  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final messages = decoded.entries.map((entry) {
          final val = entry.value;
          final valStr = (val is List) ? val.join(', ') : val.toString();
          return '${entry.key}: $valStr';
        }).join('\n');
        if (messages.isNotEmpty) return messages;
      }
    } catch (_) {}
    return 'Sunucu Hatası (HTTP ${response.statusCode})';
  }

  /// 5. KİŞİYİ SİL (DELETE /api/persons/{id})
  /// Verilen ID'ye sahip kaydı kalıcı olarak siler.
  /// REST standardında silme başarılı olduğunda gövdesiz HTTP 204 No Content döner.
  Future<void> deletePerson(int id) async {
    final uri = Uri.parse('$baseUrl/persons/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Kişi silinemedi (HTTP Hata Kodu: ${response.statusCode})');
    }
  }
}
