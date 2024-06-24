import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  static Future<bool> isNetworkConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
