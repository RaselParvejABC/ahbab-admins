import 'package:http/http.dart' as http;
import 'dart:convert';
import 'credentials.dart' as credentials;

class Notifications {
  /// Handles sending FCM notifications
  /// using Google's FCM api.
  static Notifications get instance => Notifications();

  Future<int> send({
        required String title,
        required String body,
        String? topic,
        String? token,
      }) async {
    /// Sends a notification with the
    /// given title and body to the given
    /// FCM token.
    assert(topic != null || token != null);

    String accessToken = await credentials.obtainCredentials();
    try {
      http.Response r = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/ahbab-ba8d0/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': <String, dynamic>{
              'notification' : <String, dynamic> {
                'title' : title,
                'body' : body,
              },
              'android' : <String, dynamic> {
                'priority' : 'HIGH',
              },
              if(topic == null) 'token' : token,
              if(topic != null) 'topic' : topic,
            }
          },
        ),
      );

      return r.statusCode;
    } catch (e) {
      //print(e.toString());
      return 0;
    }
  }
}