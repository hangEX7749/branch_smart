import 'package:branch_comm/screen/member_page/utils/index.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';

class MemberListPage extends StatefulWidget {
  final String? groupId;
  const MemberListPage({super.key, this.groupId});

  @override
  State<MemberListPage> createState() => _MemberListState();
}
class _MemberListState extends State<MemberListPage> {
  final UserService userService = UserService();
  
  final TextEditingController _searchNameController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchNameController.addListener(() {
      setState(() {
        _searchQuery = _searchNameController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const CustomAppBar(title: 'Member List'),
      body: Column(
        children: [
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchNameController,
              decoration: InputDecoration(
                hintText: "Search by name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: userService.getAllUsersByGroupId(widget.groupId ?? ""),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
            
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No members found"));
                }
            
                final members = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();
            
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo,
                          child: Text(
                            member['name'] != null && member['name'].isNotEmpty
                                ? member['name'][0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(member['name'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member['phone'] ?? 'No Phone'),
                            Text(member['email'] ?? 'No Email'),
                          ],
                        ),
                        // trailing: IconButton(
                        //   icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        //   onPressed: () {
                        //     // Navigate to member details or perform an action
                        //     Navigator.pushNamed(context, '/memberDetails', arguments: member);
                        //   },
                        // ),
                        onTap: () {
                          // Add optional details navigation or dialog here
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Floating action button to add a new member
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add member page
          Navigator.pushNamed(context, '/addMember', arguments: widget.groupId);
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
