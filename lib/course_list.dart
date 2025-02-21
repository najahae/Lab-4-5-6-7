import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseList extends StatefulWidget {
  @override
  _CourseListState createState() => _CourseListState();
}

class _CourseListState extends State<CourseList> {
  List<String> selectedCourses = [];
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _ensureIsActiveField();
  }

  void _ensureIsActiveField() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('courses').get();
    for (var doc in snapshot.docs) {
      if (!doc.exists || doc.data() == null) continue;
      var data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('is_active')) {
        await doc.reference.update({'is_active': true});
      }
    }
  }

  void _toggleSelectionMode(String courseId) {
    setState(() {
      isSelectionMode = true;
      if (selectedCourses.contains(courseId)) {
        selectedCourses.remove(courseId);
        if (selectedCourses.isEmpty) isSelectionMode = false;
      } else {
        selectedCourses.add(courseId);
      }
    });
  }

  void _deleteSelectedCourses() {
    for (String courseId in selectedCourses) {
      FirebaseFirestore.instance.collection('courses').doc(courseId).delete();
    }
    setState(() {
      selectedCourses.clear();
      isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Selected courses deleted"),
          backgroundColor: Colors.red),
    );
  }

  void _deleteCourse(String courseId) {
    FirebaseFirestore.instance.collection('courses').doc(courseId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Course deleted"), backgroundColor: Colors.red),
    );
  }

  void _temporaryDeleteCourse(String courseId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({'is_active': false});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Course temporarily deleted"),
          backgroundColor: Colors.orange),
    );
  }

  void _restoreCourse(String courseId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({'is_active': true});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Course restored successfully"),
          backgroundColor: Colors.green),
    );
  }

  void _editCourse(
      BuildContext context, String courseId, Map<String, dynamic> courseData) {
    TextEditingController nameController =
        TextEditingController(text: courseData['course_name']);
    TextEditingController codeController =
        TextEditingController(text: courseData['course_code']);
    TextEditingController classController =
        TextEditingController(text: courseData['class']);
    TextEditingController lecturerController =
        TextEditingController(text: courseData['lecturer_name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Course"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Course Name")),
            TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: "Course Code")),
            TextField(
                controller: classController,
                decoration: InputDecoration(labelText: "Class")),
            TextField(
                controller: lecturerController,
                decoration: InputDecoration(labelText: "Lecturer Name")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .update({
                'course_name': nameController.text,
                'course_code': codeController.text,
                'class': classController.text,
                'lecturer_name': lecturerController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Course updated successfully"),
                    backgroundColor: Colors.green),
              );
            },
            child: Text("Save", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Course List"),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (isSelectionMode)
            IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: _deleteSelectedCourses),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          var courses = snapshot.data!.docs;

          if (courses.isEmpty)
            return Center(
                child:
                    Text("No courses found!", style: TextStyle(fontSize: 18)));

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var course = courses[index];
              bool isActive = course['is_active'] ?? true;
              bool isSelected = selectedCourses.contains(course.id);

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  onLongPress: () => _toggleSelectionMode(course.id),
                  onTap: () => _toggleSelectionMode(course.id),
                  title: Text(
                    course['course_name'],
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black : Colors.grey),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Course Code: ${course['course_code']}",
                          style: TextStyle(fontSize: 14)),
                      Text("Class: ${course['class']}",
                          style: TextStyle(fontSize: 14)),
                      Text("Lecturer: ${course['lecturer_name']}",
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isActive)
                        IconButton(
                            icon: Icon(Icons.restore, color: Colors.green),
                            onPressed: () => _restoreCourse(course.id)),
                      IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editCourse(context, course.id,
                              course.data() as Map<String, dynamic>)),
                      IconButton(
                          icon:
                              Icon(Icons.visibility_off, color: Colors.orange),
                          onPressed: () => _temporaryDeleteCourse(course.id)),
                      IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCourse(course.id)),
                    ],
                  ),
                  selected: isSelected,
                  selectedTileColor: Colors.grey[300],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
