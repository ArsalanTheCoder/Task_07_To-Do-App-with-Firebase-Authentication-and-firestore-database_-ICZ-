import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyTodoApp extends StatefulWidget {
  @override
  State<MyTodoApp> createState() => _MyTodoAppState();
}

class _MyTodoAppState extends State<MyTodoApp> {
  TextEditingController itemController = TextEditingController();
  List<Map<String, dynamic>> itemList = []; // This is a list where we store our items locally

  final CollectionReference tasksCollection =
  FirebaseFirestore.instance.collection('tasks'); // Firestore collection reference

  void AddDataIntoList() async {
    // This is a method in which we store data into Firestore
    String item = itemController.text.trim();
    if (item.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill the field!",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    try {
      await tasksCollection.add({"task": item, "isChecked": false}); // Add task to Firestore
      Fluttertoast.showToast(
        msg: "Task added successfully!",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      itemController.clear();
      loadTasks();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to add task: $e",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> loadTasks() async {
    // Retrieve tasks from Firestore
    try {
      QuerySnapshot snapshot = await tasksCollection.get();
      setState(() {
        itemList = snapshot.docs.map((doc) {
          return {
            "id": doc.id,
            "task": doc["task"],
            "isChecked": doc["isChecked"],
          };
        }).toList();
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load tasks: $e",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> updateTask(String id, bool isChecked) async {
    // Update task's isChecked status in Firestore
    try {
      await tasksCollection.doc(id).update({"isChecked": isChecked});
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update task: $e",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> deleteTask(String id) async {
    // Delete task from Firestore
    try {
      await tasksCollection.doc(id).delete();
      Fluttertoast.showToast(
        msg: "Task removed successfully!",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      loadTasks();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to delete task: $e",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Todo App",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          elevation: 5,
        ),
        backgroundColor: Colors.lightBlue[50],
        body: Column(
          children: [
            SizedBox(height: 35),
            Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextField(
                      controller: itemController,
                      decoration: InputDecoration(
                        labelText: "Enter Item",
                        labelStyle: TextStyle(color: Colors.indigo),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: AddDataIntoList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                  child: Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.indigo,
                  height: 1,
                  width: 100,
                ),
                Text(
                  "   Todo List   ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  color: Colors.indigo,
                  height: 1,
                  width: 100,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        itemList[index]["task"],
                        style: TextStyle(
                          fontSize: 18,
                          decoration: itemList[index]["isChecked"]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: itemList[index]["isChecked"],
                        onChanged: (bool? value) {
                          setState(() {
                            itemList[index]["isChecked"] = value!;
                            updateTask(itemList[index]["id"], value);
                          });
                        },
                        activeColor: Colors.indigo,
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => deleteTask(itemList[index]["id"]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
