import 'package:trotinette_electrique_fablab/api/trotinette_service_io.dart';

import 'package:trotinette_electrique_fablab/models/Patinette.dart';

class TrotinetteUseCase {
  ActivityServiceApi api = ActivityServiceApi();

  Future<Patinette> getTrotinetteData() async {
    return api.getTrotinetteData().then((value) => value);
  }
}
