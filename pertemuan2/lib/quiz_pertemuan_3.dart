import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pertemuan2/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Pertemuan 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

// =================== MODEL ===================

class ExperienceItem {
  final Uint8List imageBytes;
  final String title;
  final String description;

  const ExperienceItem({
    required this.imageBytes,
    required this.title,
    required this.description,
  });
}

// =================== EDIT PROFILE PAGE ===================

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final String currentEducation;
  final String currentLocation;
  final String currentContact;
  final String currentSkills;
  final Uint8List? currentImageBytes;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentBio,
    required this.currentEducation,
    required this.currentLocation,
    required this.currentContact,
    required this.currentSkills,
    this.currentImageBytes,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _educationController;
  late TextEditingController _locationController;
  late TextEditingController _contactController;
  late TextEditingController _skillsController;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(text: widget.currentBio);
    _educationController = TextEditingController(text: widget.currentEducation);
    _locationController = TextEditingController(text: widget.currentLocation);
    _contactController = TextEditingController(text: widget.currentContact);
    _skillsController = TextEditingController(text: widget.currentSkills);
    _selectedImageBytes = widget.currentImageBytes;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _processPickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _processPickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'name': _nameController.text,
                'bio': _bioController.text,
                'education': _educationController.text,
                'location': _locationController.text,
                'contact': _contactController.text,
                'skills': _skillsController.text,
                'image': _selectedImageBytes,
              });
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Foto Profil", style: TextStyle(color: Colors.deepPurple)),
            const SizedBox(height: 16),
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _selectedImageBytes != null
                      ? MemoryImage(_selectedImageBytes!)
                      : const AssetImage("assets/Image.jpeg") as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text("Ganti Foto dari Galeri"),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Informasi Profil", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap *",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Bio / Tentang",
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _educationController,
              decoration: const InputDecoration(
                labelText: "Pendidikan",
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Lokasi",
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: "Kontak",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillsController,
              decoration: const InputDecoration(
                labelText: "Skills (pisahkan dengan koma)",
                prefixIcon: Icon(Icons.star_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'name': _nameController.text,
                    'bio': _bioController.text,
                    'education': _educationController.text,
                    'location': _locationController.text,
                    'contact': _contactController.text,
                    'skills': _skillsController.text,
                    'image': _selectedImageBytes,
                  });
                },
                icon: const Icon(Icons.save),
                label: const Text("Simpan Perubahan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== UPLOAD EXPERIENCE PAGE ===================

class UploadExperiencePage extends StatefulWidget {
  final ExperienceItem? item;

  const UploadExperiencePage({super.key, this.item});

  @override
  State<UploadExperiencePage> createState() => _UploadExperiencePageState();
}

class _UploadExperiencePageState extends State<UploadExperiencePage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? "");
    _descController = TextEditingController(text: widget.item?.description ?? "");
    _selectedImageBytes = widget.item?.imageBytes;
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _processPickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _processPickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? "Upload Pengalaman" : "Edit Pengalaman"),
        actions: [
          TextButton(
            onPressed: () {
              if (_selectedImageBytes != null && _titleController.text.isNotEmpty) {
                Navigator.pop(context, ExperienceItem(
                  imageBytes: _selectedImageBytes!,
                  title: _titleController.text,
                  description: _descController.text,
                ));
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple.shade100),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.deepPurple.shade50.withValues(alpha: 0.3),
                ),
                child: _selectedImageBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.deepPurple.shade200),
                    const SizedBox(height: 8),
                    Text("Ketuk untuk pilih gambar", style: TextStyle(color: Colors.deepPurple.shade300)),
                    Text("dari galeri perangkat kamu", style: TextStyle(color: Colors.deepPurple.shade200, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Informasi Pengalaman", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Judul *",
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_selectedImageBytes != null && _titleController.text.isNotEmpty) {
                    Navigator.pop(context, ExperienceItem(
                      imageBytes: _selectedImageBytes!,
                      title: _titleController.text,
                      description: _descController.text,
                    ));
                  }
                },
                icon: const Icon(Icons.save),
                label: Text(widget.item == null ? "Simpan Pengalaman" : "Update Pengalaman"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}