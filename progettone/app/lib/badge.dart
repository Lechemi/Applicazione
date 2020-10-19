import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 

class BadgeCard extends StatefulWidget{
  final List badgeInfo;
  const BadgeCard({Key key, this.badgeInfo}) : super(key: key);
  @override
  _BadgeCardState createState() => _BadgeCardState();  
}

class _BadgeCardState extends State<BadgeCard>{
  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            // Container che contiene la data in grande per ogni casella
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.badgeInfo[0].substring(0, 5),
                  style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 25, color: Theme.of(context).backgroundColor, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          widget.badgeInfo[widget.badgeInfo.length - 3] == 'SI'
          ? widget.badgeInfo[1] == 'Assenza'
            ? Text(
              widget.badgeInfo[1] + ', giustificata il giorno ' + widget.badgeInfo[3] + ' (' + widget.badgeInfo.last + ').',
              style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor)
            )
            : widget.badgeInfo[1] == 'Ritardo'
            ? Text(
                widget.badgeInfo[1] + ' (' + widget.badgeInfo[2] + '), giustificato il giorno ' + widget.badgeInfo[4] + ' (' + widget.badgeInfo.last + ').',
                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor)
            )
            : widget.badgeInfo[1] == 'Uscita'
            ? Text(
                widget.badgeInfo[1] + ' (' + widget.badgeInfo[2] + '), giustificata il giorno ' + widget.badgeInfo[4] + ' (' + widget.badgeInfo.last + ').',
                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor)
            )
            :Offstage()
          : widget.badgeInfo[1] == 'Assenza' || widget.badgeInfo[1] == 'Uscita' 
            ? Text(
              widget.badgeInfo[1] + ' non giustificata.',
              style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor)
            )
            : widget.badgeInfo[1] == 'Ritardo'
            ? Text(
                widget.badgeInfo[1] + ' non giustificato.',
                style: Theme.of(context).textTheme.headline1.copyWith(fontSize: 15, color: Theme.of(context).backgroundColor)
            )
            :Offstage()
        ],
      )
    );
  }
}

List<Widget> getBadge(List badgeDetails){
  List<BadgeCard> badgeList = [];
  for (int i = 0; i < badgeDetails.length; i++){
    badgeList.add(new BadgeCard(badgeInfo: badgeDetails[i],));
  }
  return badgeList;
}
