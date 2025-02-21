import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubList extends StatefulWidget {
  @override
  _ClubListState createState() => _ClubListState();
}

class _ClubListState extends State<ClubList> {
  List<String> selectedClubs = [];
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _ensureIsActiveField();
  }

  void _ensureIsActiveField() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('clubs').get();
    for (var doc in snapshot.docs) {
      if (!doc.exists || doc.data() == null) continue;
      var data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('is_active')) {
        await doc.reference.update({'is_active': true});
      }
    }
  }

  void _toggleSelectionMode(String clubId) {
    setState(() {
      isSelectionMode = true;
      if (selectedClubs.contains(clubId)) {
        selectedClubs.remove(clubId);
        if (selectedClubs.isEmpty) isSelectionMode = false;
      } else {
        selectedClubs.add(clubId);
      }
    });
  }

  void _deleteSelectedClubs() {
    for (String clubId in selectedClubs) {
      FirebaseFirestore.instance.collection('clubs').doc(clubId).delete();
    }
    setState(() {
      selectedClubs.clear();
      isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Selected clubs deleted"), backgroundColor: Colors.red),
    );
  }

  void _deleteClub(String clubId) {
    FirebaseFirestore.instance.collection('clubs').doc(clubId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Club deleted"), backgroundColor: Colors.red),
    );
  }

  void _temporaryDeleteClub(String clubId) async {
    await FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubId)
        .update({'is_active': false});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Club temporarily deleted"),
          backgroundColor: Colors.orange),
    );
  }

  void _restoreClub(String clubId) async {
    await FirebaseFirestore.instance
        .collection('clubs')
        .doc(clubId)
        .update({'is_active': true});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Club restored successfully"),
          backgroundColor: Colors.green),
    );
  }

  void _editClub(
      BuildContext context, String clubId, Map<String, dynamic> clubData) {
    TextEditingController nameController =
        TextEditingController(text: clubData['club_name']);
    TextEditingController descriptionController =
        TextEditingController(text: clubData['description']);
    TextEditingController presidentController =
        TextEditingController(text: clubData['president_name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Club"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Club Name")),
            TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description")),
            TextField(
                controller: presidentController,
                decoration: InputDecoration(labelText: "President")),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('clubs')
                  .doc(clubId)
                  .update({
                'club_name': nameController.text,
                'description': descriptionController.text,
                'president_name': presidentController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Club updated successfully"),
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
        title: Text("Club List"),
        backgroundColor: const Color.fromARGB(255, 95, 124, 175),
        actions: [
          if (isSelectionMode)
            IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: _deleteSelectedClubs),
        ],
      ),
      body: Container(
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            var clubs = snapshot.data!.docs;

            if (clubs.isEmpty)
              return Center(
                  child:
                      Text("No clubs found!", style: TextStyle(fontSize: 18)));

            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: clubs.length,
              itemBuilder: (context, index) {
                var club = clubs[index];
                bool isActive = club['is_active'] ?? true;
                bool isSelected = selectedClubs.contains(club.id);

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    onLongPress: () => _toggleSelectionMode(club.id),
                    onTap: () => _toggleSelectionMode(club.id),
                    title: Text(
                      club['club_name'],
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black : Colors.grey),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Description: ${club['description']}",
                            style: TextStyle(fontSize: 14)),
                        Text("President: ${club['president_name']}",
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isActive)
                          IconButton(
                              icon: Icon(Icons.restore, color: Colors.green),
                              onPressed: () => _restoreClub(club.id)),
                        IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editClub(context, club.id,
                                club.data() as Map<String, dynamic>)),
                        IconButton(
                            icon: Icon(Icons.visibility_off,
                                color: Colors.orange),
                            onPressed: () => _temporaryDeleteClub(club.id)),
                        IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteClub(club.id)),
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
      ),
    );
  }
}
