import 'package:branch_comm/screen/QR_scanner_page/view/qr_scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/screen/home_page/view/home.dart';
import 'package:branch_comm/screen/account_page/view/account.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  void _handleTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const QRScannerPage()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Account()),
          (route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
      onTap: _handleTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
      ],
    );
  }
}
