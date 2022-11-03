
class GlobalsConst{
  static const isSimulation = false;

  static final GlobalsConst _instance = GlobalsConst._internal();
  factory GlobalsConst() {
    return _instance;
  }
  GlobalsConst._internal();

}

