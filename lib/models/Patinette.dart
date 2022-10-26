class Patinette {
  final int battery;
  final int speed;

  const Patinette({
    required this.battery,
    required this.speed,
  });

  factory Patinette.fromJson(Map<String, dynamic> json) {
    return Patinette(
      battery: json['levelBattery'],
      speed: json['speed'],
    );
  }
}