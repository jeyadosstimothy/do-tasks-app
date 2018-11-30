import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class CalendarDay extends StatelessWidget {
  final bool selected;
  final DateTime date;
  final VoidCallback onTap;
  final Iterable<Color> colorMarkers;

  CalendarDay(
      {@required this.selected,
        @required this.date,
        @required this.onTap,
        @required this.colorMarkers});

  @override
  Widget build(BuildContext context) => new Expanded(
      child: new GestureDetector(
          onTap: onTap,
          child: new Column(children: <Widget>[
            new Container(
                decoration: selected
                    ? new BoxDecoration(
                  color: Theme.of(context).accentColor,
                  shape: BoxShape.circle,
                )
                    : new BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).accentColor,
                      width: 0.3
                  ),
                ),
                width: 30.0,
                height: 30.0,
                margin: const EdgeInsets.only(top: 4.0),
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(
                        date.day.toString(),
                        textAlign: TextAlign.center,
                        style: selected
                            ? Theme.of(context).accentTextTheme.body2
                            : Theme.of(context).textTheme.body2,
                      ),
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: colorMarkers
                              .map((color) => new Container(
                              decoration: new BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(3.0)))
                              .toList()),
                    ])),

          ])));
}
