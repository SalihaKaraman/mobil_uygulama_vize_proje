import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/person.dart';
import '../services/person_service.dart';
import 'person_form_screen.dart';

/// 2. EKRAN: KİŞİ DETAY SAYFASI (ID BAZLI VERİ & AKSİYON)
/// 
/// Listeden tıklanan kişinin benzersiz ID'si ile açılır.
/// GET /api/persons/{id} çağrısı yaparak kişi detaylarını sunucudan çeker.
class PersonDetailScreen extends StatefulWidget {
  final int personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  final PersonService _service = PersonService();
  late Future<Person> _personFuture;

  @override
  void initState() {
    super.initState();
    _loadPerson();
  }

  void _loadPerson() {
    setState(() {
      _personFuture = _service.getPerson(widget.personId);
    });
  }

  /// Telefon aramasını tetikler (Intent / url_launcher)
  Future<void> _makePhoneCall(String phone) async {
    // Numarayı sadece rakamlar ve + kalacak şekilde temizle
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('Arama uygulaması başlatılamadı: $phone');
      }
    } catch (e) {
      _showSnackBar('Hata: $e');
    }
  }

  /// E-posta gönderme niyetini tetikler (Intent / url_launcher)
  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('E-posta uygulaması açılamadı: $email');
      }
    } catch (e) {
      _showSnackBar('Hata: $e');
    }
  }

  /// Kişiyi Güncelleme Ekranına Geçiş
  Future<void> _navigateToEdit(Person person) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonFormScreen(person: person),
      ),
    );

    // Güncelleme yapıldıysa ekranı yeniden yükle
    if (updated == true) {
      _loadPerson();
    }
  }

  /// Kişiyi Silme Onay Diyaloğu ve DELETE Çağrısı
  Future<void> _confirmAndDelete(Person person) async {
    // 1. Kullanıcıdan onay diyaloğu (Confirmation Dialog) al
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Kişiyi Sil'),
          content: Text(
            '${person.fullName} kişisini rehberden silmek istediğinize emin misiniz?\nBu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('İPTAL'),
            ),
            // Silme butonu (Kırmızı)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('SİL'),
            ),
          ],
        );
      },
    );

    // Kullanıcı vazgeçtiyse çık
    if (shouldDelete != true) return;

    // 2. Kullanıcı onay verdiyse API'ye DELETE isteği yolla
    try {
      await _service.deletePerson(person.id!);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${person.fullName} başarıyla silindi.'),
          backgroundColor: Colors.green,
        ),
      );

      // Listeye geri dön (true parametresi ile listenin yenilenmesini bildir)
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Silme başarısız oldu: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişi Detay Bilgileri'),
      ),
      body: FutureBuilder<Person>(
        future: _personFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Kişi bilgileri yüklenemedi.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPerson,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          final person = snapshot.data!;
          final formattedDate = DateFormat('dd.MM.yyyy').format(person.birthDate);

          return Column(
            children: [
              // Kaydırılabilir Detay Alanı
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // 1. Üstte Büyük Profil Fotoğrafı (Yönerge şartı)
                      Center(
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.indigo.shade100,
                          backgroundImage: person.photoUrl.isNotEmpty
                              ? NetworkImage(person.photoUrl)
                              : null,
                          child: person.photoUrl.isEmpty
                              ? Text(
                                  person.fullName.isNotEmpty
                                      ? person.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Merkezde Ad-Soyad ve Departman Unvanı (Yönerge şartı)
                      Text(
                        person.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        person.department,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // 3. Alt Panel: Kartlar / Satırlar halinde detay bilgileri
                      Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              // Doğum Yeri ve Tarihi
                              ListTile(
                                leading: const Icon(Icons.cake_outlined, color: Colors.indigo),
                                title: const Text(
                                  'D.Yeri / Tarih',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                subtitle: Text(
                                  '${person.birthPlace} | $formattedDate',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Divider(height: 1, indent: 64),

                              // E-Posta (Tıklanabilir -> mailto: tetikler)
                              ListTile(
                                leading: const Icon(Icons.email_outlined, color: Colors.indigo),
                                title: const Text(
                                  'E-Posta (Göndermek için tıklayın)',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                subtitle: Text(
                                  person.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                                onTap: () => _sendEmail(person.email),
                              ),
                              const Divider(height: 1, indent: 64),

                              // Telefon (Tıklanabilir -> tel: tetikler)
                              ListTile(
                                leading: const Icon(Icons.phone_outlined, color: Colors.indigo),
                                title: const Text(
                                  'Telefon (Aramak için tıklayın)',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                subtitle: Text(
                                  person.phone,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                trailing: const Icon(Icons.call, size: 20, color: Colors.green),
                                onTap: () => _makePhoneCall(person.phone),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. En Altta Sabit Aksiyon Butonları (Düzenle ve Kişiyi Sil)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Düzenle Butonu (Yönerge: Bilgileri güncelleme ekranına taşır)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.indigo, width: 1.5),
                          ),
                          onPressed: () => _navigateToEdit(person),
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          label: const Text(
                            'DÜZENLE',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sil Butonu (Yönerge: Onay diyaloğu alıp DELETE isteği yollar)
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _confirmAndDelete(person),
                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                          label: const Text(
                            'KİŞİYİ SİL',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
