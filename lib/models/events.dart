class ActiveEvent {
  final String event_id;
  final String event_name;

  ActiveEvent({
    required this.event_id,
    required this.event_name,
  });

  // Factory method to create an Employee object from a JSON map
  factory ActiveEvent.fromJson(Map<String, dynamic> json) {
    return ActiveEvent(
      event_id: json['event_id'].toString(), // Ensure id is converted to string
      event_name: json['event_name'].toString(),
    );
  }

  // Convert an Employee object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'event_id': event_id,
      'event_name': event_name,
    };
  }
}
