import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/person.dart';
import '../services/person_service.dart';

/// 3. EKRAN: KİŞİ EKLEME VE DÜZENLEME FORMU
/// 
/// Hem yeni kişi kaydı (POST /api/persons) hem de mevcut kişiyi
/// güncellemek (PUT /api/persons/{id}) için ortak kullanılan form ekranıdır.
class PersonFormScreen extends StatefulWidget {
  final Person? person; // Düzenleme modunda dolu gelir, yeni eklemede null'dır.

  const PersonFormScreen({super.key, this.person});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PersonService _service = PersonService();

  // Metin kontrolcüleri (Controllers)
  late final TextEditingController _fullNameController;
  late final TextEditingController _departmentController;
  late final TextEditingController _photoUrlController;
  late final TextEditingController _birthPlaceController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  bool get _isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    final p = widget.person;

    _fullNameController = TextEditingController(text: p?.fullName ?? '');
    _departmentController = TextEditingController(text: p?.department ?? '');
    _photoUrlController = TextEditingController(text: p?.photoUrl ?? '');
    _birthPlaceController = TextEditingController(text: p?.birthPlace ?? '');
    _selectedBirthDate = p?.birthDate ?? DateTime(1995, 1, 1);
    _birthDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
    );
    _emailController = TextEditingController(text: p?.email ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _departmentController.dispose();
    _photoUrlController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Tarih Seçici Diyaloğu (DatePicker)
  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Doğum Tarihi Seçiniz',
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  /// Formu Doğrula ve Sunucuya Kaydet (POST veya PUT)
  Future<void> _savePerson() async {
    // 1. Form Doğrulaması (Validation)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final personData = Person(
      id: widget.person?.id,
      fullName: _fullNameController.text.trim(),
      department: _departmentController.text.trim(),
      photoUrl: _photoUrlController.text.trim(),
      birthPlace: _birthPlaceController.text.trim(),
      birthDate: _selectedBirthDate ?? DateTime(1995, 1, 1),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    try {
      if (_isEditing) {
        // PUT /api/persons/{id} isteği
        await _service.updatePerson(widget.person!.id!, personData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kişi başarıyla güncellendi.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // POST /api/persons isteği
        await _service.createPerson(personData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yeni kişi başarıyla kaydedildi.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Başarılı olduğunda bir önceki sayfaya 'true' dönerek listeyi tazelet
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem başarısız: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Kişi Bilgilerini Güncelle' : 'Yeni Kişi Kaydı';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sunucuya kaydediliyor...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ad Soyad Alanı
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen Ad-Soyad giriniz.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Departman Alanı
                    TextFormField(
                      controller: _departmentController,
                      decoration: const InputDecoration(
                        labelText: 'Departman / Unvan *',
                        prefixIcon: Icon(Icons.business_center),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen departman giriniz.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Profil Fotoğrafı URL (İsteğe bağlı)
                    TextFormField(
                      controller: _photoUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Profil Fotoğrafı URL (İsteğe bağlı)',
                        prefixIcon: Icon(Icons.image),
                        border: OutlineInputBorder(),
                        hintText: 'https://example.com/photo.jpg',
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final text = value.trim();
                          if (!text.startsWith('http://') && !text.startsWith('https://')) {
                            return 'Geçerli bir web adresi giriniz (http:// veya https://) veya boş bırakınız.';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Doğum Yeri
                    TextFormField(
                      controller: _birthPlaceController,
                      decoration: const InputDecoration(
                        labelText: 'Doğum Yeri *',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen doğum yeri giriniz.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Doğum Tarihi (DatePicker ile seçilir)
                    TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Doğum Tarihi *',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onTap: _pickBirthDate,
                    ),
                    const SizedBox(height: 16),

                    // E-Posta Alanı
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-Posta Adresi *',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen e-posta giriniz.';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Geçerli bir e-posta adresi giriniz.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Telefon Alanı
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefon Numarası *',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                        hintText: '+90 (555) 000 00 00',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen telefon numarası giriniz.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Kaydet Butonu
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                      ),
                      onPressed: _savePerson,
                      icon: const Icon(Icons.save),
                      label: Text(
                        _isEditing ? 'GÜNCELLEMEYİ KAYDET' : 'KİŞİYİ KAYDET',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
