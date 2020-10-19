import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as test;
import 'dart:math';


class Subject extends StatefulWidget{
  final String subjectName;
  final double average;
  final String nomeProf;
  final List markDetails;
  const Subject({Key key, this.subjectName, this.average, this.nomeProf, this.markDetails}) : super(key: key);
  @override 
  _SubjectState createState() => _SubjectState();
}
 
// Classe che gestisce la casella di ogni materia 
class _SubjectState extends State<Subject>{
  double height = 100;
  int millisecondsDuration = 300;
  double detailsOpacityMinor = 0;
  double subjectHeight = 20;
  bool open = false;
  bool openDetails = false;
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () {
        // Cosa succede quando schiaccio la prima volta sul widget
        if (open == false) {
          setState(() {
          detailsOpacityMinor = 0.8;
          height = height + 85;
          subjectHeight = 0;
          open = true;
        });
          Future.delayed(Duration(milliseconds: 250), (){
            setState(() {
              openDetails = true;
              millisecondsDuration = 100;
            });
          });
        }else{
          // Cosa succede quando schiaccio la seconda volta sul widget
          setState(() {
            openDetails = false;
          });
          Future.delayed(Duration(milliseconds: 100), (){
            setState(() {
              millisecondsDuration = 300;
              height = height - 85;
              subjectHeight = 20;
              detailsOpacityMinor = 0;
              open = false;
            });
          });
        }
      },
      child: AnimatedContainer(
        // Container che contiene tutto e che si allunga
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCirc,
        height: height,
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          // Column che contiene tutto
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AnimatedContainer(
              // Container che contiene le info a colpo d'occhio
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutCirc,
              padding: EdgeInsets.only(top: subjectHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    // Row che contiene il nome della materia e la media
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        widget.subjectName,
                        style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 30, fontWeight: FontWeight.bold)
                      ),
                      Text(
                        widget.average.toString(),
                        style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 35, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                  Row(
                    // Row che contiene il nome del/la professore/ssa e la hint 'Media'
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: detailsOpacityMinor,
                      child: Text(
                        widget.nomeProf,
                        style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15)
                      ),
                      ),
                      AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: detailsOpacityMinor,
                      child: Text(
                        'Media',
                        style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15)
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              // Widget contenente  i dettagli di ogni materia (voti singoli + giustifiche utilizzate)
              duration: Duration(milliseconds: millisecondsDuration),
              child: openDetails  
              ? Container(
                height: 110,
                margin: const EdgeInsets.only(bottom: 5),
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: <Widget>[
                      widget.markDetails.length > 1
                      ? Container(
                        // Questo container contiene la ListView - non rimuovere
                        height: 70,
                        width: double.infinity,
                        child: ListView(
                          // ListView i cui children sono creati dalla funzione markList
                          scrollDirection: Axis.horizontal,
                          children: markList(widget.markDetails),
                        )
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 30),
                            child: Opacity(
                              opacity: 0.4,
                              child: Text(
                                'Non hai ancora voti in questa materia...',
                                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15)
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              'Giustifiche utilizzate: ' + widget.markDetails.last.toString(),
                              style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 20)
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
              : Offstage(
                child: Text('invisible')
              )
            )
          ]
        ),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        )
      ),
    );
  }
}

double roundDouble(double value, int places){ 
   double mod = pow(10.0, places); 
   return ((value * mod).round().toDouble() / mod); 
}

double organizeMarks(List rawData){
  // Funzione che ritorna la media per ogni materia
  double sum = 0;
  int markNumber = 0;
  double average = 0;
  for (int i=0; i<(rawData.length - 1); i++){
    if (rawData[i][3] == 'SI') {
      sum = sum + rawData[i][2];
      markNumber ++;
    }
  }
  if (markNumber == 0) {
    average = 0.0;
  }else{
    average = sum/markNumber;
  }
  if (average == 10){
    return 10;
  }else{
    return roundDouble(average, 1);
  }
}

class Mark extends StatelessWidget{
  // Classe che crea i voti per ogni materia (senza dettagli)
  final List singleMark;
  
  const Mark({Key key, this.singleMark}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return ButtonTheme(
      minWidth: 0,
      child: FlatButton(
        onPressed: (){
          _showDialog(context, singleMark);
        },
        color: Theme.of(context).hintColor,
        padding: const EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Column(
          children: <Widget>[
            Text(
              singleMark[2].toString(),
              style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 30)
            ),
            Opacity(
              opacity: 0.8,
              child: Text(
              singleMark[0].substring(0, 5),
              style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarkDialog extends StatefulWidget {
  final List details;
  const MarkDialog({this.details});
  @override
  State<StatefulWidget> createState() => MarkDialogState();
}

class MarkDialogState extends State<MarkDialog> with SingleTickerProviderStateMixin{
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOutCirc);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  Widget build (BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Theme(
        data: Theme.of(context).copyWith(dialogBackgroundColor: Color(0xff26303d)),
        child: AlertDialog(
          titlePadding: const EdgeInsets.all(5),
          contentPadding: const EdgeInsets.only(left: 15, right: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
          ), 
          title: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
              borderRadius: BorderRadius.circular(5)
            ),
            child: Row(
              // Qua c'è il voto scritto in grande
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.details[2].toString(),
                  style: widget.details[2] >= 7
                  ? Theme.of(context).textTheme.headline1.copyWith(fontSize: 40, color: Colors.green[200])
                  : widget.details[2] <= 5
                    ? Theme.of(context).textTheme.headline1.copyWith(fontSize: 40, color: Colors.red[200])
                    : Theme.of(context).textTheme.headline1.copyWith(fontSize: 40, color: Colors.orange[200])
                ),
              ] 
            ),
          ),
          content: Container(
            // Qua ci sono tutti i dettagli
            width: double.infinity,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  // DATA
                  children: <Widget>[
                    Text(
                      'Data: ',
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 17, color: Theme.of(context).accentColor, fontWeight: FontWeight.bold)
                    ),
                    Text(
                      widget.details[0],
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 17, color: Theme.of(context).accentColor)
                    ),
                  ],
                ),
                Row(
                  // TIPOLOGIA (scritto/orale)
                  children: <Widget>[
                    Text(
                      'Tipologia: ',
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 17, color: Theme.of(context).accentColor, fontWeight: FontWeight.bold)
                    ),
                    Text(
                      widget.details[1].toLowerCase(),
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 17, color: Theme.of(context).accentColor)
                    ),
                  ],
                ),
                widget.details[4] != ''
                ? Column(
                  // DESCRIZIONE (appare solo se c'è)
                    children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          children: [
                            TextSpan(children: [
                              TextSpan(
                                text: 'Descrizione: ',
                                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 17, color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),),
                              TextSpan(
                                text: widget.details[4],
                                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 17, color: Theme.of(context).accentColor),
                              ),
                            ]),
                          ]
                        )
                      ),
                    ) 
                  ]
                ) 
                : Offstage(),
                Row(
                  // FA MEDIA O NO
                  children: <Widget>[
                    widget.details[3] == 'SI'
                    ? Text(
                      'Il voto fa media.',
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 17, color: Theme.of(context).accentColor, fontWeight: FontWeight.bold)
                    )
                    : Text(
                      'Il voto non fa media.',
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 17, color: Theme.of(context).accentColor, fontWeight: FontWeight.bold)
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: FlatButton(
                // Pulsante per chiudere (si può anche toccare fuori dal widget in realtà)
                child: Text(
                  "Chiudi",
                  style: test.GoogleFonts.quicksand(color: Theme.of(context).accentColor, fontSize: 15)
                ),
                color: Theme.of(context).buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


void _showDialog(BuildContext context, List details) {
  // Funzione che fa apparire i dettagli sul voto
  showDialog(
    context: context,
    builder: (_) => MarkDialog(details: details,)
  );
}


List<Widget> getList(List averageList, List namesList, List fullDetails, List subjects) {
  // Funzione che ritorna la casella di ogni materia (molto importante)
  List<Subject> list = [];
  for (int i = 0; i < subjects.length; i++){
    list.add(Subject(subjectName: subjects[i], average: averageList[i], nomeProf: namesList[i], markDetails: fullDetails[i],));
  }
  return list;
}

List<Widget> markList(List details){
  // Funzione che ritorna le caselle dei voti che appaiono quando si tocca la materia
  int markCount = details.length - 1;
  List<Container> list = [];
  for (int i = 0; i < markCount; i++) {
    list.add(Container(
      margin: const EdgeInsets.only(right: 10),
      child: Mark(singleMark: details[i]),));
  }
  return list;
}

