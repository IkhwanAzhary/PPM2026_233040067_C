import 'package:flutter/material.dart';
import 'db_helper.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ============================================================
// MODEL
// ============================================================

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final String emailPengirim;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.emailPengirim,
    required this.dibuatPada,
  });

  // === Dart object → row Map ===
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'email_pengirim': emailPengirim,
    'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
  };

  // === Row Map → Dart object ===
  static Catatan fromMap(Map<String, Object?> m) => Catatan(
    id: m['id'] as int?,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    kategori: m['kategori'] as String,
    emailPengirim: m['email_pengirim'] as String,
    dibuatPada:
    DateTime.fromMillisecondsSinceEpoch(m['dibuat_pada'] as int),
  );

  // Helper untuk Edit — copy dengan beberapa field diganti.
  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
    String? emailPengirim,
  }) =>
      Catatan(
        id: id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        emailPengirim: emailPengirim ?? this.emailPengirim,
        dibuatPada: dibuatPada,
      );
}

// ============================================================
// APP ROOT
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/form':
            final arg = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => FormCatatanPage(initial: arg as Catatan?),
            );
          case '/detail':
            final c = settings.arguments as Catatan;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: c),
            );
        }
        return null;
      },
    );
  }
}

// ============================================================
// HELPER
// ============================================================

String _formatTanggal(DateTime dt) {
  final bulan = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  final d = dt.day.toString().padLeft(2, '0');
  final m = bulan[dt.month];
  final y = dt.year;
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$d $m $y, $h:$min';
}

Color _warnaKategori(String kategori) {
  switch (kategori) {
    case 'Kuliah':
      return Colors.indigo;
    case 'Tugas':
      return Colors.orange;
    case 'Pribadi':
      return Colors.green;
    default:
      return Colors.blueGrey;
  }
}

// Regex validasi email (RFC-sederhana)
final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

const _kategoriOpsi = ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Catatan>> _futureCatatan;

  @override
  void initState() {
    super.initState();
    _muatUlang();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = DbHelper.instance.getAll();
    });
  }

  // Navigasi ke Form (Tambah)
  Future<void> _bukaForm({Catatan? initial}) async {
    await Navigator.pushNamed(context, '/form', arguments: initial);
    _muatUlang();
  }

  // Hapus catatan
  Future<void> _hapusCatatan(Catatan c) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Hapus "${c.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true && c.id != null) {
      await DbHelper.instance.delete(c.id!);
      _muatUlang();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${c.judul}" dihapus')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? const [];
          if (data.isEmpty) return const _EmptyState();
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final c = data[i];
              return _CatatanCard(
                catatan: c,
                onTap: () async {
                  await Navigator.pushNamed(context, '/detail', arguments: c);
                  _muatUlang();
                },
                onHapus: () => _hapusCatatan(c),
                onEdit: () => _bukaForm(initial: c),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

// ============================================================
// WIDGET: CARD CATATAN
// ============================================================

class _CatatanCard extends StatelessWidget {
  final Catatan catatan;
  final VoidCallback onTap;
  final VoidCallback onHapus;
  final VoidCallback onEdit;

  const _CatatanCard({
    required this.catatan,
    required this.onTap,
    required this.onHapus,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final warna = _warnaKategori(catatan.kategori);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Strip warna kiri
            Container(width: 6, height: 88, color: warna),
            const SizedBox(width: 12),
            // Konten
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      catatan.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      catatan.isi,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _KategoriBadge(kategori: catatan.kategori),
                        const SizedBox(width: 8),
                        Icon(Icons.email_outlined,
                            size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            catatan.emailPengirim,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Aksi
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Hapus',
                  onPressed: onHapus,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: BADGE KATEGORI (reusable)
// ============================================================

class _KategoriBadge extends StatelessWidget {
  final String kategori;
  const _KategoriBadge({required this.kategori});

  @override
  Widget build(BuildContext context) {
    final warna = _warnaKategori(kategori);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kategori,
        style: TextStyle(
          color: warna,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada catatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + Tambah untuk membuat catatan baru.',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FORM CATATAN PAGE  (Tambah & Edit — satu halaman, dua mode)
// ============================================================

class FormCatatanPage extends StatefulWidget {
  final Catatan? initial;
  const FormCatatanPage({super.key, this.initial});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;
  late final TextEditingController _emailCtrl;

  late String _kategori;
  bool _menyimpan = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.initial?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.initial?.isi ?? '');
    _emailCtrl = TextEditingController(text: widget.initial?.emailPengirim ?? '');
    _kategori = widget.initial?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);

    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          emailPengirim: _emailCtrl.text.trim(),
        );
        await DbHelper.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          emailPengirim: _emailCtrl.text.trim(),
          dibuatPada: DateTime.now(),
        );
        await DbHelper.instance.insert(baru);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Catatan diperbarui' : 'Catatan ditambahkan'),
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                if (!_emailRegex.hasMatch(v.trim())) return 'Format email salah';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.notes),
                ),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_isEdit ? Icons.update : Icons.save),
              label: Text(_isEdit ? 'Perbarui Catatan' : 'Simpan Catatan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DETAIL CATATAN PAGE
// ============================================================

class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;

  const DetailCatatanPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, '/form', arguments: catatan);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KategoriBadge(kategori: catatan.kategori),
            const SizedBox(height: 12),
            Text(
              catatan.judul,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatTanggal(catatan.dibuatPada),
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  catatan.emailPengirim,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}