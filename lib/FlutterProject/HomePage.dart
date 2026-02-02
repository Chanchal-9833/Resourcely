import "package:flutter/material.dart";
import "package:flutter_firebase/FlutterProject/PcBookingPage.dart";

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 3, child: Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Builder(
          builder: (context) => Container(
            color: Color(0xFF00796B),
            child: Row(
              children: [IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  showMenu(position:RelativeRect.fromLTRB(0,0, 0, 0),context: context, items: [PopupMenuItem(child: Text("Profile"),),
                    PopupMenuItem(child: Text("Logout"),)
                  ]);}
              ),
                Expanded(
                  child: Container(
                    height: 60,
                    child: TabBar(
                        tabs: [ Tab(child: Row(children: [ Text("Pc Room",style:
                        TextStyle(fontFamily: "Mono",fontSize: 15,color: Colors.white),),
                          SizedBox(width:10), Icon(Icons.computer_outlined,color: Colors.white,) ],), ),
                          Tab(child: Row(
                            children: [
                              Text("Turf",style:
                              TextStyle(fontFamily: "Mono",fontSize: 15,color: Colors.white),),
                              SizedBox(width:10),
                              Icon(Icons.sports_cricket,color:Colors.white)
                            ],
                          ),), Tab(child:Row(
                            children: [
                              Text("Badminton",style:
                              TextStyle(fontFamily: "Mono",fontSize: 15,color: Colors.white),),
                              SizedBox(width:10),
                              Icon(Icons.sports_tennis_outlined,color:Colors.white)
                            ],
                          ),) ]
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(children: [
        Container(
            margin: EdgeInsets.only(top:2),
          padding: EdgeInsetsGeometry.all(30),
          child:GridView.builder(itemCount:4,scrollDirection:Axis.vertical,gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,crossAxisSpacing:20,mainAxisSpacing:25,mainAxisExtent:238),
              itemBuilder:(context,index){return Card(
                child: Column(
                  children: [Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network("https://tse2.mm.bing.net/th/id/OIP.uUwuVyEOr4oYpzjFO9kU2wHaFj?pid=Api&P=0&h=220"),
                  ),
                    // SizedBox(child: CircleAvatar(child: Text("${index+1}"),),),
                    SizedBox(
                      width: 160,
                      child: TextButton(style:ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color(0xFF007968)),
                        padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(10))
                      ),onPressed: (){
                        print("Pc ${index+1}");
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return Pcbookingpage(pcnumber: index+1,);
                        }));
                      }, child: Text("Book PC ${index+1}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700,color:Colors.white),)),
                    ),SizedBox(height: 3,),
                    SizedBox(
                      width: 160,
                      child: TextButton(style:ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.grey.shade400),
                          padding: WidgetStatePropertyAll(EdgeInsetsGeometry.all(10))
                      ),onPressed: (){
                        showMenu(position:RelativeRect.fromLTRB(300, 300, 0, 0),context: context, items: [
                          PopupMenuItem(child:Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date"),
                                  Text("Time"),
                                  Text("Status")
                                ],
                              )
                            ],
                          ))
                        ]);
                      }, child: Text("View Slot",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w700,color:Colors.grey.shade800),)),
                    ),
                    SizedBox(height: 3,)
                  ],
                )
              );})
        ),
       Text("Turf"),
        Text("Bad")
      ]),
    )
    );
  }
}
