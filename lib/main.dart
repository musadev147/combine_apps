import 'package:auto_animated/auto_animated.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/buyer/coustomer/serach/presentation/invoice_section/data/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';

import 'helpers/di.dart';
import 'helpers/helper_methods.dart';
import 'helpers/navigation_service.dart';
import 'helpers/register_provider.dart';
import 'networks/dio/dio.dart';
import 'constants/custom_theme.dart';

import 'services/web_socket_service.dart';
import 'services/agora_service.dart';
import 'controllers/connection_controller.dart';
import 'controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await GetStorage.init();
  diSetup();
  initiInternetChecker();

  Get.put(WebSocketService());
  Get.put(AgoraService());
  Get.put(ConnectionController());
  Get.put(ThemeController());

  configLoading();

  runApp(MyApp());

  // Non-blocking background initialization after UI launches
  Future.microtask(() async {
    try {
      await DioSingleton.instance.create();
      await NotificationService.instance.init();
    } catch (_) {}
  });
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(seconds: 3)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 40.0
    ..radius = 10.0
    ..maskType = EasyLoadingMaskType.none
    ..toastPosition = EasyLoadingToastPosition.top
    ..backgroundColor = const Color(0xFF00F0FF)
    ..textColor = Colors.white
    ..indicatorColor = Colors.white
    ..userInteractions = true
    ..dismissOnTap = true;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    rotation();
    setInitValue();
    return MultiProvider(
      providers: providers,
      child: AnimateIfVisibleWrapper(
        showItemInterval: const Duration(milliseconds: 150),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return const UtillScreenMobile();
          },
        ),
      ),
    );
  }
}

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
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          showPerformanceOverlay: false,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: AppColors.white,
            ),
            primarySwatch: CustomTheme.kToDark,
            scaffoldBackgroundColor: AppColors.white,
            useMaterial3: false,
          ),
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          // Register the shared observer so RouteAware.didPopNext fires on
          // every screen that subscribes (e.g. AstTenantListScreen).
          // navigatorObservers: [routeObserver],
          // home: SplashScreen(),

          builder: EasyLoading.init(),
        );
      },
    );
  }
}
