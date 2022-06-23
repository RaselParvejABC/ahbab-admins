import 'package:ahbabadmin/utilities/for_json.dart';
import "package:googleapis_auth/auth_io.dart";
import "package:http/http.dart" as http;


// Use service account credentials to obtain oauth credentials.
Future<String> obtainCredentials() async {
  var accountCredentials = ServiceAccountCredentials.fromJson(
    await readJsonFileFromAsset('assets/service-account.json')
  );
  var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  var client = http.Client();
  AccessCredentials credentials =
  await obtainAccessCredentialsViaServiceAccount(accountCredentials, scopes, client);

  client.close();
  return credentials.accessToken.data;
}