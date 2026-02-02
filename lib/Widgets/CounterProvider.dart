import 'package:flutter/cupertino.dart';

class Counterprovider extends ChangeNotifier{
  int _count=0;

//   Events
void Increment(){
  _count ++;
  notifyListeners();

}
void Decrement(){
  if(_count > 0){
    _count--;
  }
  notifyListeners();
}
// Get value of count
int getCount(){
  return _count;
}
}