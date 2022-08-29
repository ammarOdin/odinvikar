class CalendarItem {
  final String type, uid, description, attendee, startTime, endTime, location, summary;

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
      type: json['type'] ?? 'Intet',
      uid: json['uid'] ?? 'Intet',
      description: json['description'] ?? 'Intet',
      attendee: json['attendee'] ?? 'Intet',
      startTime: json['dtstart'] ?? 'Intet',
      endTime: json['dtend'] ?? 'Intet',
      location: json['location'] ?? 'Intet',
      summary: json['summary'] ?? 'Intet',
    );
  }
}