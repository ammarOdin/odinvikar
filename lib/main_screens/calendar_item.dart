import 'package:icalendar_parser/icalendar_parser.dart';

class CalendarItem {
  final String type, uid, description, location, summary;
  final IcsDateTime startTime, endTime;
  final List attendee;

  CalendarItem({
    required this.type,
    required this.uid,
    required this.description,
    required this.attendee,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.summary,
  });

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    return CalendarItem(
      type: json['type'] ?? 'Ukendt type',
      uid: json['uid'] ?? 'Ukendt UID',
      description: json['description'] ?? 'Ukendt besked',
      attendee: json['attendee'] ?? List.empty(),
      startTime: json['dtstart'] ?? IcsDateTime(dt: 'Ukendt start'),
      endTime: json['dtend'] ?? IcsDateTime(dt: 'Ukendt slut'),
      location: json['location'] ?? 'Ukendt lokation',
      summary: json['summary'] ?? 'Ukendt fag',
    );
  }
}