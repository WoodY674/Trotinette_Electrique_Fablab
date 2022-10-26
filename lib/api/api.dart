import "package:http/http.dart" as http;

enum Method{
  get,
  post,
  patch,
  put,
  delete
}

extension StringExtension on String{
  String camelCaseToNormal(){
    return this.split(RegExp(r"(?=[A-Z])")).join(" ");

  }

  String enumToNormalCase(){
    return this.split(".").last.camelCaseToNormal();
  }
}

extension MethodExtension on Method{
  String toShortString(){
    return this.toString().enumToNormalCase();
  }
}

isEmptyValue(dynamic val){
  if (val == null){
    return true;
  }
  if (val.runtimeType is int){
    return val == 0;
  }
  else if(val.runtimeType is String){
    return val == "";
  }
  else if(val.runtimeType is List){
    return val.isEmpty;
  }
  else if (val.runtimeType is Map){
    return val.isEmpty;
  }
  else if(val.runtimeType is bool){
    return val;
  }
  else{
    return false;
  }
}

class Api{
  final http.Client client = http.Client();
  final host = "http://10.42.0.1:5000/";
  var mainHeader = {
    'Content-type': "application/json; charset=UTF-8"
  };

  static final Api _instance = Api._internal();
  factory Api() {
    return _instance;
  }
  Api._internal();

  setMainHeader(keyPara, val){
    mainHeader[keyPara]=val ;
  }


  /// Prepare the params in url (ex : https://api/activities?hostId=1&city=Cergy).
  /// [isFirstParam] should be true if we require to add a '?' char in first place.
  /// [map] contains all the data to convert as url params.
  /// The keys are used as param name (ex : {hostId:1, city:Cergy}).
  ///
  /// [ignored] is the list of keys we may want to ignore in the map provided.
  /// let it empty if nothing is to ignore.
  String handleUrlParams(bool isFirstParam, Map<String, dynamic> map,  {List<String>  ignored:const []}){
    String params = "";
    int count = 0;
    map.forEach((key, value){
      if(!ignored.contains(key) && value != null && !(isEmptyValue(value)) ){
        params += (isFirstParam && count ==0 ? "?" : "&") + key + "=" + value.toString();
        count ++;
      }
    });
    return params;
  }

}

class ApiErr implements Exception {
  int codeStatus;
  String message;
  String errMsg() => 'an error occured with status code - $codeStatus - , $message';

  ApiErr({required this.codeStatus, required this.message});
}