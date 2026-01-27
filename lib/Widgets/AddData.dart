import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void addData()async{
    String user=usernameController.text;
    String pass=passwordController.text;
    if(user.isEmpty || pass.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Required")));
    }
    else{
      await FirebaseFirestore.instance.collection("Users").doc(user.toString()).set({
        "Username":user.toString(),
        "Password":pass.toString()
      }).then((value){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inserted")));
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login UI"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: (){
              addData();
            }, child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}
