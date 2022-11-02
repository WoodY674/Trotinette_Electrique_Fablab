import 'dart:convert';
import 'package:trotinette_electrique_fablab/api/api.dart';
import 'package:trotinette_electrique_fablab/models/Patinette.dart';

/// This class is used to call our API for all that concern activities
class ActivityServiceApi {
  final api = Api();

  Future<Patinette> getTrotinetteData() async {
    final response = await api.client
        .get(Uri.parse(api.host + 'allData'));
    if (response.statusCode == 200) {
      return Patinette.fromJson(jsonDecode(response.body));
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load activity");
    }
  }

}