import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'calendar_day.dart';

typedef void DateTappedCallbackType(DateTime dateTime);

class CalendarMonth extends StatelessWidget {
  final DateTime startDate;
  final DateTime selectedDate;
  final DateTappedCallbackType onDateTapped;
  final Iterable<DateTime> daysOfMonth;
  final int firstDayOfWeek;
  final Iterable<Color> Function(DateTime) colorMarkers;
  static final DateTime _mondayDate = new DateTime.utc(2018, 5, 6);
  static final DateFormat _weekdayAbbreviationFormatter = new DateFormat('E');
  static final DateFormat _monthFormatter = new DateFormat('MMMM');

  static String getLocalizedMonth(DateTime date) =>
      _monthFormatter.format(date);

  static String _getLocalizedWeekdayAbbreviation(int weekday) =>
      _weekdayAbbreviationFormatter
          .format(_mondayDate.add(Duration(days: weekday)));

  static DateTime _lowerToFirstWeekday(int year, int month, int firstWeekday) {
    DateTime day = DateTime.utc(year, month);

    while (day.weekday != firstWeekday) {
      day = day.add(Duration(days: -1));
    }

    return day;
  }

  static String formatTitle(DateTime date) =>
      "${getLocalizedMonth(date)} ${date.year}";

  CalendarMonth(
      {@required this.startDate,
        @required this.selectedDate,
        @required this.onDateTapped,
        @required this.colorMarkers,
        @required this.firstDayOfWeek})
      : daysOfMonth = generateExtendedDaysOfMonth(startDate, firstDayOfWeek);

  @override
  Widget build(BuildContext context) => new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: []
        ..add(new Container(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: new Text(
              formatTitle(startDate),
              style: Theme.of(context).textTheme.title,
            )))
        ..add(generateWeekDays(context, days: daysOfMonth))
        ..addAll(generateWeeks(days: daysOfMonth, startDate: startDate)));

  static List<DateTime> generateExtendedDaysOfMonth(
      DateTime monthDate, int firstWeekday) {
    final List<DateTime> extendedDaysOfMonth = <DateTime>[];
    DateTime currentDay;

    // adds days before the start of the month
    currentDay = _lowerToFirstWeekday(
      monthDate.year,
      monthDate.month,
      firstWeekday,
    );
    while (currentDay.month != monthDate.month) {
      extendedDaysOfMonth.add(currentDay);
      currentDay = currentDay.add(new Duration(days: 1));
    }

    // adds actual days of month
    while (currentDay.month == monthDate.month) {
      extendedDaysOfMonth.add(currentDay);
      currentDay = currentDay.add(new Duration(days: 1));
    }

    // adds days after the end of the month
    while (currentDay.weekday != firstWeekday) {
      extendedDaysOfMonth.add(currentDay);
      currentDay = currentDay.add(new Duration(days: 1));
    }

    return extendedDaysOfMonth;
  }

  static bool _isSameDate(DateTime a, DateTime b) =>
      a != null &&
          b != null &&
          (a.year == b.year && a.month == b.month && a.day == b.day);

  Widget generateWeek(Iterable<DateTime> daysOfWeek,
      {@required DateTime startDate}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: daysOfWeek
            .map((DateTime date) => (date.month != startDate.month)
            ? new Expanded(child: new Container())
            : new CalendarDay(
          colorMarkers: colorMarkers(date),
          selected: _isSameDate(date, selectedDate),
          date: date,
          onTap: () => onDateTapped(date),
        ))
            .toList(),
      );

  List<Widget> generateWeeks(
      {@required List<DateTime> days, @required DateTime startDate}) =>
      new List<int>.generate(
          days.length ~/ DateTime.daysPerWeek, (index) => index)
          .map((int weekIndex) => generateWeek(
          days.getRange(weekIndex * DateTime.daysPerWeek,
              (weekIndex + 1) * DateTime.daysPerWeek),
          startDate: startDate))
          .toList();

  Widget generateWeekDays(BuildContext context,
      {@required List<DateTime> days}) =>
      new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days
              .getRange(0, 7)
              .map((day) => new Expanded(
              child: new Text(
                _getLocalizedWeekdayAbbreviation(day.weekday),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subhead,
              )))
              .toList());
}
