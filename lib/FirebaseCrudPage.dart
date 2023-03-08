import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCRUDPage extends StatefulWidget {
  @override
  _FirebaseCRUDPageState createState() => _FirebaseCRUDPageState();
}

class _FirebaseCRUDPageState extends State<FirebaseCRUDPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  // Create operation
  Future<void> addUser() {
    return users
        .add({
      'name': _nameController.text,
      'age': int.parse(_ageController.text)
    })
        .then((value) => print('User added'))
        .catchError((error) => print('Failed to add user: $error'));
  }

  // Read operation
  StreamBuilder<QuerySnapshot> buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name']),
              subtitle: Text(data['age'].toString()),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => deleteUser(document.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Update operation
  Future<void> updateUser(String id) {
    return users
        .doc(id)
        .update({'name': _nameController.text, 'age': int.parse(_ageController.text)})
        .then((value) => print('User updated'))
        .catchError((error) => print('Failed to update user: $error'));
  }

  // Delete operation
  Future<void> deleteUser(String id) {
    return users
        .doc(id)
        .delete()
        .then((value) => print('User deleted'))
        .catchError((error) => print('Failed to delete user: $error'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase CRUD Operations'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: _nameController,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Age'),
              controller: _ageController,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: addUser,
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: () => updateUser('USER_ID'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Users', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Expanded(
              child: buildUserList(),
            ),
          ],
        ),
      ),
    );
  }
}
