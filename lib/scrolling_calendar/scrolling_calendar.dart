import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'calendar_month.dart';

class ScrollingCalendar extends StatelessWidget {
  static const double listItemHeight = 320.0;
  static const int baseIndex = 10000;
  final DateTime dateAtBaseIndex;
  final int firstDayOfWeek;
  final DateTime selectedDate;
  final DateTappedCallbackType onDateTapped;
  final Iterable<Color> Function(DateTime) colorMarkers;

  static DateTime _getCurrentDate() =>
      ((DateTime time) => new DateTime.utc(time.year, time.month, time.day))(
          DateTime.now().toUtc());

  ScrollingCalendar(
      {this.selectedDate,
        DateTappedCallbackType onDateTapped,
        int firstDayOfWeek,
        Iterable<Color> Function(DateTime) colorMarkers})
      : colorMarkers = colorMarkers ?? ((_) => <Color>[]),
        firstDayOfWeek = firstDayOfWeek ?? DateTime.monday,
        onDateTapped = (onDateTapped ?? (_) {}),
        dateAtBaseIndex = (selectedDate ?? _getCurrentDate());

  void jumpToMonth(DateTime date) {
    scrollController
        .jumpTo(_getScrollOffsetForIndex(_getIndexForMonthDate(date)));
  }

  static int _getMonthDifference(DateTime base, DateTime other) =>
      (other.year - base.year) * DateTime.monthsPerYear +
          (other.month - base.month);

  int _getIndexForMonthDate(DateTime date) =>
      baseIndex + _getMonthDifference(dateAtBaseIndex, date);

  static double _getScrollOffsetForIndex(int index) => index * listItemHeight;

  static DateTime _getSiblingMonthDate(DateTime current, bool next) {
    DateTime result = current;

    while (result.month == current.month)
      result = result.add(Duration(days: next ? 28 : -28));

    return result;
  }

  DateTime _getMonthDateByIndex(int index) {
    DateTime resultDate = dateAtBaseIndex;

    final bool advanceForwards = (index - baseIndex) > 0;
    final int advanceTimes = (index - baseIndex).abs();

    for (int index = 0; index < advanceTimes; ++index)
      resultDate = _getSiblingMonthDate(resultDate, advanceForwards);

    return resultDate;
  }

  final ScrollController scrollController = PageController(
      initialPage: baseIndex);//_getScrollOffsetForIndex(baseIndex));

  @override
  Widget build(BuildContext context) => Container(
    height: listItemHeight,
    child: PageView.builder(
      //itemExtent: listItemHeight,
      itemBuilder: (BuildContext context, int index) => Container(
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          child: CalendarMonth(
            colorMarkers: colorMarkers,
            startDate: _getMonthDateByIndex(index),
            selectedDate: selectedDate,
            onDateTapped: onDateTapped,
            firstDayOfWeek: firstDayOfWeek,
          )),
      controller: scrollController,
    )
  );
}
