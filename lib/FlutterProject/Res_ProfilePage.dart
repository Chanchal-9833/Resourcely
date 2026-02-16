import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class ResProfilepage extends StatefulWidget {
  const ResProfilepage({super.key});

  @override
  State<ResProfilepage> createState() => _ResProfilepageState();
}

class _ResProfilepageState extends State<ResProfilepage> {
  String uname="";
  final fullname=TextEditingController();
  final email=TextEditingController();
  final password=TextEditingController();

  // String num="";
  // void delete_user_account(){
  //
  // }
  void get_username()async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      uname=prefs.getString("username")??"User";
      fullname.text=uname;
      // uname=unm;

    });
  }
  void get_email_pass()async{
    final user=FirebaseAuth.instance.currentUser;
    final doc=await FirebaseFirestore.instance.collection("Users").doc(user!.uid).get();
    // final preffs=await SharedPreferences.getInstance();
    // String? em=preffs.getString("email");
    email.text=doc["email"];
    // password.text=doc["password"];

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_email_pass();
    get_username();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$uname's Profile ",
          style: const TextStyle(fontSize: 18, fontFamily: "Mono",fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(60),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                child: Text(
                  uname.isNotEmpty ? uname[0].toUpperCase() : "U",
                style: TextStyle(fontSize: 50),),radius: 50,
              ),
            ),
            SizedBox(height: 15),
           TextField(
             readOnly: true,
             controller: fullname,
             style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,fontFamily: "Mono",),
             decoration: InputDecoration(
               floatingLabelStyle: TextStyle(fontSize: 15),
               labelText: "fullname",
               floatingLabelBehavior: FloatingLabelBehavior.always,
               suffixIcon: Icon(Icons.arrow_forward,size: 17,)

             ),
           ),
            SizedBox(height: 20,),
            TextField(
              readOnly: true,
              controller: email,
              style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,fontFamily: "Mono"),
              decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(fontSize: 15),
                  labelText: "email",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: Icon(Icons.email,size: 17,)

              ),
            ),
            SizedBox(height: 20,),
            TextField(
              readOnly: true,
              onTap: (){
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Reset Password"),
                    content: Text("Do you want to reset your password?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("No",style: TextStyle(color: Color(0xFF00796B)),),
                      ),
                      TextButton(
                        onPressed: () async{
                          final mail = email.text.trim();

                          if (mail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Please enter your email"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Password reset link sent",style: TextStyle(color: Colors.white,fontFamily: "Mono",fontSize: 16,),),
                                backgroundColor:Colors.green,behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } on FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(e.message ?? "Failed to send link"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          // YES logic
                        },
                        child: Text("Yes",style:TextStyle(color: Color(0xFF00796B)),),
                      ),
                    ],
                  ),
                );

                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration:Duration(seconds: 1),content: Text("Want To Reset Password ?",
                //   style: TextStyle(fontWeight:FontWeight.w500,fontSize: 18,fontFamily: "Mono"),)
                //   ,behavior: SnackBarBehavior.floating,backgroundColor:Color(0xFF00796B),action: SnackBarAction(label: "Yes",
                //       textColor: Colors.white,
                //       onPressed: ()async{
                //   final mail = email.text.trim();
                //
                //   if (mail.isEmpty) {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text("Please enter your email"),
                //         behavior: SnackBarBehavior.floating,
                //       ),
                //     );
                //     return;
                //   }
                //   try {
                //     await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
                //
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text("Password reset link sent"),
                //         behavior: SnackBarBehavior.floating,
                //       ),
                //     );
                //   } on FirebaseAuthException catch (e) {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text(e.message ?? "Failed to send link"),
                //         behavior: SnackBarBehavior.floating,
                //       ),
                //     );
                //   }
                // }),),);
              },
              style: TextStyle(fontWeight: FontWeight.w500,fontSize: 17,fontFamily: "Mono"),
              decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(fontSize: 15),
                  labelText: "password",
                  hintText: "********",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: Icon(Icons.pin_rounded,size: 17,)

              ),
            ),
            SizedBox(height: 30,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(style:ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                padding: WidgetStatePropertyAll(EdgeInsets.all(16))
              ),
    onPressed: (){}, child: Text("Delete Account ?",style: TextStyle(fontSize: 18,fontFamily: "Mono",fontWeight: FontWeight.w600),)),
            )

            // SizedBox(height: 30,),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton( style: ElevatedButton.styleFrom(
            //     foregroundColor: Colors.white,
            //     backgroundColor: const Color(0xFF00796B),
            //     padding: const EdgeInsets.symmetric(vertical: 20),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),onPressed: (){
            //
            //   }, child:Text("Update",style: TextStyle(fontFamily: "Mono",fontSize: 18,fontWeight: FontWeight.w500),)),
            // )
          ],
        ),
      ),
    );
  }
}
