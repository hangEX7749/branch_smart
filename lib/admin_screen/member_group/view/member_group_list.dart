import 'package:branch_comm/admin_screen/member_group/mixins/name_fetching_mixin.dart';
import 'package:branch_comm/admin_screen/member_group/utils/member_group_helpers.dart';
import 'package:branch_comm/admin_screen/member_group/widget/member_group_dialogs.dart';
import 'package:branch_comm/model/member_group_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:branch_comm/services/database/member_group_service.dart';

class MemberGroupList extends StatefulWidget {
  const MemberGroupList({super.key});

  @override
  State<MemberGroupList> createState() => _MemberGroupListState();
}
class _MemberGroupListState extends State<MemberGroupList> with NameFetchingMixin {
  final UserService _userService = UserService();
  final GroupService _groupService = GroupService();
  final MemberGroupService memberGroupService = MemberGroupService();

  // Filter state
  int? _selectedStatus; // null means "All"

  @override
  UserService get userService => _userService;

  @override
  GroupService get groupService => _groupService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Member Groups")),
      body: Column(
        children: [
          // --- Filter Dropdown ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text("All"),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text("All"),
                      ),
                      DropdownMenuItem(
                        value: MemberGroup.pending,
                        child: Text("Pending"),
                      ),
                      DropdownMenuItem(
                        value: MemberGroup.active,
                        child: Text("Active"),
                      ),
                      DropdownMenuItem(
                        value: MemberGroup.inactive,
                        child: Text("Inactive"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // --- Member Groups List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: memberGroupService.getAllMemberGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No member groups found"));
                }

                // Convert and apply filter
                final allGroups = snapshot.data!.docs;
                final filteredGroups = _selectedStatus == null
                    ? allGroups
                    : allGroups.where((doc) {
                        final group = doc.data() as Map<String, dynamic>;
                        return group['status'] == _selectedStatus;
                      }).toList();

                if (filteredGroups.isEmpty) {
                  return const Center(child: Text("No groups match filter"));
                }

                return ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group =
                        filteredGroups[index].data() as Map<String, dynamic>;
                    final groupId = group['group_id'] ?? '';
                    final userId = group['user_id'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: FutureBuilder<String>(
                          future: getGroupName(groupId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading group...');
                            }
                            return Text(snapshot.data ?? 'Unknown Group');
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: getUserName(userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text('Loading user...');
                                }
                                return Text(
                                    'Member: ${snapshot.data ?? 'Unknown User'}');
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'IDs: Group($groupId) | User($userId)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: MemberGroupHelpers.getStatusColor(
                                  group['status']),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: MemberGroupHelpers.getStatusColor(
                                    group['status']),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  MemberGroupHelpers.getStatusText(
                                      group['status']),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          onSelected: (String newStatus) {
                            MemberGroupDialogs.showStatusChangeConfirmation(
                              context,
                              docId: filteredGroups[index].id,
                              currentStatus: group['status'],
                              newStatus: int.parse(newStatus),
                              group: group,
                              memberGroupService: memberGroupService,
                            );
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: MemberGroup.pending.toString(),
                              child: Row(
                                children: [
                                  Icon(
                                    MemberGroupHelpers.getStatusIcon(
                                        MemberGroup.pending),
                                    color: MemberGroupHelpers.getStatusColor(
                                        MemberGroup.pending),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Pending'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: MemberGroup.active.toString(),
                              child: Row(
                                children: [
                                  Icon(
                                    MemberGroupHelpers.getStatusIcon(
                                        MemberGroup.active),
                                    color: MemberGroupHelpers.getStatusColor(
                                        MemberGroup.active),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Active'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: MemberGroup.inactive.toString(),
                              child: Row(
                                children: [
                                  Icon(
                                    MemberGroupHelpers.getStatusIcon(
                                        MemberGroup.inactive),
                                    color: MemberGroupHelpers.getStatusColor(
                                        MemberGroup.inactive),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Inactive'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          MemberGroupDialogs.showMemberGroupDetails(
                            context,
                            group: group,
                            groupId: groupId,
                            userId: userId,
                            docId: filteredGroups[index].id,
                            userService: _userService,
                            groupService: _groupService,
                            memberGroupService: memberGroupService,
                          );
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
    );
  }
}
