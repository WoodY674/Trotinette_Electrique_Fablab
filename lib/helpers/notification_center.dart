/// This class is used to share notification among the app.
/// That could be used to refresh data after an action occurred on another page.
class Notification{
  final String name;
  final List<String> stateImpacted;

  Notification({
    required this.name,
    required this.stateImpacted
  });
}

class NotificationCenter{
  static Notification trottinetteDataReceived = Notification(name: "PatinetteDataReceived", stateImpacted: ["_HomePageState"]);
}
