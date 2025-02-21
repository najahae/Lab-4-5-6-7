import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubForm extends StatefulWidget {
  @override
  _ClubFormState createState() => _ClubFormState();
}

class _ClubFormState extends State<ClubForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController clubNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController presidentNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  void _registerClub() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('clubs').add({
        'club_name': clubNameController.text,
        'description': descriptionController.text,
        'president_name': presidentNameController.text,
        'contact_info': contactController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear fields after submitting
      clubNameController.clear();
      descriptionController.clear();
      presidentNameController.clear();
      contactController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Club registered successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Club Registration"),
        backgroundColor: const Color.fromARGB(255, 95, 124, 175),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 146, 180, 221),
              const Color.fromARGB(255, 121, 163, 226)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Register a New Club",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Club Name Input
                  TextFormField(
                    controller: clubNameController,
                    decoration: InputDecoration(
                      labelText: "Club Name",
                      prefixIcon: Icon(Icons.group, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter club name" : null,
                  ),
                  SizedBox(height: 15),

                  // Description Input
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description",
                      prefixIcon:
                          Icon(Icons.description, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter description" : null,
                  ),
                  SizedBox(height: 15),

                  // President Name Input
                  TextFormField(
                    controller: presidentNameController,
                    decoration: InputDecoration(
                      labelText: "President Name",
                      prefixIcon: Icon(Icons.person, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter president name" : null,
                  ),
                  SizedBox(height: 15),

                  // Contact Info Input
                  TextFormField(
                    controller: contactController,
                    decoration: InputDecoration(
                      labelText: "Contact Info",
                      prefixIcon: Icon(Icons.phone, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter contact info" : null,
                  ),
                  SizedBox(height: 25),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerClub,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.orange,
                      ),
                      child: Text(
                        "Register Club",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
