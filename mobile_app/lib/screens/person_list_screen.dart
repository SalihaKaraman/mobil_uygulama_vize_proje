import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/person_service.dart';
import 'person_detail_screen.dart';
import 'person_form_screen.dart';

/// 1. EKRAN: KİŞİ LİSTESİ (ANA SAYFA)
/// 
/// Sunucudan (GET /api/persons) kişileri çeker ve kaydırılabilir bir listede gösterir.
class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  // REST API çağrılarını yapacak servis örneğimiz
  final PersonService _service = PersonService();

  // Asenkron veri akışını tutan Future değişkeni
  late Future<List<Person>> _personsFuture;

  @override
  void initState() {
    super.initState();
    // Ekran ilk açıldığında sunucudan verileri istiyoruz
    _loadPersons();
  }

  /// Verileri sunucudan çeker ve arayüzü günceller
  void _loadPersons() {
    setState(() {
      _personsFuture = _service.getPersons();
    });
  }

  /// Sayfa aşağı çekildiğinde (Pull-to-refresh) tetiklenir
  Future<void> _handleRefresh() async {
    _loadPersons();
    try {
      await _personsFuture;
    } catch (_) {
      // Hata oluşursa FutureBuilder zaten arayüzde gösterecek
    }
  }

  /// Satıra tıklandığında Kişi Detay Sayfasına gider (Yönerge: Kişi ID'si ile açılır)
  Future<void> _navigateToDetail(Person person) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonDetailScreen(personId: person.id!),
      ),
    );

    // Detay ekranından geri dönüldüğünde (silme veya güncelleme yapılmış olabilir)
    // listeyi otomatik yeniliyoruz.
    if (result == true || mounted) {
      _loadPersons();
    }
  }

  /// FAB (+) butonuna tıklandığında Yeni Kişi Ekleme Ekranına gider
  Future<void> _navigateToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PersonFormScreen(),
      ),
    );

    // Yeni kişi eklendiyse listeyi yenile
    if (result == true) {
      _loadPersons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rehber / Kişi Listesi'),
      ),
      // FutureBuilder: Asenkron (Future) verinin durumuna (yükleniyor, hata, tamamlandı)
      // göre otomatik farklı widget'lar çizer.
      body: FutureBuilder<List<Person>>(
        future: _personsFuture,
        builder: (context, snapshot) {
          // 1. Durum: Veri sunucudan bekleniyor (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Durum: Sunucuya bağlanırken bir hata oluştu
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      'Sunucuya bağlanılamadı!\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loadPersons,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          final persons = snapshot.data ?? [];

          // 3. Durum: Veritabanında hiç kayıt yok
          if (persons.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text(
                      'Henüz kayıtlı kişi bulunmamaktadır.\n+ butonuna basarak yeni kişi ekleyebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. Durum: Veriler başarıyla geldi -> Listeyi çiziyoruz
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: persons.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final person = persons[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // Solda dairesel profil fotoğrafı (Ağ resmi)
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.indigo.shade100,
                    backgroundImage: person.photoUrl.isNotEmpty
                        ? NetworkImage(person.photoUrl)
                        : null,
                    // Fotoğraf yüklenemezse veya yoksa baş harfi göster
                    child: person.photoUrl.isEmpty
                        ? Text(
                            person.fullName.isNotEmpty ? person.fullName[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  // Kalın yazı tipiyle Ad-Soyad (Yönerge şartı)
                  title: Text(
                    person.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  // Altında Departman bilgisi (Yönerge şartı)
                  subtitle: Text(
                    person.department,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  // Satıra tıklandığında seçilen kişinin ID'si ile Detay Ekranını aç
                  onTap: () => _navigateToDetail(person),
                );
              },
            ),
          );
        },
      ),
      // Sağ alt köşede sabit + simgeli Floating Action Button (Yönerge şartı)
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        tooltip: 'Yeni Kişi Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
