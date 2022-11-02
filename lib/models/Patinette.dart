class Patinette {
  final int battery;
  final int speed;
  final int gear;

  const Patinette({
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
