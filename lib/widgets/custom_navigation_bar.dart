import 'package:flutter/material.dart';
import '../models/user.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final User user;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: Color(0xFF0D6EFD),
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol Home dengan area klik lebih besar
            InkWell(
              onTap: () => onTap(0),
              borderRadius:
                  BorderRadius.circular(50), // Agar efek sentuhnya bulat
              splashColor: Colors.white.withAlpha(76), // Efek sentuh transparan
              highlightColor: Colors.transparent, // Hilangkan highlight default
              child: Transform.translate(
                offset: Offset(0, -8), // Naikkan ikon ke atas 5 pixel
                child: Container(
                  padding: EdgeInsets.all(10), // Perbesar area sentuh
                  child: Icon(
                    Icons.home,
                    size: 28, // Perbesar ikon
                    color: selectedIndex == 0 ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),

            // Tombol Profil dengan area klik luas & ikon naik ke atas
            InkWell(
              onTap: () => onTap(1),
              borderRadius:
                  BorderRadius.circular(50), // Agar efek sentuhnya bulat
              splashColor: Colors.white.withAlpha(76), // Efek sentuh transparan
              highlightColor: Colors.transparent, // Hilangkan highlight default
              child: Transform.translate(
                offset: Offset(0, -8), // Naikkan ikon ke atas 5 pixel
                child: Container(
                  padding: EdgeInsets.all(10), // Perbesar area sentuh
                  child: Icon(
                    Icons.person,
                    size: 28, // Perbesar ikon
                    color: selectedIndex == 1 ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
