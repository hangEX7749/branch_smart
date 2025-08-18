import 'package:branch_comm/admin_screen/member/widget/member_list_dialog.dart';
import 'package:branch_comm/model/member_model.dart';
import 'package:branch_comm/utils/helpers/member_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/services/database/user_service.dart';

class MemberList extends StatefulWidget {
  const MemberList({super.key});

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  final UserService _userService = UserService();
  final TextEditingController _searchNameController = TextEditingController();
  String _searchQuery = "";
  String selectedStatus = Member.allStatusLabel;

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
      appBar: AppBar(title: const Text("Manage Members")),
      body: Column(
        children: [
          //name search field
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
          // Status filter dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              items: Member.statusFilterOptions.keys.map((label) {
                return DropdownMenuItem(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) => setState(
                () => selectedStatus = value ?? Member.allStatusLabel
              ),
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _userService.getAllUsers(),
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
                
                // Filter members based on search query and selected status
                final filteredMembers = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final status = data['status']?.toString() ?? '';
                  
                  // Check if name matches search query
                  final matchesName = name.contains(_searchQuery);
                  
                  // Check if status matches selected status or is null
                  final matchesStatus = selectedStatus == Member.allStatusLabel ||
                      (status.isNotEmpty && status == Member.statusFilterOptions[selectedStatus]?.toString());
                  
                  return matchesName && matchesStatus;
                }).toList();

                return ListView.builder(
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index].data() as Map<String, dynamic>;
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
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['name'] ?? 'No Name'
                            ),
                            const SizedBox(width: 8),
                            // Display status with color and icon
                            Row(
                              children: [
                                Icon(
                                  MemberHelpers.getStatusIcon(member['status']),
                                  color: MemberHelpers.getStatusColor(member['status']),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  MemberHelpers.getStatusText(member['status']),
                                  style: TextStyle(
                                    color: MemberHelpers.getStatusColor(member['status']),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        subtitle: 
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(member['email'] ?? 'No Email'),
                              Text(member['phone'] ?? 'No Phone'),
                            ],
                          ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            // Handle menu actions
                            if (value == 'changeStatus') {
                              // Show dialog to change member status
                              MemberListDialog.showStatusUpdateDialog(
                                context,
                                docId: filteredMembers[index].id,
                                currentStatus: member['status'] ?? Member.active,
                                userService: _userService,
                              );

                            } else if (value == 'delete') {
                              // Show confirmation dialog before deleting
                              MemberListDialog.showDeleteMemberDialog(
                                context,
                                userId: member['id'],
                                onDeleteConfirmed: () {
                                  // Refresh the list after deletion
                                  setState(() {});
                                },
                                userService: _userService,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'changeStatus', child: Text('Change Status')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                      ),
                    ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}