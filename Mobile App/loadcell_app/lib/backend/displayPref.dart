// stores information on whether the user wants to display volume, weight or percent
import "package:shared_preferences/shared_preferences.dart";
import "data.dart";

class DisplayPref{

  static void setAppPreferance(String preference) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("appPref",preference);
  }

  static void setScalePreferance(String preference, String firebaseKey) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("scalePref",preference);
    Data.changeScalePref(preference,firebaseKey);
  }

  static Future<String> getAppPreference()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String str = pref.getString("appPref");
    if (str == null){
      str = "Weight";
    }
    return str;
  }

  static Future<String> getScalePreference()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String str = pref.getString("scalePref");
      if (str == null){
        str = "Weight";
      }
    return str;
  }
}