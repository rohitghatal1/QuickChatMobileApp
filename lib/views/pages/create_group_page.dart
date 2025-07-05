import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  List<String> selectedUserIds = [];
  bool isLoading = false;

  void createGroup() async {
    if (_groupNameController.text.isEmpty || selectedUserIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Group name and at lease two members required")));
      return;
    }

    setState(() => isLoading = true);

    final dio = await MyDio().getDio();
    final response = await dio.post('/users/groups/create', data: {
      "groupName": _groupNameController.text,
      "participantIds": selectedUserIds,
    });

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to create group')));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> users = [];

    return Scaffold(
        appBar: AppBar(
          title: Text('Create Group'),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(labelText: "Group Name"),
              ),
              Expanded(
                child: ListView(
                  children: users.map((user) {
                    return CheckboxListTile(
                        title: Text(user['name']!),
                        value: selectedUserIds.contains(user['id']),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedUserIds.add(user['id']!);
                            } else {
                              selectedUserIds.remove(user['id']);
                            }
                          });
                        });
                  }).toList(),
                ),
              ),
              ElevatedButton(
                  onPressed: isLoading ? null : createGroup,
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Text('Create Group')),
            ],
          ),
        ));
  }
}
