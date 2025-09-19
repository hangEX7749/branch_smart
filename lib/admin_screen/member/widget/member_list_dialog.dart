import 'package:branch_comm/model/member_model.dart';
import 'package:branch_comm/utils/helpers/member_helpers.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/services/database/user_service.dart';

class MemberListDialog {
  static void showMemberListDialog(
    BuildContext context, {
    required String groupId,
    required List<String> members,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Member List'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(members[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Status update dialog
static void showStatusUpdateDialog(
  BuildContext context, {
  required String docId,
  required int currentStatus,
  required UserService userService,
}) {
  int? selectedStatus = currentStatus;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Member Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Status: ${MemberHelpers.getStatusText(currentStatus)}',
                ),
                const SizedBox(height: 10),
                DropdownButton<int>(
                  value: selectedStatus,
                  items: Member.statusOptions.map((status) {
                    return DropdownMenuItem<int>(
                      value: status['value'] as int,
                      child: Text(status['label'] as String),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedStatus != null &&
                      selectedStatus != currentStatus) {
                    MemberHelpers.updateMemberStatus(
                      docId: docId,
                      newStatus: selectedStatus!,
                      userService: userService,
                      context: context,
                    );
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );
}

//delete dialog
static void showDeleteMemberDialog(
  BuildContext context, {
  required String userId,
  required VoidCallback onDeleteConfirmed,
  required UserService userService,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Member'),
      content: Text('Are you sure you want to delete this user?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final proceed = await userService.deleteUser(userId);
            onDeleteConfirmed();
            if (context.mounted) {
              if (proceed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User deleted successfully'),
                    backgroundColor: Colors.green
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error deleting user'),
                    backgroundColor: Colors.red
                  ),
                );
              }
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
}