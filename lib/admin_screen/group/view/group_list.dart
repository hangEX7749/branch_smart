import 'package:branch_comm/admin_screen/group/view/create_group.dart';
import 'package:branch_comm/admin_screen/group/view/edit_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:branch_comm/model/group_model.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final GroupService _groupService = GroupService();
  String selectedStatus = 'All';

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final TextEditingController _dateRangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Groups")),
      body: Column(
        children: [
          // Status and date filter dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: Group.statusFilterOptions.keys.map((label) {
                      return DropdownMenuItem(
                        value: label,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) => setState(
                      () => selectedStatus = value ?? Group.allStatusLabel
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dateRangeController,
                    decoration: InputDecoration(
                      labelText: 'Date Range',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _pickDateRange,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildGroupList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroup()),
          );
        },
        tooltip: 'Add New Group',
        child: const Icon(Icons.add),
      ),
    );
  }

Widget _buildGroupList() {
  return StreamBuilder<QuerySnapshot>(
    stream: _groupService.getGroupsStream(
      selectedStatus,
      _selectedStartDate,
      _selectedEndDate,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No groups found.'));
      }

      final groups = snapshot.data!.docs
          .map((doc) => Group.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                group.groupName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (group.description != null && group.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        group.description!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    "Status: ${Group.statusCodeToName(group.status ?? Group.unknown)}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'Edit') {
                    //print(group.toJson());
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditGroup(groupId: group.id),
                      ),
                    );
                  } else if (value == 'Delete') {
                    _deleteGroupById(group.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Edit', child: Text('Edit')),
                  PopupMenuItem(value: 'Delete', child: Text('Delete')),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ),
          );
        },
      );
    },
  );
}

//delete group by id
Future<void> _deleteGroupById(String groupId) async {
  try {
    final proceed = await _groupService.deleteGroupById(groupId);

    if (!mounted) return;

    if (!proceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete group'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group deleted successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting group: $e')),
    );
  }
}

void _pickDateRange() async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    initialDateRange: DateTimeRange(
      start: _selectedStartDate ?? DateTime.now(),
      end: _selectedEndDate ?? DateTime.now().add(const Duration(days: 7)),
    ),
  );

  if (picked != null) {
    setState(() {
      _selectedStartDate = picked.start;
      _selectedEndDate = picked.end;
      _dateRangeController.text = 
        '${DateFormat('yyyy-MM-dd').format(_selectedStartDate!)} - '
        '${DateFormat('yyyy-MM-dd').format(_selectedEndDate!)}';
    });
  }
}
}