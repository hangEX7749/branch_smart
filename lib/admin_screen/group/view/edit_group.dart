import 'package:branch_comm/model/amenity_group_model.dart';
import 'package:branch_comm/model/group_model.dart';
import 'package:branch_comm/screen/account_page/utils/index.dart';
import 'package:branch_comm/services/database/amenity_service.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:branch_comm/services/database/amenity_group_service.dart';

class EditGroup extends StatefulWidget {
  const EditGroup({super.key, required this.groupId});
  final String groupId;

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  final _formKey = GlobalKey<FormState>();
  final GroupService _groupService = GroupService();
  final AmenityService _amenityService = AmenityService();
  final AmenityGroupService _amenityGroupService = AmenityGroupService();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String groupName = '';
  String description = '';
  int status = Group.unknown; // Default to unknown
  bool isLoading = false;
  bool isFetching = true;

  List<Map<String, dynamic>> _amenities = []; // All available amenities
  List<String> _selectedAmenityIds = []; // Selected amenity IDs

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

Future<void> _loadGroupData() async {
  final data = await _groupService.getGroupById(widget.groupId);
  final amenitySnap = await _amenityService.get();

  if (data == null) {
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group not found'), backgroundColor: Colors.red),
      );
    }
    return;
  }

  // Load group info
  groupName = data['group_name'] ?? '';
  description = data['description'] ?? '';
  status = data['status'] ?? Group.unknown;
  _nameController.text = groupName;
  _descController.text = description;

  // Load all amenities
  _amenities = amenitySnap.docs.map((doc) {
    final a = doc.data();
    return {
      'id': doc.id,
      'name': a['amenity_name'],
    };
  }).toList();

  // Load selected amenity IDs from amenity_group
  final selectedAmenitySnap = await _amenityGroupService.getAmenityGroupsByGroupId(widget.groupId);
  _selectedAmenityIds = selectedAmenitySnap.docs
      .map((doc) => doc.data()['amenity_id'] as String)
      .toList();

  setState(() {
    isFetching = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
      ),
      body: isFetching ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Group Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter group name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Amenities", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: -8,
                            children: _selectedAmenityIds.map((id) {
                              final name = _amenities.firstWhere((a) => a['id'] == id, orElse: () => {'name': 'Unknown'})['name'];
                              return Chip(label: Text(name));
                            }).toList(),
                          ),
                          TextButton(
                            onPressed: _openAmenitySelector,
                            child: const Text('Select Amenities'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading ? null : _editGroup,
                      child: isLoading ? 
                          const CircularProgressIndicator(color: Colors.white) : 
                          const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _editGroup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final proceed = await _groupService.updateGroup(widget.groupId, {
        'group_name': _nameController.text,
        'description': _descController.text,
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() => isLoading = false);
      if (proceed) {
        //Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        //update amenitiesGroup
        final amenityGroups = _selectedAmenityIds.map((amenityId) {
          return AmenityGroup(
            id: '', // Will be set by Firestore
            groupId: widget.groupId,
            amenityId: amenityId,
          ).toMap();
        }).toList();

        // Clear unselected amenities
        final existingGroups = await _amenityGroupService.getAmenityGroupsByGroupId(widget.groupId);
        final existingAmenityIds = existingGroups.docs.map((doc) => doc.data()['amenity_id'] as String).toSet();
        final unselectedAmenityIds = existingAmenityIds.difference(_selectedAmenityIds.toSet());
        for (final amenityId in unselectedAmenityIds) {
          await _amenityGroupService.clearAmenityGroupById(widget.groupId, amenityId);
        }
        
        // Add or update selected amenities
        for (final groupData in amenityGroups) {
          await _amenityGroupService.addAmenityGroup(groupData);
        }
      
      } else {
        // Handle update failure
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update group details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openAmenitySelector() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        List<String> tempSelection = [..._selectedAmenityIds];

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ..._amenities.map((a) {
                    final id = a['id'];
                    final name = a['name'];
                    final isSelected = tempSelection.contains(id);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(name),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            tempSelection.add(id);
                          } else {
                            tempSelection.remove(id);
                          }
                        });
                      },
                    );
                  }),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, tempSelection),
                    child: const Text("Done"),
                  )
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _selectedAmenityIds = result);
    }
  }
}
