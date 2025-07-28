import 'package:branch_comm/model/amenity_model.dart';
import 'package:branch_comm/screen/home_page/utils/index.dart';
import 'package:branch_comm/services/database/amenity_service.dart';

class CreateAmenity extends StatefulWidget {
  const CreateAmenity({super.key});

  @override
  State<CreateAmenity> createState() => _CreateAmenityState();
}

class _CreateAmenityState extends State<CreateAmenity> {
  final _formKey = GlobalKey<FormState>();
  final AmenityService _amenityService = AmenityService();

  String amenityName = '';
  String amenityDescription = '';
  int maxCapacity = 0; // Default value, can be changed later
  bool isLoading = false;

  Future<void> _createAmenity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {

      final amenityData = {
        'id': await _amenityService.getNewId(),
        'amenity_name': amenityName.trim(),
        'max_capacity': 0, // Default value, can be changed later
        'status': Amenity.inactive,
        'description': amenityDescription.trim(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _amenityService.addAmenity(amenityData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Amenity created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating amenity: $e'),
            backgroundColor: Colors.red,),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Amenity")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amenity Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                onChanged: (value) => amenityName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (value) => amenityDescription = value,
              ),
              //int max capacity field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Max Capacity'),
                keyboardType: TextInputType.number,
                onChanged: (value) => maxCapacity = int.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _createAmenity,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create Amenity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}