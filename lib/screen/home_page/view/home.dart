import 'package:branch_comm/screen/home_page/utils/index.dart';

//import 'package:lucide_icons/lucide_icons.dart'; // Optional for icons

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //final UserService _userService = UserService();
  final GroupService _groupService = GroupService();
  final AmenityGroupService _amenityGroupService = AmenityGroupService();
  final MemberGroupService _memberGroupService = MemberGroupService();

  String? name, id, email, userGroupId;
  late Future<QuerySnapshot<Object?>> userData;
  
  // List of user groups and their names
  List<Map<String, dynamic>> userMemberGroups = [];
  //String? selectedMemberGroupId;
  //bool isLoadingMemberGroups = true;
  
  // List of groups for dropdown (for demonstration purposes)
  List<String> groupList = [];
  String? selectedGroup;

  bool hasGroups = false;
  bool hasAmenities = false;

  Future<void> getTheSharedPref() async {
    final startTime = DateTime.now();

    Member user = Member(id: '', name: '', email: '');

    while ((user.id.isEmpty || user.name.isEmpty) &&
        DateTime.now().difference(startTime).inSeconds < 5) {
      await Future.delayed(Duration(milliseconds: 100));
      user = await SharedpreferenceHelper().getUser();
    }

    if (!mounted) return; // ✅ Prevent setState after dispose

    if (user.id.isEmpty || user.name.isEmpty) {
      Navigator.pushReplacementNamed(context, '/signin');
    } else {
      if (!mounted) return; // ✅ Double-check before setState
      setState(() {
        id = user.id;
        name = user.name;
        email = user.email;
      });

      // ✅ Call fetchMemberGroup AFTER state is updated
      await _fetchMemberGroup(user.id);
    }
  }

  Future<void> _fetchMemberGroup(String userId) async {
    try {
      final QuerySnapshot memberGroupSnapshot = await _memberGroupService.getMemberGroupByUserId(userId);

      final List<String> groupNames = [];

      for (var doc in memberGroupSnapshot.docs) {
        final String groupId = doc['group_id'];

        final DocumentSnapshot groupDoc =
            await _groupService.getUserGroupById(groupId);

        if (groupDoc.exists && groupDoc['group_name'] != null) {
          groupNames.add(groupDoc['group_name']);
        }
      }

      //to check have groups or not
      hasGroups = groupNames.isNotEmpty;

      if (!mounted) return; // ✅ Check before setState

      setState(() {
        groupList = groupNames;
        if (groupList.isNotEmpty && selectedGroup == null) {
          selectedGroup = groupList.first;
        }
      });

      // Check amenities for the first group if available
      if (groupNames.isNotEmpty) {
        final firstGroupId = memberGroupSnapshot.docs.first['group_id'];
        await _checkAmenities(firstGroupId);
      }

    } catch (e) {
      if (!mounted) return; // ✅ Prevent error UI after disposal

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load member groups: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkAmenities(String groupId) async {
    try {
      final amenitiesSnapshot = await _amenityGroupService.getAmenityGroupsByGroupId(groupId);

      setState(() {
        // Check if there are any amenities for the selected group
        if (amenitiesSnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No amenities available for this group.'),
              backgroundColor: Colors.orange,
            ),
          );
          hasAmenities = false;
          userGroupId = null;
        } else {
          hasAmenities = true;  
          userGroupId = groupId; 
        }
      });

    } catch (e) {
      //print('Error checking amenities: $e');
      setState(() {
        hasAmenities = false;
        userGroupId = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTheSharedPref();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1,
        title: Text('Welcome, ${name ?? ""}', style: const TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Group Selection Dropdown
            if (groupList.isNotEmpty)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Group',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: selectedGroup,
                items: groupList.map((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (String? newValue) async {
                  setState(() {
                    selectedGroup = newValue;
                  });

                  final groupId = await _groupService.getGroupIdFromGroupName(newValue!);
                  if (groupId == null) return;
                  await _checkAmenities(groupId);
                },
              ),
            //const SizedBox(height: 24),
            // Balance Card
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.indigo,
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: const [
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text('Wallet Balance', style: TextStyle(color: Colors.white70)),
            //           SizedBox(height: 8),
            //           Text('\$1,240.00',
            //               style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            //         ],
            //       ),
            //       Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 24),

            // Services Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  if (hasGroups) ...[
                    if (hasAmenities)
                      _buildServiceTile(Icons.calendar_today, "Book Facility", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => Booking(groupId: userGroupId!)),
                        );
                      }),
                    _buildServiceTile(Icons.book_online, "Appointment", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Appointment()),
                      );
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
                  ],
                  // Join Group - no condition
                  _buildServiceTile(Icons.group_add, "Join Group", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => JoinGroup()),
                    );
                  }),
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
