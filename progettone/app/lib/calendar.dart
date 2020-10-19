import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'api.dart';

class Calendar extends StatefulWidget{
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  CalendarController _calendarController;
  Map<DateTime, List> _events;
  List<dynamic> _selectedEvents;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _events = getEvents(calendar);
    _selectedEvents = [];
    final _selectedDay = DateTime.now();
    _selectedEvents = _events[_selectedDay] ?? [];
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget> [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: const EdgeInsets.only(bottom: 10),
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                ),
              ],
            ),
            child: TableCalendar(              
              calendarController: _calendarController,
              events: _events,
              startingDayOfWeek: StartingDayOfWeek.monday,
              weekendDays: const [DateTime.sunday],
              locale: 'it_IT',
              onDaySelected: (date, events) {
                setState(() {
                  _selectedEvents = events;
                });
              },
              calendarStyle: CalendarStyle(
                markersColor: Theme.of(context).backgroundColor,
              ),
              //availableGestures: AvailableGestures.none,
              availableCalendarFormats: {CalendarFormat.month : 'Mese', CalendarFormat.week: '-'},
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.quicksand(color: Theme.of(context).backgroundColor, fontSize: 15),
                weekendStyle: GoogleFonts.quicksand(color: Colors.red[300], fontSize: 15),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: Theme.of(context).textTheme.headline1.copyWith(fontSize: 25, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).backgroundColor,),
                rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).backgroundColor,),
                formatButtonVisible: false,
              ),
              builders: CalendarBuilders(
                // Giorno normale
                dayBuilder: (context, date, events) =>
                Container(
                  margin: const EdgeInsets.all(5),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 20),
                    ),
                  ),
                ),
                // Giorno selezionato
                selectedDayBuilder: (context, date, events) {
                return FadeTransition(
                  opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 20),
                      ),
                    ),
                  ),
                );
                },
                // Giorno corente
                todayDayBuilder: (context, date, events) =>
                Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).backgroundColor)
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // I tre punti servono a dire "tutto" di quella lista di eventi (_selectedEvents)
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: _selectedEvents.length != 0
            ? ListView(
              padding: const EdgeInsets.all(15),
              children: <Widget>[
                ..._selectedEvents.map((event) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).buttonColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      event,
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 20, color: Theme.of(context).accentColor),
                    )
                  ),
                ))
              ],
            )
            : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).buttonColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      'Compiti e verifiche appariranno qui',
                      style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 20, color: Theme.of(context).accentColor)
                    )
                  ),
                ),
              ],
            )
          )
        ),
      ] 
    );
  }
}

Map<DateTime, List> getEvents(List calendarData){
  Map<DateTime, List> calendarList = {};
  for (int i = 0; i < calendarData.length; i++) {
    if (calendarData[i] == 'Homework' || calendarData[i] == 'Test'){
      if(calendarList.containsKey(DateTime.utc(calendarData[i+1][2], calendarData[i+1][1], calendarData[i+1][0]))){
        if (calendarData[i] == 'Homework'){
          calendarList[DateTime.utc(calendarData[i+1][2], calendarData[i+1][1], calendarData[i+1][0])].add(
            'Compiti di ' + calendarData[i+2].toString() + ': ' + calendarData[i+3].toString() + ' [assegnati il ' + calendarData[i+4].toString() + ']'
          );
        }else{
          calendarList[DateTime.utc(calendarData[i+1][2], calendarData[i+1][1], calendarData[i+1][0])].add(
            'Verifica di ' + calendarData[i+3].toString() + ' [descrizione: ' + calendarData[i+2].toString() + ']'
          );
        }
      }else{
        if (calendarData[i] == "Homework"){
          calendarList[DateTime.utc(calendarData[i+1][2], calendarData[i+1][1], calendarData[i+1][0])] =
            ['Compiti di ' + calendarData[i+2].toString() + ': ' + calendarData[i+3].toString() + ' [assegnati il ' + calendarData[i+4].toString() + ']'];
        } else {
          calendarList[DateTime.utc(calendarData[i+1][2], calendarData[i+1][1], calendarData[i+1][0])] =
            ['Verifica di ' + calendarData[i+3].toString() + ' [descrizione: ' + calendarData[i+2].toString() + ']'];
        } 
      }
    }
  }
  return calendarList;
}