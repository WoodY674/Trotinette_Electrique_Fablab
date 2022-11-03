import 'package:patinette_electrique_fablab/api/patinette_service_io.dart';

import 'package:patinette_electrique_fablab/models/Patinette.dart';

class PatinetteUseCase {
  ActivityServiceApi api = ActivityServiceApi();

  Future<Patinette> getPatinetteData() async {
    return api.getPatinetteData().then((value) => value);
  }
}
