import 'package:branch_comm/model/member_group_model.dart';
import 'package:branch_comm/screen/home_page/utils/index.dart';
import 'package:branch_comm/services/database/group_service.dart';
import 'package:branch_comm/services/database/member_group_service.dart';

class JoinGroup extends StatefulWidget {
  const JoinGroup({super.key});

  @override
  State<JoinGroup> createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  final GroupService _groupService = GroupService();
  final _formKey = GlobalKey<FormState>(); // Add form key for validation

  String? selectedGroupId;
  String? selectedGroupName;
  List<Map<String, dynamic>> availableGroups = [];
  bool isLoading = true;

  // Dummy user data — Replace with actual user info
  String? userId; // Get this from auth/sharedprefs
  String? userName; // Optional: user display name

  final MemberGroupService _memberGroupService = MemberGroupService();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchGroups();
  }

  Future<void> _loadUserId() async {
    final user = await SharedpreferenceHelper().getUser();
    if (mounted) {
      setState(() {
        userId = user.id;
      });
    }
  }

  Future<void> _fetchGroups() async {
    try {
      final groupList = await _groupService.getGroupDropdownOptions();
      setState(() {
        availableGroups = groupList;
        isLoading = false;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _submitJoinRequest() async {
    if (!_formKey.currentState!.validate()) return; // Validate form first

    try {
      final exists = await _memberGroupService.memberGroupExists(
        userId!,
        selectedGroupId!,
      );
      
      if (exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already requested to join this group.'),
            backgroundColor: Color.fromARGB(255, 255, 215, 68),
          ),
        );
        return;
      }
      
      Map<String, dynamic> memberGroupMap = {
        'id': await _memberGroupService.getNewId(),
        'user_id': userId,
        'group_id': selectedGroupId,
        'status': MemberGroup.pending,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp()
      };

      final proceed = await _memberGroupService.addMemberGroup(memberGroupMap);

      if (!mounted) return;
      if (!proceed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit join request. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Join request submitted to "$selectedGroupName". Wait Admin approval.'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          'Failed to submit request.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form( // Wrap with Form widget
                key: _formKey, // Assign the form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select a group to request to join:', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGroupId,
                      decoration: const InputDecoration(
                        labelText: 'Groups',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null ? 'Please select a group' : null, // Validation
                      items: availableGroups.map<DropdownMenuItem<String>>((group) {
                        return DropdownMenuItem<String>(
                          value: group['id'] as String,
                          child: Text(group['name'] as String),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final group = availableGroups.firstWhere((g) => g['id'] == value);
                        setState(() {
                          selectedGroupId = value;
                          selectedGroupName = group['name'];
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitJoinRequest,
                        child: const Text('Request to Join'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}