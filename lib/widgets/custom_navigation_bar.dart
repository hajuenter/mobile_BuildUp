import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0, // Sedikit lebih kecil agar pas
      color: Colors.blue,
      height: 50, // Mengurangi tinggi navbar
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home,
                  color: selectedIndex == 0 ? Colors.white : Colors.white70),
              onPressed: () => onTap(0),
            ),
            IconButton(
              icon: Icon(Icons.person,
                  color: selectedIndex == 1 ? Colors.white : Colors.white70),
              onPressed: () => onTap(1),
            ),
          ],
        ),
      ),
    );
  }
}
