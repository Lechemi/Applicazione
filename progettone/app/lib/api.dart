import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'marks.dart';

var jsonResponseNames;
var jsonResponseMarks;
var jsonResponseCalendar;
var jsonResponseBadge;
var jsonResponseDetails;
List avr = [];
List n = [];
List fullMarks = [];
List badge = [];
String userFullName;
String userClass;
List calendar = [];
int responseCode;
String myToken;
final List subjectList = ['Italiano', 'Inglese', 'Filosofia', 'Storia', 'Matematica', 'Fisica', 'Scienze', 'Informatica', 'Arte', 'Educazione Fisica'];
 
// Funzione che esegue la GET request al server con ogni query
Future getData(String query, String token, bool testing) async {
  final String url = 'http://127.0.0.1:5000/api?query=' + query;
  http.Response response = await http.get(url, headers: {'x-access-token': token});
  if (response.statusCode == 200) {
    if (testing == true) {
      responseCode = 200;
      return;
    }
    if (query == 'names'){
      n = [];
      jsonResponseNames = jsonDecode(response.body);
      for (int i = 0; i < subjectList.length; i++){
        n.add(jsonResponseNames[subjectList[i]]);
      }
    }else if (query == 'marks'){
      jsonResponseMarks = jsonDecode(response.body);
      avr = [];
      fullMarks = [];
      for (int i = 0; i < subjectList.length; i++){
        fullMarks.add(jsonResponseMarks[subjectList[i]]);
      }
      for (int i = 0; i < subjectList.length; i++){
        if (jsonResponseMarks[subjectList[i]].length > 1) {
          avr.add(organizeMarks(jsonResponseMarks[subjectList[i]]));
        }else{
          avr.add(0.0);}
      }
    }else if (query == 'calendar'){
      jsonResponseCalendar = jsonDecode(response.body);
      calendar = jsonResponseCalendar['Calendar'];
    }else if (query == 'badge'){
      jsonResponseBadge = jsonDecode(response.body);
      badge = jsonResponseBadge['Badge'];
    }else if (query == 'userdetails'){
      jsonResponseDetails = jsonDecode(response.body);
      userFullName = jsonResponseDetails['Name'];
      userClass = jsonResponseDetails['Class'];
    }
  }
  responseCode = response.statusCode;
  return;
}

Future getToken(String usr, String psw) async {
  String token = '';
  Map data = {
  'username': usr,
  'password': psw
  };

  String body = json.encode(data);

  http.Response response = await http.post(
    'http://127.0.0.1:5000/login',
    body: body,
  );
  token = jsonDecode(response.body)['token'];
  return token;
}

Future getCredentials(bool type) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String data;
  if (type == true) {
    data = prefs.getString('username');
  }else{
    data = prefs.getString('password');
  }
  return data;
}

Future saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('token', token);
}

Future retreiveToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future lmao(bool retreiveData) async {
  if (retreiveData) {
    myToken = await retreiveToken();
    // Dopo aver preso il token da shared preferences, prova a prendere le informazioni dal server
    await Future.wait([
      getData('marks', myToken, false), 
      getData('names', myToken, false), 
      getData('calendar', myToken, false), 
      getData('badge', myToken, false),
      getData('userdetails', myToken, false),]);
    if (responseCode == 500){
      // Se le credenziali sono sbagliate, rimanda alla pagina di login
      return;
    }else if (responseCode == 403){
      // Se il token è scaduto o sbagliato per qualsiasi motivo
      String username = await getCredentials(true);
      String password = await getCredentials(false);
      myToken = await getToken(username, password);
      await saveToken(myToken);
      await Future.wait([
      getData('marks', myToken, false), 
      getData('names', myToken, false), 
      getData('calendar', myToken, false), 
      getData('badge', myToken, false),
      getData('userdetails', myToken, false),]);
    }
  }
  // Se tutto va a buon fine, ritorna 200
  responseCode = 200;
  return;
}
