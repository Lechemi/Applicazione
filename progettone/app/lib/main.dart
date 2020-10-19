import 'calendar.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'marks.dart';
import 'api.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'badge.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    final textTheme = Theme.of(context).textTheme;
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]
    );
    return MaterialApp(
      title: 'test',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Color(0xffA8C256),
        accentColor: Color(0xffe1dede),
        backgroundColor: Color(0xff26303d),
        hintColor: Color(0xff9DB54F),
        buttonColor: Color(0xff374659),

        textTheme: GoogleFonts.quicksandTextTheme(textTheme).copyWith(
          headline1: GoogleFonts.quicksand(color: Color(0xff26303d), fontSize: 20,),
        ),
      ),
      home: Splash()
    );
  }
}

class Splash extends StatefulWidget {
  // Il costruttore di questa classe è il primo ad essere chiamato
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  Future checkFirstSeen() async {
    // Controllo se è la prima volta che l'utente apre l'app
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);
    // _seen viene presa dalle shared preferences ('seen'), ma se non c'è, la metto false (quindi è il primo accesso per l'utente)
    if (_seen) {
      // Se non è il primo accesso vado a MyHomePage
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage(reload: true,)));
    } else {
      // Se è il primo accesso, imposto 'seen' a true e vado all'IntroScreen
      await prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => IntroScreen(goBack: false,)));
    }
  }

  @override
  void initState() {
    super.initState();
    Future.wait([checkFirstSeen()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Center(
        child: Text('Loading...'),
    ),
    );
  }
}


class MyHomePage extends StatefulWidget{
  MyHomePage({Key key, this.title, this.reload}) : super(key: key);
  final String title;
  final bool reload;
  @override 
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  @override
  Widget build(BuildContext context){
    return FutureBuilder(
    // Questo FutureBuilder aspetta che lmao() sia conclusa e intanto fa vedere la clessidra di caricamento
    // In lmao passo reload, che solo se è vera ricarica tutti i dati prendendoli dal server
    future: lmao(widget.reload),
    builder: (context, snapshot) {
      if (responseCode == 500) {
        // Se lmao rende responseCode uguale a 500 vuol dire che le credenziali sono errate, quindi rimanda a IntroScreen
        return IntroScreen(goBack: false,);
      } else {
        if (snapshot.connectionState == ConnectionState.done){
          // Se è andato tutto bene con lmao(), posso ritornare la app vera e propria
          return Scaffold(
          body: DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              drawer: Drawer(
                // Drawer in alto a sinistra 
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                // Nome dell'utente
                                userFullName,
                                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 25, color: Theme.of(context).backgroundColor)
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                // Classe e sezione dell'utente
                                'Classe ' + userClass,
                                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor),
                              ),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      ListTile(
                        // Tasto che porta alla schermata di login
                        leading: Icon(Icons.input, color: Colors.grey[200],),
                        title: Text(
                          'Login',
                          style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 20, color: Theme.of(context).accentColor),
                        ),
                        onTap: () {
                          // Riporta alla schermata di login iniziale
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => IntroScreen(goBack: true,)));
                        }
                      ),
                    ],
                  ),
                ),
              ),
              // Appbar
              appBar: AppBar(
                elevation: 20,
                centerTitle: true,
                backgroundColor: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                title: Text(
                  // Nome dell'app
                  'Registro',
                  style: Theme.of(context).textTheme.headline1,
                )
              ),
              body: TabBarView(
                children: [
                  Container(
                    // VOTI
                    color: Theme.of(context).backgroundColor,
                    child: Center(
                      child: ListView(
                        padding: EdgeInsets.only(bottom: 30, top: 10),
                        children: getList(avr, n, fullMarks, subjectList)
                      ),
                    )
                  ),
                  Container(
                    // CALENDARIO (compiti + verifiche)
                    color: Theme.of(context).backgroundColor,
                    child: Center(child: Calendar())
                  ),
                  Container(
                    // ASSENZE/RITARDI
                    color: Theme.of(context).backgroundColor,
                    child: Center(
                      child: badge.length >= 1
                      ? GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: (1/1),
                        children: getBadge(badge)
                      )
                      : Container(
                        // Questo container appare se non ci sono assenze/ritardi
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Non hai ancora assenze, ritardi o uscite anticipate...',
                          style: GoogleFonts.quicksand(color: Theme.of(context).accentColor, fontSize: 20),
                          textAlign: TextAlign.center
                        ),
                      )
                    )
                  ),
                ],
              ),
              bottomNavigationBar: Container(
                // Questa è la barra di navigazione in basso che scorre tra le schermate
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Theme.of(context).accentColor)
                  )
                ),
                child: TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.school),
                    ),
                    Tab(
                      icon: Icon(Icons.calendar_today),
                    ),
                    Tab(icon: Icon(Icons.schedule),)
                  ],
                  labelColor: Color(0xffD9594C),
                  unselectedLabelColor: Theme.of(context).accentColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.all(5.0),
                  indicatorColor: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
        );
        }else {
          return Container(
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: SpinKitPouringHourglass(
                color: Theme.of(context).accentColor,
                size: 70.0
              )
            ),
          );
        }
      }
    }
    );
  }
}
