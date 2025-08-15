import 'package:branch_comm/admin_screen/amenity/view/create_amenity.dart';
import 'package:branch_comm/admin_screen/amenity/view/edit_amenity.dart';
import 'package:branch_comm/model/amenity_model.dart';
import 'package:branch_comm/services/database/amenity_service.dart';
import 'package:branch_comm/utils/helpers/amenity_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AmenityList extends StatefulWidget {
  const AmenityList({super.key});

  @override
  State<AmenityList> createState() => _AmenityListState();
}

class _AmenityListState extends State<AmenityList> {
  final AmenityService _amenityService = AmenityService();
  String selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Amenities")),
      body: Column(
        children: [
          // Status filter dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              items: Amenity.statusFilterOptions.keys.map((label) {
                return DropdownMenuItem(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedStatus = value ?? Amenity.allStatusLabel),
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Amenities list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _amenityService.getAllAmenities(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Apply status filter if selected
                final filteredAmenities = snapshot.data?.docs.where((doc) {
                  final status = doc['status'] as int?;
                  if (selectedStatus == Amenity.allStatusLabel) return true;
                  return Amenity.statusFilterOptions[selectedStatus] == status;
                }).toList() ?? [];

                if (filteredAmenities.isEmpty) {
                  return const Center(child: Text('No amenities found'));
                }

                return ListView.builder(
                  itemCount: filteredAmenities.length,
                  itemBuilder: (context, index) {
                    final amenity = filteredAmenities[index];

                    final status = amenity['status'] as int?;
                    final statusColor = AmenityHelpers.getStatusColor(status);
                    final statusIcon = AmenityHelpers.getStatusIcon(status);

                    return ListTile(
                      leading: Icon(statusIcon, color: statusColor),
                      title: Text(amenity['amenity_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(amenity['description'] ?? ''),
                          const SizedBox(height: 4),
                          Text("Status: ${Amenity.statusCodeToName(amenity['status'])}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'Edit') {
                            // Navigate to edit screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditAmenity(amenityId: amenity.id),
                              ),
                            );
                          } 
                          else if (value == 'Delete') {
                            // Delete amenity
                            _deleteAmenityById(amenity.id);
                          } 
                          else if (value == 'Update Status') {
                            final selected = await _showStatusSelectionDialog(context);
                            
                            if (selected != null) {
                              _updateStatus(amenity.id, selected.toString());
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                          const PopupMenuItem(value: 'Update Status', child: Text('Update Status')),
                        ],
                        icon: const Icon(Icons.more_vert),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAmenity()),
          );
        },
        tooltip: 'Add New Group',
        child: const Icon(Icons.add),
      ),
    );
  }

  //Show dialog to update amenity status
  Future<int?> _showStatusSelectionDialog(BuildContext context) async {
    return await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Status'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 10),
              child: const Text('Active'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 90),
              child: const Text('Inactive'),
            ),
          ],
        );
      },
    );
  }

  //update status of an amenity
  Future<void> _updateStatus(String amenityId, String newStatus) async {
    final status = int.tryParse(newStatus);
    if (status == null) return;

    final proceed = await _amenityService.updateAmenityStatus(amenityId, status);
    
    if (!mounted) return;
    if (!proceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update status.")),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Status updated to ${Amenity.statusCodeToName(status)}")),
    );
  }

  //delete amenity by id
  Future<void> _deleteAmenityById(String amenityId) async {
    final proceed = await _amenityService.deleteAmenityById(amenityId);
    if (!mounted) return;
    if (!proceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete amenity')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Amenity deleted successfully')),
    );
  }
}