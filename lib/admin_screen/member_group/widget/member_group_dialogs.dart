import 'package:flutter/material.dart';
import 'package:branch_comm/model/member_group_model.dart';
import 'package:branch_comm/services/database/member_group_service.dart';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:branch_comm/admin_screen/member_group/utils/member_group_helpers.dart';

class MemberGroupDialogs {
  static void showStatusChangeConfirmation(
    BuildContext context, {
    required String docId,
    required int currentStatus,
    required int newStatus,
    required Map<String, dynamic> group,
    required MemberGroupService memberGroupService,
  }) {
    if (currentStatus == newStatus) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to change the status?'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('From: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: MemberGroupHelpers.getStatusColor(currentStatus),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    MemberGroupHelpers.getStatusText(currentStatus),
                    style: TextStyle(color: Colors.white,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('To: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: MemberGroupHelpers.getStatusColor(newStatus),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    MemberGroupHelpers.getStatusText(newStatus),
                    style: TextStyle(color: Colors.white,),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              MemberGroupHelpers.updateMemberGroupStatus(
                docId: docId,
                newStatus: newStatus,
                memberGroupService: memberGroupService,
                context: context,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MemberGroupHelpers.getStatusColor(newStatus),
            ),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void showStatusChangeDialog(
    BuildContext context, {
    required String docId,
    required int currentStatus,
    required Map<String, dynamic> group,
    required MemberGroupService memberGroupService,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Member Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new status:'),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.hourglass_empty, color: Colors.orange),
              title: const Text('Pending'),
              onTap: () {
                Navigator.of(context).pop();
                showStatusChangeConfirmation(
                  context,
                  docId: docId,
                  currentStatus: currentStatus,
                  newStatus: MemberGroup.pending,
                  group: group,
                  memberGroupService: memberGroupService,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Active'),
              onTap: () {
                Navigator.of(context).pop();
                showStatusChangeConfirmation(
                  context,
                  docId: docId,
                  currentStatus: currentStatus,
                  newStatus: MemberGroup.active,
                  group: group,
                  memberGroupService: memberGroupService,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: const Text('Rejected'),
              onTap: () {
                Navigator.of(context).pop();
                showStatusChangeConfirmation(
                  context,
                  docId: docId,
                  currentStatus: currentStatus,
                  newStatus: MemberGroup.rejected,
                  group: group,
                  memberGroupService: memberGroupService,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static void showMemberGroupDetails(
    BuildContext context, {
    required Map<String, dynamic> group,
    required String groupId,
    required String userId,
    required String docId,
    required UserService userService,
    required GroupService groupService,
    required MemberGroupService memberGroupService,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Member Group Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<String?>>(
              future: Future.wait([
                groupService.getGroupNameById(groupId),
                userService.getUserNameById(userId),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final groupName = snapshot.data?[0] ?? 'Unknown Group';
                final userName = snapshot.data?[1] ?? 'Unknown User';
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Group: $groupName'),
                    Text('Group ID: $groupId'),
                    const SizedBox(height: 8),
                    Text('Member: $userName'),
                    Text('User ID: $userId'),
                    const SizedBox(height: 8),
                    Text('Status: ${MemberGroupHelpers.getStatusText(group['status'])}'),
                    if (group['joined_at'] != null)
                      Text('Joined: ${group['joined_at'].toDate()}'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              showStatusChangeDialog(
                context,
                docId: docId,
                currentStatus: group['status'],
                group: group,
                memberGroupService: memberGroupService,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white
            ),
            child: const Text('Change Status'),
          ),
        ],
      ),
    );
  }
}