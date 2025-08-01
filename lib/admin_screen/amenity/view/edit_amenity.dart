import 'package:branch_comm/model/amenity_model.dart';
import 'package:branch_comm/screen/home_page/utils/index.dart';
import 'package:branch_comm/services/database/amenity_service.dart';

class EditAmenity extends StatefulWidget {
  const EditAmenity({super.key, required this.amenityId});
  final String amenityId;

  @override
  State<EditAmenity> createState() => _EditAmenityState();
}

class _EditAmenityState extends State<EditAmenity> {
  final _formKey = GlobalKey<FormState>();
  final AmenityService _amenityService = AmenityService();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _maxController = TextEditingController();

  String amenityName = '';
  String description = '';
  int status = Amenity.unknown; // Default to inactive
  int maxCapacity = 0; // Default value, can be changed later
  bool isLoading = false;
  bool isFetching = true;

  @override
  void initState() {
    super.initState();
    _loadAmenityData();
  }

  Future<void> _loadAmenityData() async {
    final data = await _amenityService.getAmenityById(widget.amenityId);
    if (data != null) {
      setState(() {
        amenityName = data['amenity_name'] ?? '';
        description = data['description'] ?? '';
        maxCapacity = (data['max_capacity'] ?? 0) as int;
        status = data['status'] ?? Amenity.unknown;
        isFetching = false;

        _nameController.text = amenityName;
        _descController.text = description;
        _maxController.text = maxCapacity.toString();

      });
    } else {
      // Handle not found
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Amenity not found.'),
            backgroundColor: Colors.red,),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Amenity")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Amenity Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                onChanged: (value) => amenityName = value,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (value) => description = value,
              ),
              //int max capacity field
              TextFormField(
                controller: _maxController,
                decoration: const InputDecoration(labelText: 'Max Capacity'),
                keyboardType: TextInputType.number,
                onChanged: (value) => maxCapacity = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _editAmenity,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Edit Amenity'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editAmenity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final proceed = await _amenityService.updateAmenity(widget.amenityId, {
      'amenity_name': amenityName,
      'description': description,
      'max_capacity': maxCapacity,
      'updated_at': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    setState(() => isLoading = false);

    if (!proceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update amenity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    //Navigator.pop(context); //will redirect to the previous screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Amenity updated successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}