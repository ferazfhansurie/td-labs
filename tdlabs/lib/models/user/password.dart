import 'package:flutter/cupertino.dart';
import '../../utils/web_service.dart';

class Password {
  static Future<Response?> changePassword(BuildContext context, int id,
      String currPassword, String newPassword) async {
    final webService = WebService(context);
    webService.setMethod('POST').setEndpoint('identity/password');

    Map<String, String> data = {
      'password_old': currPassword,
      'password': newPassword
    };
    return await webService.setData(data).send();
  }

  static Future<Response?> resetRequest(
      BuildContext context, String username, int usernameType) async {
    final webService = WebService(context);
    webService
        .setAuthType('Basic')
        .setMethod('POST')
        .setEndpoint('identity/password-reset/request');

    Map<String, String> data = {
      'username': username,
      'username_type': usernameType.toString()
    };
    return await webService.setData(data).send();
  }

  static Future<Response?> resetVerify(BuildContext context, String username,
      String pin, int usernameType) async {
    final webService = WebService(context);
    webService
        .setAuthType('Basic')
        .setMethod('POST')
        .setEndpoint('identity/password-reset/verify');

    Map<String, String> data = {
      'username': username,
      'pin': pin,
      'username_type': usernameType.toString()
    };
    return await webService.setData(data).send();
  }

  static Future<Response?> resetUpdate(BuildContext context,
      String passwordResetToken, String password, int usernameType) async {
    final webService = WebService(context);
    webService
        .setAuthType('Basic')
        .setMethod('POST')
        .setEndpoint('identity/password-reset/update');

    Map<String, String> data = {
      'password_reset_token': passwordResetToken,
      'password': password,
      'username_type': usernameType.toString(),
    };
    return await webService.setData(data).send();
  }
}
