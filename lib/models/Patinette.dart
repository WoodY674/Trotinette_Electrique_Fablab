class Patinette {
  int battery;
  int speed;
  int gear;

  Patinette({
    required this.battery,
    required this.speed,
    required this.gear,
  });

  factory Patinette.fromJson(Map<String, dynamic> json) {
    return Patinette(
      battery: json['batteryLevel'],
      speed: json['speed_kmh'],
      gear: json['gear'],
    );
  }
}
