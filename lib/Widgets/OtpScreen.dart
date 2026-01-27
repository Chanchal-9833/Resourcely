import "dart:math";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_firebase/Widgets/Homepage.dart";

class Otpscreen extends StatefulWidget {
  String verification_id;
  Otpscreen({required this.verification_id});

  @override
  State<Otpscreen> createState() => _OtpscreenState();
}

class _OtpscreenState extends State<Otpscreen> {
  final otp=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(title: Text("Phone Authentication.",style:TextStyle(fontSize: 20) ),backgroundColor: Colors.green.shade300,foregroundColor: Colors.white,),
        body:Container(
            child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      controller:otp,
                      decoration: InputDecoration(
                          labelText: "Enter Otp",
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2
                              ),
                              borderRadius: BorderRadius.circular(15)
                          )
                      ),
                    ),
                  ),
                  SizedBox(height:20),
                  ElevatedButton(style:ButtonStyle( shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                      backgroundColor: WidgetStatePropertyAll(Colors.green),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(20))
                  ),onPressed: ()async{
                    try{
                      PhoneAuthCredential Credential=await PhoneAuthProvider.credential(verificationId: widget.verification_id, smsCode:otp.text.toString());
                      FirebaseAuth.instance.signInWithCredential(Credential).then((value){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return Homepage();
                        }));
                      });
                    }
                    catch(ex){
                      print(ex);

                    }
                  }, child:Text("Verify Otp",style: TextStyle(fontSize: 20),))
                ]
            )

        )
    );
  }
}
