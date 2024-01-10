// ignore_for_file: constant_identifier_names
import 'main_local.dart';


class MainConfig {  
  static const modeLive = false;
  static const test = false;
  static const appId = MainLocalConfig.appId;
  static const appSecret = MainLocalConfig.appSecret;
  static const versionHash ='e343ccb2c6215fa91e12e66699378f87fcd3c858d1cf8e7a96b5546ee7f33897';
  static const googleMapApi = 'AIzaSyB-WkFm80gN7bXvORa__Bjua1zOEGFgfl0';
  static const CURRENCY = 'RM';
  static String baseUrl = getUrl();
  static String appUrl = baseUrl + '/api/v1';
  static const APP_VER = '3.13';
  static String getUrl() {
    if (modeLive) {
      return 'https://cloud.tdlabs.co';
    } else {
      return 'https://dev.tdlabs.co';
    }
  }
}
