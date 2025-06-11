import 'package:branch_comm/pages/booking.dart';
import 'package:flutter/material.dart';
//import 'package:lucide_icons/lucide_icons.dart'; // Optional for icons

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Welcome, John', style: TextStyle(color: Colors.black)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wallet Balance', style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 8),
                      Text('\$1,240.00',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Services Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildServiceTile(Icons.calendar_today, "Book Facility", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Booking()),
                    );
                  }),
                  _buildServiceTile(Icons.send, "Send"),
                  _buildServiceTile(Icons.receipt_long, "Bills"),
                  _buildServiceTile(Icons.phone_android, "Airtime"),
                  _buildServiceTile(Icons.credit_card, "Cards"),
                  _buildServiceTile(Icons.savings, "Savings"),
                  _buildServiceTile(Icons.more_horiz, "More"),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildServiceTile(IconData icon, String label, [VoidCallback? onTap]) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.indigo, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

}
