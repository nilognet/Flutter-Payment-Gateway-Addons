
class FatoorahFunction {
  static bool formCardValidator(String number, String cvv, String mm, String yy, String name){
    if(number.isNotEmpty && cvv.isNotEmpty && mm.isNotEmpty && yy.isNotEmpty && name.isNotEmpty){
      return true;
    }
    return false;
  }
}
