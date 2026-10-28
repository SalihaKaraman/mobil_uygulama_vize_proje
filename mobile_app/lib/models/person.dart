/// Kişi Veri Modeli (Person Model)
/// 
/// Bu sınıf, Django REST API'den gelen JSON verisini Dart nesnesine
/// ve mobil uygulamadaki kullanıcı girdilerini API'ye gönderilecek JSON formatına
/// dönüştürmekten sorumludur.
class Person {
  // id: Sunucu tarafından otomatik atandığı için yeni kişi eklerken null olabilir.
  final int? id;
  final String fullName;
  final String department;
  final String photoUrl;
  final String birthPlace;
  final DateTime birthDate;
  final String email;
  final String phone;

  const Person({
    this.id,
    required this.fullName,
    required this.department,
    required this.photoUrl,
    required this.birthPlace,
    required this.birthDate,
    required this.email,
    required this.phone,
  });

  /// JSON verisinden Dart Person nesnesi üreten fabrika yapıcı (factory constructor).
  /// API'den gelen HTTP GET yanıtı JSON Map olarak buraya iletilir.
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int?,
      fullName: json['fullName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      birthPlace: json['birthPlace'] as String? ?? '',
      // String formatındaki ("1994-04-12") tarihi Dart DateTime nesnesine çeviriyoruz
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : DateTime.now(),
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  /// Dart Person nesnesini HTTP POST/PUT isteklerinde gönderilmek üzere JSON Map'e dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'department': department,
      'photoUrl': photoUrl,
      'birthPlace': birthPlace,
      // DateTime nesnesini Django DateField'ın beklediği "YYYY-MM-DD" formatına çeviriyoruz:
      'birthDate': birthDate.toIso8601String().split('T').first,
      'email': email,
      'phone': phone,
    };
  }

  /// Mevcut nesnenin belirli alanlarını güncelleyip yeni bir nesne kopyalamak için kullanılır (Immutability).
  Person copyWith({
    int? id,
    String? fullName,
    String? department,
    String? photoUrl,
    String? birthPlace,
    DateTime? birthDate,
    String? email,
    String? phone,
  }) {
    return Person(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      photoUrl: photoUrl ?? this.photoUrl,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}
