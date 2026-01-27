import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter_firebase/Widgets/OtpScreen.dart";


class Phoneauth extends StatefulWidget {
  const Phoneauth({super.key});

  @override
  State<Phoneauth> createState() => _PhoneauthState();
}

class _PhoneauthState extends State<Phoneauth> {
  final phone=TextEditingController();
  void verify_phone()async{
    await FirebaseAuth.instance.verifyPhoneNumber(verificationCompleted:(PhoneAuthCredential credential){

    }, verificationFailed:(FirebaseAuthException ex){

    }, codeSent:(String verificationId,int? resend_token){
      Navigator.push(context, MaterialPageRoute(builder: (context){
        return Otpscreen(verification_id: verificationId,);
      }));
    }, codeAutoRetrievalTimeout:(String ver_id){},phoneNumber: phone.text.toString());
  }
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
                  controller:phone,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
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
              ElevatedButton(style:ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                backgroundColor: WidgetStatePropertyAll(Colors.green),
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(20),)
              ),onPressed: (){
                verify_phone();
              }, child:Text("Verify",style: TextStyle(fontSize: 20),))
            ]
        )

      )
    );
  }
}
