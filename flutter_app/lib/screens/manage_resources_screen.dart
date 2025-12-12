import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageResourcesScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic> adminData;

  const ManageResourcesScreen({
    Key? key,
    required this.token,
    required this.adminData,
  }) : super(key: key);

  @override
  _ManageResourcesScreenState createState() => _ManageResourcesScreenState();
}

class _ManageResourcesScreenState extends State<ManageResourcesScreen> {
  List<dynamic> _coaches = [];
  List<dynamic> _gunNames = [];
  bool _isLoading = true;

  final _coachNameController = TextEditingController();
  final _coachSpecialtyController = TextEditingController();
  final _coachExperienceController = TextEditingController();
  final _coachRatingController = TextEditingController();

  final _gunNameController = TextEditingController();
  String _selectedWeaponType = 'Pistol';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _coachNameController.dispose();
    _coachSpecialtyController.dispose();
    _coachExperienceController.dispose();
    _coachRatingController.dispose();
    _gunNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final coachesResponse = await http.get(
        Uri.parse('http://localhost:3000/v1/resources/coaches'),
      );

      final gunNamesResponse = await http.get(
        Uri.parse('http://localhost:3000/v1/resources/gun-names'),
      );

      if (coachesResponse.statusCode == 200) {
        final data = json.decode(coachesResponse.body);
        setState(() {
          _coaches = data['coaches'] ?? [];
        });
      }

      if (gunNamesResponse.statusCode == 200) {
        final data = json.decode(gunNamesResponse.body);
        setState(() {
          _gunNames = data['gunNames'] ?? [];
        });
      }
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCoach() async {
    if (_coachNameController.text.isEmpty ||
        _coachSpecialtyController.text.isEmpty ||
        _coachExperienceController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/v1/resources/coaches'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _coachNameController.text,
          'specialization': _coachSpecialtyController.text.split(',').map((e) => e.trim()).toList(),
          'experience': int.parse(_coachExperienceController.text),
          'rating': _coachRatingController.text.isEmpty ? 4.0 : double.parse(_coachRatingController.text),
        }),
      );

      if (response.statusCode == 201) {
        _showSuccess('Coach added successfully');
        _coachNameController.clear();
        _coachSpecialtyController.clear();
        _coachExperienceController.clear();
        _coachRatingController.clear();
        _loadData();
      } else {
        final error = json.decode(response.body);
        _showError(error['message'] ?? 'Failed to add coach');
      }
    } catch (e) {
      _showError('Failed to add coach: $e');
    }
  }

  Future<void> _deleteCoach(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1e2538),
        title: Text('Delete Coach', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete $name?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/v1/resources/coaches/$id'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        _showSuccess('Coach deleted successfully');
        _loadData();
      } else {
        _showError('Failed to delete coach');
      }
    } catch (e) {
      _showError('Failed to delete coach: $e');
    }
  }

  Future<void> _addGunName() async {
    if (_gunNameController.text.isEmpty) {
      _showError('Please enter a gun name');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/v1/resources/gun-names'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _gunNameController.text,
          'weaponType': _selectedWeaponType,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccess('Gun name added successfully');
        _gunNameController.clear();
        _loadData();
      } else {
        final error = json.decode(response.body);
        _showError(error['message'] ?? 'Failed to add gun name');
      }
    } catch (e) {
      _showError('Failed to add gun name: $e');
    }
  }

  Future<void> _deleteGunName(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1e2538),
        title: Text('Delete Gun', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete $name?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/v1/resources/gun-names/$id'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        _showSuccess('Gun name deleted successfully');
        _loadData();
      } else {
        _showError('Failed to delete gun name');
      }
    } catch (e) {
      _showError('Failed to delete gun name: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF00ff88),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: Color(0xFF1a1f35),
        elevation: 0,
        title: Text(
          'Manage Resources',
          style: TextStyle(
            color: Color(0xFF00ff88),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Color(0xFF00d9ff)),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00d9ff),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coaches Section
                  _buildSectionTitle('Manage Coaches'),
                  SizedBox(height: 16),
                  _buildAddCoachForm(),
                  SizedBox(height: 24),
                  _buildCoachesList(),
                  SizedBox(height: 40),

                  // Gun Names Section
                  _buildSectionTitle('Manage Gun Names'),
                  SizedBox(height: 16),
                  _buildAddGunForm(),
                  SizedBox(height: 24),
                  _buildGunNamesList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF00ff88),
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF00ff88),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAddCoachForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1e2538),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Coach',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildTextField(_coachNameController, 'Coach Name'),
          SizedBox(height: 12),
          _buildTextField(_coachSpecialtyController, 'Specialization (comma separated)'),
          SizedBox(height: 12),
          _buildTextField(_coachExperienceController, 'Experience (years)', isNumber: true),
          SizedBox(height: 12),
          _buildTextField(_coachRatingController, 'Rating (0-5, optional)', isNumber: true),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addCoach,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00ff88),
              foregroundColor: Color(0xFF0a0e1a),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('Add Coach'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGunForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1e2538),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Gun',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildTextField(_gunNameController, 'Gun Name'),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedWeaponType,
            dropdownColor: Color(0xFF1e2538),
            decoration: InputDecoration(
              labelText: 'Weapon Type',
              labelStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Color(0xFF0a0e1a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white10),
              ),
            ),
            style: TextStyle(color: Colors.white),
            items: ['Pistol', 'Rifle', 'Shotgun'].map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedWeaponType = value!;
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addGunName,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00ff88),
              foregroundColor: Color(0xFF0a0e1a),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('Add Gun'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Color(0xFF0a0e1a),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white10),
        ),
      ),
    );
  }

  Widget _buildCoachesList() {
    if (_coaches.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No coaches added yet',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: _coaches.map((coach) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1e2538),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach['name'] ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Specialization: ${(coach['specialization'] as List).join(", ")}',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      'Experience: ${coach['experience']} years | Rating: ${coach['rating']}',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteCoach(coach['_id'], coach['name']),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGunNamesList() {
    if (_gunNames.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No gun names added yet',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: _gunNames.map((gun) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1e2538),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gun['name'] ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Type: ${gun['weaponType']}',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteGunName(gun['_id'], gun['name']),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
