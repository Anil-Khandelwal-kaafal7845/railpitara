// moengage_service.dart
import 'package:moengage_flutter/moengage_flutter.dart';

class MoEngageService {
  static final MoEngageFlutter _instance = MoEngageFlutter('F2Z5P8P67ZG4GWG42469CTWX');

  static MoEngageFlutter get instance => _instance;

  static void initialise() {
    _instance.initialise();
  }


}
