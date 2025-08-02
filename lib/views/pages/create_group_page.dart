import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quick_chat/utils/Dio/myDio.dart';

import '../../models/user.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  List<User> users = [];
  List<String> selectedUserIds = [];
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    try {
      final dio = await MyDio().getDio();
      final response = await dio.get("/users/getUsers");
      if (response.data != null) {
        List<User> fetchedUsers =
        (response.data as List).map((json) => User.fromJson(json)).toList();

        setState(() {
          users = fetchedUsers;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch users");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch users')));
    }
  }

  void createGroup() async {
    if (_groupNameController.text.isEmpty || selectedUserIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Group name and at lease two members required")));
      return;
    }

    setState(() => isLoading = true);

    final dio = await MyDio().getDio();
    final response = await dio.post('/groups/createGroup', data: {
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Group'),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _groupNameController,
                  decoration: InputDecoration(labelText: "Group Name"),
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Group name is mandatory";
                    }
                    return null;
                  },
                ),
                Expanded(
                  child: ListView(
                    children: users.map((user) {
                      return CheckboxListTile(
                          title: Text(user.name!),
                          value: selectedUserIds.contains(user.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedUserIds.add(user.id!);
                              } else {
                                selectedUserIds.remove(user.id);
                              }
                            });
                          });
                    }).toList(),
                  ),
                ),
                ElevatedButton(
                    onPressed: (){
                      if(_formKey.currentState?.validate() ?? false){
                        createGroup();
                      }
                    },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text('Create Group')),
              ],
            ),
          ),
        ));
  }
}
