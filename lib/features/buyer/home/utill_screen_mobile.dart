import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/helpers/navigation_service.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:bd_shope_combined/constants/custom_theme.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/helpers/helper_methods.dart';
import 'package:bd_shope_combined/helpers/register_provider.dart';

class UtillScreenMobile extends StatelessWidget {
  const UtillScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          // You can set the initial route here if needed, but Home is already set via AppPages
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          builder: EasyLoading.init(),
        );
      },
    );
  }
}
