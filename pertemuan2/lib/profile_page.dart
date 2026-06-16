import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pertemuan2/gallery_widget.dart';
import 'package:pertemuan2/quiz_pertemuan_3.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 1;

  // Profile Data
  String _name = "Ikhwan Azhary";
  String _npm = "233040067";
  String _bio = "Saya mahasiswa semester 6 yang tertarik pada Flutter dan pengembangan aplikasi mobile. Hobi saya koding dan mengeksplorasi teknologi baru.";
  Uint8List? _profileImageBytes;

  // Experience Data
  final List<ExperienceItem> _experiences = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Profil Saya"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              accountName: Text("Menu Utama", style: TextStyle(fontSize: 20)),
              accountEmail: null,
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profil"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text("Widget Gallery"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GaleryWidget()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text("Upload Pengalaman"),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadExperiencePage()),
                );
                if (result != null && result is ExperienceItem) {
                  setState(() {
                    _experiences.add(result);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Pengaturan"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Pengaturan"),
                    content: const Text("Halaman pengaturan sedang dalam pengembangan."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Tutup"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageBytes != null
                          ? MemoryImage(_profileImageBytes!)
                          : const AssetImage("assets/Image.jpeg") as ImageProvider,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Mahasiswa Teknik Informatika",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("Post", "12"),
                        _buildStatItem("Teman", "128"),
                        _buildStatItem("Like", "1.2K"),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sections
              _buildSectionCard(
                icon: Icons.info_outline,
                title: "Tentang",
                content: _bio,
              ),
              _buildSectionCard(
                icon: Icons.school_outlined,
                title: "Pendidikan",
                content: "Teknik Informatika - Semester 6",
              ),
              _buildSectionCard(
                icon: Icons.location_on_outlined,
                title: "Lokasi",
                content: "Bandung, Jawa Barat",
              ),
              _buildSectionCard(
                icon: Icons.email_outlined,
                title: "Kontak",
                content: "ikhwanazhary9@gmail.com",
              ),

              const SizedBox(height: 16),
              // Skills Section
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.deepPurple, size: 20),
                  SizedBox(width: 8),
                  Text("Skills", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: ["Flutter", "Dart", "Java", "Python", "Git", "Laravel", "Php"].map((skill) {
                  return Chip(
                    label: Text(skill, style: const TextStyle(color: Colors.deepPurple)),
                    backgroundColor: Colors.deepPurple.shade50,
                    side: BorderSide(color: Colors.deepPurple.shade100),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              // Experience Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.collections_bookmark, color: Colors.deepPurple, size: 20),
                      SizedBox(width: 8),
                      Text("Pengalaman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_experiences.isNotEmpty)
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.deepPurple.shade50,
                      child: Text(_experiences.length.toString(), style: const TextStyle(fontSize: 10, color: Colors.deepPurple)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_experiences.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text("Belum ada pengalaman")),
                  ),
                )
              else
                ..._experiences.map((exp) => _buildExperienceCard(exp)).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                currentName: _name,
                currentBio: _bio,
                currentImageBytes: _profileImageBytes,
              ),
            ),
          );

          if (result != null && result is Map) {
            setState(() {
              _name = result['name'];
              _bio = result['bio'];
              _profileImageBytes = result['image'];
            });
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text("Edit Profil"),
        backgroundColor: Colors.deepPurple.shade50,
        foregroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profil",
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: "Pesan",
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: "Setting",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required String content}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple, size: 20),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(content, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _buildExperienceCard(ExperienceItem exp) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.memory(exp.imageBytes, width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(exp.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}