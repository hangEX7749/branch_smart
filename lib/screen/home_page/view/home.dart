import 'package:branch_comm/screen/home_page/utils/index.dart';
//import 'package:lucide_icons/lucide_icons.dart'; // Optional for icons

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String? name, id, email;
  late Future<QuerySnapshot<Object?>> userData;

  Future<void> getTheSharedPref() async {
    final startTime = DateTime.now();

    Member user = Member(id: '', name: '', email: '');

    // Keep checking every 100ms until data is available or timeout (e.g. 5 seconds)
    while ((user.id.isEmpty || user.name.isEmpty) &&
          DateTime.now().difference(startTime).inSeconds < 5) {
      await Future.delayed(Duration(milliseconds: 100));
      user = await SharedpreferenceHelper().getUser();
    }

    //print("User: ${user.id}, ${user.name}, ${user.email}");

    if (!mounted) return;

    if (user.id.isEmpty || user.name.isEmpty) {
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      setState(() {
        id = user.id;
        name = user.name;
        email = user.email;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore
    //UserAuthData().getUserData(email);

    //print(userData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTheSharedPref();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Welcome, ${name ?? ""}', style: const TextStyle(color: Colors.black)),
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
                  _buildServiceTile(Icons.book_online, "Appointment", () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (_) => const Appointment()),
                    // );
                  }),
                  _buildServiceTile(Icons.people_alt, "Members", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MemberListPage()),
                    );
                  }),                  
                  _buildServiceTile(Icons.chat_bubble_outline, "Community Wall", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WallPage()),
                    );
                  }),
                  _buildServiceTile(Icons.more_horiz, "More"),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        context: context, // pass context into the widget
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
