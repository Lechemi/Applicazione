import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';


class IntroScreen extends StatefulWidget {
  final bool goBack;
  const IntroScreen({this.goBack});
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  TextEditingController usrController = new TextEditingController();
  TextEditingController pswController = new TextEditingController();
  bool isLogniDisabled = true;
  int verifyingCredentials = 0;

  // Per verifyingCredentials --> 0 = nulla, 1 = sbagliate, 2 = verificando

  Future saveCredentials(String uName, String psw) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', uName);
    prefs.setString('password', psw);
  }

  Future _loginPressed() async {
    setState(() {
      verifyingCredentials = 2;
    });
    // Controllo che le credenziali siano corrette
    myToken = await getToken(usrController.text, pswController.text);
    await getData('badge', myToken, true);
    if (responseCode == 500) {
      // Se le credenziali sono incorrette faccio vedere un messaggio di errore
      setState(() {
        verifyingCredentials = 1;
      });
    }else{
      // Se le credenziali sono corrette le salvo in SharedPreferences
      await saveCredentials(usrController.text, pswController.text);
      await saveToken(myToken);
      setState(() {
        verifyingCredentials = 0;
      });
      // Vado alla home
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage(reload: true,)));
    }
  }

  void _onChanged(String value) {
    setState(() {
      isLogniDisabled = (usrController.text.length == 0 || pswController.text.length == 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  widget.goBack == true
                  ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Theme.of(context).backgroundColor),
                          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage(reload: false,))),
                        )
                      ],
                    ),
                  )
                  : Container(
                    height: 60,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Inserisci le tue credenziali',
                          style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 20, color: Theme.of(context).backgroundColor, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  // Username
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(color: Theme.of(context).backgroundColor,)
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        labelStyle: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor),
                        labelText: 'Username',
                        icon: Icon(
                          Icons.person,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      style: GoogleFonts.quicksand(color: Theme.of(context).backgroundColor),
                      controller: usrController,
                      onChanged: _onChanged,                    
                    ),
                  ),
                  // Password
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(color: Theme.of(context).backgroundColor,)
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        labelStyle: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor),
                        labelText: 'Password',
                        icon: Icon(
                          Icons.lock,
                          color: Theme.of(context).backgroundColor,
                        ),
                      ),
                      style: GoogleFonts.quicksand(color: Theme.of(context).backgroundColor),
                      obscureText: true,
                      controller: pswController,
                      onChanged: _onChanged,
                    ),
                  ),
                  // Pulsante di login
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    //color: Color(0xffD9594C),
                    color: Theme.of(context).primaryColor,
                    disabledColor: Theme.of(context).primaryColor,
                    disabledElevation: 0,
                    elevation: 10,
                    child: Text(
                      'Login',
                      style: GoogleFonts.quicksand(color: Theme.of(context).backgroundColor, fontWeight: FontWeight.bold)
                    ),
                    onPressed: isLogniDisabled
                      ? null
                      : _loginPressed, // isLoginDisabled è true? Se sì ritorna null, se è false chiama la funzione _loginPressed
                  ),
                  verifyingCredentials == 1
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Credenziali inesistenti',
                          style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Color(0xffD9594C)),
                        ),
                      )
                    ],
                  )
                  : verifyingCredentials == 2
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Verificando le credenziali...',
                            style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor),
                          ),
                        )
                      ],
                    )
                    : Offstage()
                  ],
                ),
            )
            ),
          ] 
        ),
      ),
    );
  }
}

// () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage(reload: false,))),