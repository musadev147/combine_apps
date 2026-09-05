
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';

Future<void> totalDataClean() async {
  await appData.write(kKeyIsLoggedIn, false);
  await appData.write(kKeyIsExploring, false);
  await appData.remove(kKeyUserName);
  await appData.remove(kKeyUserID);
  await appData.remove(kKeyAccessToken);
  // cleanLoginData();
}

void cleanLoginData() {
}
