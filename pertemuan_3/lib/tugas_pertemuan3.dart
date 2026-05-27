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
  final String emailPengirim; // [BARU] Validasi Lanjutan
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.emailPengirim,
    required this.dibuatPada,
  });

  // Membuat salinan dengan field yang diubah (dipakai saat Edit)
  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
    String? emailPengirim,
    DateTime? dibuatPada,
  }) {
    return Catatan(
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      kategori: kategori ?? this.kategori,
      emailPengirim: emailPengirim ?? this.emailPengirim,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }
}

// ============================================================
// ARGUMEN NAVIGASI
// Dipakai saat push ke '/form' — membawa data opsional (null = mode Tambah)
// ============================================================

class FormCatatanArgs {
  final Catatan? catatanLama; // null  → mode Tambah, non-null → mode Edit
  final int? index;           // index di list, dipakai saat update

  const FormCatatanArgs({this.catatanLama, this.index});
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
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
        // [BARU] Route '/form' menggantikan '/tambah' — bisa untuk Tambah & Edit
          case '/form':
            final args = settings.arguments as FormCatatanArgs?;
            return MaterialPageRoute(
              builder: (_) => FormCatatanPage(args: args),
            );
          case '/detail':
            final args = settings.arguments as _DetailArgs;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(
                catatan: args.catatan,
                index: args.index,
              ),
            );
        }
        return null;
      },
    );
  }
}

// Wrapper argumen untuk '/detail'
class _DetailArgs {
  final Catatan catatan;
  final int index;
  const _DetailArgs({required this.catatan, required this.index});
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
  // Seluruh catatan (tidak difilter)
  final List<Catatan> _semuaCatatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation di Flutter. '
          'Flutter adalah framework UI dari Google untuk membuat aplikasi '
          'cross-platform dari satu codebase.',
      kategori: 'Kuliah',
      emailPengirim: 'mahasiswa@kampus.ac.id',
      dibuatPada: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Catatan(
      judul: 'Tugas Basis Data',
      isi: 'Membuat ERD untuk sistem perpustakaan. Entitas: Buku, Anggota, Peminjaman.',
      kategori: 'Tugas',
      emailPengirim: 'mahasiswa@kampus.ac.id',
      dibuatPada: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // [BARU] Filter kategori — 'Semua' berarti tidak difilter
  String _filterKategori = 'Semua';

  // List yang tampil (hasil filter)
  List<({Catatan catatan, int indexAsli})> get _catatanTerfilter {
    if (_filterKategori == 'Semua') {
      return [
        for (var i = 0; i < _semuaCatatan.length; i++)
          (catatan: _semuaCatatan[i], indexAsli: i),
      ];
    }
    return [
      for (var i = 0; i < _semuaCatatan.length; i++)
        if (_semuaCatatan[i].kategori == _filterKategori)
          (catatan: _semuaCatatan[i], indexAsli: i),
    ];
  }

  // Buka form Tambah
  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(
      context,
      '/form',
      arguments: const FormCatatanArgs(), // tanpa data lama → mode Tambah
    );

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

  // [BARU] Buka form Edit — dipanggil dari DetailCatatanPage via pop
  // HomePage menerima hasil edit langsung di sini
  Future<void> _bukaDetail(Catatan c, int index) async {
    final hasil = await Navigator.pushNamed(
      context,
      '/detail',
      arguments: _DetailArgs(catatan: c, index: index),
    );

    // Hasil bisa berupa Catatan (setelah edit) atau null (hanya lihat/kembali)
    if (hasil is _HasilEdit) {
      setState(() => _semuaCatatan[hasil.index] = hasil.catatan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${hasil.catatan.judul}" diperbarui!'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Hapus catatan dengan dialog konfirmasi
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
    final terfilter = _catatanTerfilter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        centerTitle: false,
        actions: [
          // [BARU] Dropdown filter kategori
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<String>(
              value: _filterKategori,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.filter_list),
              items: ['Semua', ..._kategoriOpsi]
                  .map(
                    (k) => DropdownMenuItem(
                  value: k,
                  child: Text(k, style: const TextStyle(fontSize: 14)),
                ),
              )
                  .toList(),
              onChanged: (v) => setState(() => _filterKategori = v!),
            ),
          ),
          // Badge jumlah catatan yang tampil
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                '${terfilter.length}/${_semuaCatatan.length}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: terfilter.isEmpty
          ? _EmptyState(filterAktif: _filterKategori != 'Semua')
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: terfilter.length,
        itemBuilder: (context, i) {
          final item = terfilter[i];
          return _CatatanCard(
            catatan: item.catatan,
            onTap: () => _bukaDetail(item.catatan, item.indexAsli),
            onHapus: () => _hapusCatatan(item.indexAsli),
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

// Wrapper nilai yang dikembalikan dari DetailPage setelah edit
class _HasilEdit {
  final Catatan catatan;
  final int index;
  const _HasilEdit({required this.catatan, required this.index});
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
            // Tombol hapus
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Hapus',
              onPressed: onHapus,
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
  final bool filterAktif;
  const _EmptyState({required this.filterAktif});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filterAktif ? Icons.filter_list_off : Icons.note_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            filterAktif
                ? 'Tidak ada catatan di kategori ini'
                : 'Belum ada catatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filterAktif
                ? 'Coba pilih kategori lain atau "Semua".'
                : 'Tap tombol + Tambah untuk membuat catatan baru.',
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
  final FormCatatanArgs? args;
  const FormCatatanPage({super.key, this.args});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // [BARU]

  String _kategori = 'Kuliah';

  // Mode edit: true jika args.catatanLama != null
  bool get _modeEdit => widget.args?.catatanLama != null;

  @override
  void initState() {
    super.initState();
    // Jika mode Edit, isi field dengan data lama
    final lama = widget.args?.catatanLama;
    if (lama != null) {
      _judulCtrl.text = lama.judul;
      _isiCtrl.text = lama.isi;
      _emailCtrl.text = lama.emailPengirim;
      _kategori = lama.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatan = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      emailPengirim: _emailCtrl.text.trim(),
      // Jika edit, pertahankan tanggal asli; jika tambah, pakai waktu sekarang
      dibuatPada: _modeEdit
          ? widget.args!.catatanLama!.dibuatPada
          : DateTime.now(),
    );

    Navigator.pop(context, catatan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Catatan' : 'Tambah Catatan'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Judul ──────────────────────────────────────────
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                hintText: 'Contoh: Rangkuman Algoritma Sorting',
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

            // ── Kategori ───────────────────────────────────────
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

            // ── Email Pengirim [BARU] ──────────────────────────
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                hintText: 'nama@contoh.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email wajib diisi';
                }
                if (!_emailRegex.hasMatch(v.trim())) {
                  return 'Format email tidak valid (contoh: nama@domain.com)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Isi ────────────────────────────────────────────
            TextFormField(
              controller: _isiCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                hintText: 'Tulis catatan kamu di sini...',
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

            // ── Tombol Simpan ──────────────────────────────────
            FilledButton.icon(
              onPressed: _simpan,
              icon: Icon(_modeEdit ? Icons.update : Icons.save),
              label: Text(_modeEdit ? 'Perbarui Catatan' : 'Simpan Catatan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),

            // ── Tombol Batal ───────────────────────────────────
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Batal'),
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
  final int index; // dipakai saat mengembalikan hasil edit ke HomePage

  const DetailCatatanPage({
    super.key,
    required this.catatan,
    required this.index,
  });

  // [BARU] Buka form Edit dari halaman Detail
  Future<void> _bukaEdit(BuildContext context) async {
    final hasil = await Navigator.pushNamed(
      context,
      '/form',
      arguments: FormCatatanArgs(catatanLama: catatan, index: index),
    );

    if (hasil is Catatan) {
      // Teruskan hasil edit ke HomePage dengan membawa index
      if (context.mounted) {
        Navigator.pop(context, _HasilEdit(catatan: hasil, index: index));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        centerTitle: false,
        actions: [
          // [BARU] Tombol Edit di AppBar
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Catatan',
            onPressed: () => _bukaEdit(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori badge
            _KategoriBadge(kategori: catatan.kategori),
            const SizedBox(height: 12),

            // Judul
            Text(
              catatan.judul,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            // Meta: tanggal & email
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

            // Isi
            Text(
              catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.7),
            ),

            const SizedBox(height: 32),

            // Tombol kembali
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