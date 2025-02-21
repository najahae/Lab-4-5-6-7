import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseForm extends StatefulWidget {
  @override
  _CourseFormState createState() => _CourseFormState();
}

class _CourseFormState extends State<CourseForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController courseCodeController = TextEditingController();
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController lecturerNameController = TextEditingController();

  void _addCourse() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('courses').add({
        'course_code': courseCodeController.text,
        'course_name': courseNameController.text,
        'class': classController.text,
        'lecturer_name': lecturerNameController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear fields after submitting
      courseCodeController.clear();
      courseNameController.clear();
      classController.clear();
      lecturerNameController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Course registered successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course Registration"),
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
                    "Enter Course Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Course Code Input
                  TextFormField(
                    controller: courseCodeController,
                    decoration: InputDecoration(
                      labelText: "Course Code",
                      prefixIcon: Icon(Icons.code, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter course code" : null,
                  ),
                  SizedBox(height: 15),

                  // Course Name Input
                  TextFormField(
                    controller: courseNameController,
                    decoration: InputDecoration(
                      labelText: "Course Name",
                      prefixIcon: Icon(Icons.book, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter course name" : null,
                  ),
                  SizedBox(height: 15),

                  // Class Input
                  TextFormField(
                    controller: classController,
                    decoration: InputDecoration(
                      labelText: "Class",
                      prefixIcon: Icon(Icons.class_, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter class" : null,
                  ),
                  SizedBox(height: 15),

                  // Lecturer Name Input
                  TextFormField(
                    controller: lecturerNameController,
                    decoration: InputDecoration(
                      labelText: "Lecturer Name",
                      prefixIcon: Icon(Icons.person, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter lecturer name" : null,
                  ),
                  SizedBox(height: 25),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addCourse,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        "Submit",
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
