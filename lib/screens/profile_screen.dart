import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/session_manager.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'package:image/image.dart' as img;
import '../widgets/custom_dialog.dart';
import '../widgets/custom_confirmation_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final int selectedIndex;

  const ProfileScreen({super.key, required this.user, this.selectedIndex = 2});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _imageTemp;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.noHp ?? '');
    addressController = TextEditingController(text: widget.user.alamat ?? '');
    _imageTemp = widget.user.foto;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String fixImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return ''; // Pastikan nilai default jika kosong
    }

    if (!imageUrl.startsWith('http')) {
      return '${ApiService.baseImageUrl}$imageUrl'; // Tambahkan base URL jika perlu
    }

    return imageUrl; // Jika sudah berbentuk URL penuh, kembalikan langsung
  }

  void _saveProfile() async {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      File? selectedImage;
      if (_image != null) {
        File originalFile = File(_image!.path);
        img.Image? image = img.decodeImage(await originalFile.readAsBytes());

        if (image != null) {
          img.Image resizedImage = img.copyResize(image, width: 600);
          List<int> compressedImage = img.encodeJpg(resizedImage, quality: 85);

          String tempPath =
              '${originalFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
          File compressedFile = File(tempPath)
            ..writeAsBytesSync(compressedImage);

          selectedImage = compressedFile;
        }
      }

      var response = await ApiService().updateProfile(
        name: nameController.text,
        email: emailController.text,
        noHp: phoneController.text,
        alamat: addressController.text,
        image: selectedImage,
      );

      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        widget.user.name = response.user.name;
        widget.user.email = response.user.email;
        widget.user.noHp = response.user.noHp;
        widget.user.alamat = response.user.alamat;
        widget.user.foto = response.user.foto;
        _imageTemp = response.user.foto;
        _image = null;
      });
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: "Berhasil",
            message: response.message,
            imagePath: 'assets/yes.png',
            buttonText: "Oke",
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      // Tampilkan Modal Error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
            title: "Terjadi Kesalahan",
            message: e.toString().replaceAll("Exception: ", ""),
            imagePath: 'assets/hand.png',
            buttonText: "Tutup",
            onPressed: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera"),
              onTap: () async {
                Navigator.pop(context); // Tutup modal
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = pickedFile;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeri"),
              onTap: () async {
                Navigator.pop(context); // Tutup modal
                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = pickedFile;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation() async {
    bool confirm = await showCustomConfirmationDialog(
      context: context,
      title: "Konfirmasi Logout",
      message: "Apakah Anda yakin ingin keluar?",
      confirmText: "Logout",
      cancelText: "Batal",
      confirmIcon: Icons.logout, // Icon untuk logout
      cancelIcon: Icons.close, // Icon untuk batal
      confirmColor: Color(0xFFFF001D), // Warna biru untuk tombol logout
      cancelColor: Colors.grey, // Warna abu-abu untuk tombol batal
      logoSvgAsset: "assets/logonew.svg", // Path ke logo SVG aplikasi Anda
      logoSize: 40.0, // Ukuran logo yang sedikit lebih besar
    );

    if (confirm) {
      // Jalankan fungsi logout jika user mengkonfirmasi
      _logout();
    }
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _refreshProfile() async {
    FocusScope.of(context).unfocus();
    try {
      var apiService = ApiService();
      var result = await apiService.getProfile();

      if (!mounted) return;

      if (result["success"]) {
        var userData = result["user"];
        setState(() {
          widget.user.name = userData['name'];
          widget.user.email = userData['email'];
          widget.user.noHp = userData['no_hp'];
          widget.user.alamat = userData['alamat'];
          widget.user.foto = userData['foto'];
          _imageTemp = userData['foto']; // 🔥 Reset ke foto lama dari server
          _image = null; // 🔥 Hapus gambar yang baru dipilih
        });

        nameController.text = userData['name'];
        emailController.text = userData['email'];
        phoneController.text = userData['no_hp'] ?? '';
        addressController.text = userData['alamat'] ?? '';
      } else {
        throw Exception(result["message"]);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui profil: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF0D6EFD),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15), // Atur radius untuk melengkung
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _image != null
                          ? FileImage(File(_image!.path)) as ImageProvider
                          : (_imageTemp != null && _imageTemp!.isNotEmpty)
                              ? NetworkImage(fixImageUrl(_imageTemp))
                              : null,
                      child: (_imageTemp == null || _imageTemp!.isEmpty) &&
                              _image == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFF0D6EFD),
                          child:
                              Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoField(Icons.person, "Nama", nameController),
              _buildInfoField(Icons.email, "Email", emailController),
              _buildInfoField(Icons.phone, "No HP", phoneController),
              _buildInfoField(Icons.location_on, "Alamat", addressController),
              const SizedBox(height: 20),
              _buildButton('Edit Profile', Color(0xFF0D6EFD), _saveProfile),
              const SizedBox(height: 10),
              _buildButton(
                  'Logout', Color(0xFFFF001D), _showLogoutConfirmation),
              const SizedBox(height: 65),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildInfoField(
    IconData icon, String label, TextEditingController controller) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildButton(String text, Color color, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: 20), // Menghilangkan jarak kiri-kanan
    child: SizedBox(
      width: double.infinity, // Full width
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    ),
  );
}
