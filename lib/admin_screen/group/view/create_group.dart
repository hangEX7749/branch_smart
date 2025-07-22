import 'package:branch_comm/model/group_model.dart';
import 'package:branch_comm/services/admin_shared_pref.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final _formKey = GlobalKey<FormState>();
  final GroupService _groupService = GroupService();

  String groupName = '';
  String groupDescription = '';
  bool isLoading = false;

  String adminId = '';

  @override
  void initState() {
    super.initState();
    _loadAdminId();
    //print("Admin ID: $adminId");
  }

  Future<void> _loadAdminId() async {
    final admin = await AdminSharedPreferenceHelper().getAdmin();
    if (mounted) {
      setState(() {
        adminId = admin['id'] ?? '';
      });
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {

      final groupData = {
        'id': FirebaseFirestore.instance.collection('groups').doc().id,
        'iid': adminId, // admin id who initiated
        'group_name': groupName.trim(),
        'status': Group.inactive,
        'description': groupDescription.trim(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      final proceed = await _groupService.addGroup(groupData);
      if (mounted) {
        if (!proceed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create group')),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('New group created successfully'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error creating group: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a group name' : null,
                onChanged: (value) => groupName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Group Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                onChanged: (value) => groupDescription = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _createGroup,
                child: isLoading ? const CircularProgressIndicator() : const Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}