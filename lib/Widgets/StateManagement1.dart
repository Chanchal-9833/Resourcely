import "package:flutter/material.dart";
import "package:flutter_firebase/Widgets/CounterProvider.dart";
import "package:provider/provider.dart";

class Statemanagement1 extends StatelessWidget {
  const Statemanagement1({super.key});

  // int count=0;

  @override

  Widget build(BuildContext context) {
    print("Main build");
    return Scaffold(
        appBar: AppBar(title: Text("Phone Authentication.",style:TextStyle(fontSize: 20) ),backgroundColor: Colors.green.shade300,foregroundColor: Colors.white,),
        body:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<Counterprovider>(
                builder: (ctx,_,__){
                  print("Consumer build");
                  return Center(
                    // child: Text("${Provider.of<Counterprovider>(ctx,listen: true).getCount()}"),
                      child:Text("${ctx.watch<Counterprovider>().getCount()}")
                  );
                }


            ),
            SizedBox(height:20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                FloatingActionButton(onPressed: (){
                  Provider.of<Counterprovider>(context,listen:false).Increment();
                },child: Icon(Icons.add),),
                SizedBox(width: 20,),
                FloatingActionButton(onPressed: (){
                  Provider.of<Counterprovider>(context,listen:false).Decrement();
                },child:Text("-",style: TextStyle(fontSize: 30),))
              ],
            ),

          ],
        )
    );
  }
}