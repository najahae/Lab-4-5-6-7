import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studentIDController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.uid)
          .get();

      if (userData.exists) {
        setState(() {
          nameController.text = userData['name'];
          studentIDController.text = userData['student_id'];
          emailController.text = userData['email'];
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate() && user != null) {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.uid)
          .update({
        'name': nameController.text,
        'student_id': studentIDController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")));
    }
  }

  Future<void> _deleteProfile() async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.uid)
          .delete();
      await user!.delete();
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 95, 124, 175),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => _deleteProfile(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity, // Ensures full-screen background
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
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) => value!.isEmpty ? "Enter name" : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: studentIDController,
                    decoration: InputDecoration(
                      labelText: "Student ID",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter Student ID" : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Update Profile",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
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
