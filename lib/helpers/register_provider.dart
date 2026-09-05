
import 'package:provider/provider.dart';

import 'package:bd_shope_combined/common_wigdets/custom_theme.dart';
import 'package:bd_shope_combined/provider/carosul_provider.dart';
import 'package:bd_shope_combined/provider/forget_password_provider.dart';
import 'package:bd_shope_combined/provider/profile_provider.dart';
import 'package:bd_shope_combined/provider/singnup_provider.dart';

var providers = [
  ChangeNotifierProvider<ForgetPasswordProvider>(
    create: ((context) => ForgetPasswordProvider()),
  ),

  ChangeNotifierProvider<SignupProvider>(
    create: ((context) => SignupProvider()),
  ),

  ChangeNotifierProvider<ProfileProvider>(
    create: ((context) => ProfileProvider()),
  ),

  ChangeNotifierProvider<CarosulProvider>(
    create: ((context) => CarosulProvider()),
  ),

  ChangeNotifierProvider<CustomThemeProvider>(
    create: ((context) => CustomThemeProvider()),
  ),
];
