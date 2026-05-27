import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================
// MODEL
// ============================================================

class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });
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
      routes: {
        '/': (context) => const HomePage(),
        '/tambah': (context) => const TambahCatatanPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final catatan = settings.arguments as Catatan;
          return MaterialPageRoute(
            builder: (_) => DetailCatatanPage(catatan: catatan),
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
  final List<Catatan> _semuaCatatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation di Flutter.',
      kategori: 'Kuliah',
      dibuatPada: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Catatan(
      judul: 'Tugas Basis Data',
      isi: 'Membuat ERD untuk sistem perpustakaan.',
      kategori: 'Tugas',
      dibuatPada: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() => _semuaCatatan.add(hasil));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${hasil.judul}" ditambahkan!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _hapusCatatan(int index) async {
    final nama = _semuaCatatan[index].judul;
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Yakin ingin menghapus "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      setState(() => _semuaCatatan.removeAt(index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        centerTitle: false,
      ),
      body: _semuaCatatan.isEmpty
          ? const _EmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _semuaCatatan.length,
        itemBuilder: (context, i) {
          return _CatatanCard(
            catatan: _semuaCatatan[i],
            onTap: () => Navigator.pushNamed(
              context,
              '/detail',
              arguments: _semuaCatatan[i],
            ),
            onHapus: () => _hapusCatatan(i),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaTambahCatatan,
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

  const _CatatanCard({
    required this.catatan,
    required this.onTap,
    required this.onHapus,
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
            Container(width: 6, height: 80, color: warna),
            const SizedBox(width: 12),
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
                    _KategoriBadge(kategori: catatan.kategori),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onHapus,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: BADGE KATEGORI
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
        color: warna.withOpacity(0.12),
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
          Icon(Icons.note_outlined, size: 80, color: Colors.grey[300]),
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
// TAMBAH CATATAN PAGE
// ============================================================

class TambahCatatanPage extends StatefulWidget {
  const TambahCatatanPage({super.key});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  String _kategori = 'Kuliah';

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatan = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      dibuatPada: DateTime.now(),
    );

    Navigator.pop(context, catatan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Catatan'),
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
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
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
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Catatan'),
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
        centerTitle: false,
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
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
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
            const Divider(height: 32),
            Text(
              catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.7),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali ke Daftar'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}