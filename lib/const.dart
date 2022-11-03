
class GlobalsConst{
  static const isSimulation = true;

  static final GlobalsConst _instance = GlobalsConst._internal();
  factory GlobalsConst() {
    return _instance;
  }
  GlobalsConst._internal();

}

