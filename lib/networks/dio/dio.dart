import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'log.dart';

final class DioSingleton {
  static final DioSingleton _singleton = DioSingleton._internal();
  static CancelToken cancelToken = CancelToken();
  DioSingleton._internal();

  static DioSingleton get instance => _singleton;

  late Dio dio;
  bool isRefreshing = false;
  final List<Completer<String?>> refreshCompleters = [];
  PersistCookieJar? cookieJar;

  Future<void> create() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(storage: FileStorage("${appDocDir.path}/.cookies/"));

    BaseOptions options = BaseOptions(
        baseUrl: url!,
        connectTimeout: const Duration(milliseconds: 100000),
        receiveTimeout: const Duration(milliseconds: 100000),
        headers: {
          NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
          NetworkConstants.ACCEPT_LANGUAGE: appData.read(kKeyCountryCode) ?? "pt",
          NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
        });
    dio = Dio(options);
    dio.interceptors.add(CookieManager(cookieJar!));
    _addInterceptors(dio);
  }

  void update(String auth) {
    if (kDebugMode) {
      print("Dio update");
    }
    BaseOptions options = BaseOptions(
      baseUrl: url!,
      responseType: ResponseType.json,
      headers: {
        NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
        NetworkConstants.ACCEPT_LANGUAGE: appData.read(kKeyLanguage) ?? "pt",
        NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
        NetworkConstants.AUTHORIZATION: "Bearer $auth",
      },
      connectTimeout: const Duration(milliseconds: 100000),
      receiveTimeout: const Duration(milliseconds: 100000),
    );
    dio = Dio(options);
    if (cookieJar != null) {
      dio.interceptors.add(CookieManager(cookieJar!));
    }
    _addInterceptors(dio);
  }

  void updateLanguage(String countryCode) {
    if (kDebugMode) {
      print("Dio update $countryCode");
    }
    BaseOptions options = BaseOptions(
      baseUrl: url!,
      responseType: ResponseType.json,
      headers: {
        NetworkConstants.ACCEPT: NetworkConstants.ACCEPT_TYPE,
        NetworkConstants.ACCEPT_LANGUAGE: countryCode,
        NetworkConstants.APP_KEY: NetworkConstants.APP_KEY_VALUE,
        NetworkConstants.AUTHORIZATION: "Bearer ${appData.read(kKeyAccessToken)} ",
      },
      connectTimeout: const Duration(milliseconds: 100000),
      receiveTimeout: const Duration(milliseconds: 100000),
    );
    dio = Dio(options);
    if (cookieJar != null) {
      dio.interceptors.add(CookieManager(cookieJar!));
    }
    _addInterceptors(dio);
  }

  void _addInterceptors(Dio client) {
    client.interceptors.add(Logger());
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          final token = appData.read<String>(kKeyAccessToken) ?? '';
          if (token.isNotEmpty) {
            options.headers[NetworkConstants.AUTHORIZATION] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
            final path = error.requestOptions.path;
            if (path.contains("login") || path.contains("register") || path.contains("getRefreshToken")) {
              return handler.next(error);
            }

            final refreshToken = appData.read<String>('refresh_token') ?? '';
            if (refreshToken.isNotEmpty) {
              if (isRefreshing) {
                final completer = Completer<String?>();
                refreshCompleters.add(completer);
                final newAccessToken = await completer.future;
                if (newAccessToken != null) {
                  final options = error.requestOptions;
                  options.headers[NetworkConstants.AUTHORIZATION] = "Bearer $newAccessToken";
                  try {
                    final cloneReq = await dio.fetch(options);
                    return handler.resolve(cloneReq);
                  } catch (e) {
                    return handler.reject(DioException(requestOptions: options, error: e));
                  }
                }
              } else {
                isRefreshing = true;
                try {
                  final refreshDio = Dio(BaseOptions(
                    baseUrl: url!,
                    connectTimeout: const Duration(seconds: 5),
                    receiveTimeout: const Duration(seconds: 5),
                  ));
                  
                  Response? response;
                  final endpoints = [
                    'auth/token/refresh/',
                    'auth/refresh/',
                    'auth/login/refresh/',
                    'auth/getRefreshToken'
                  ];

                  for (final endpoint in endpoints) {
                    try {
                      response = await refreshDio.post(
                        endpoint,
                        data: {
                          "refresh": refreshToken,
                          "refresh_token": refreshToken,
                        },
                      );
                      if (response.statusCode == 200 || response.statusCode == 201) {
                        break;
                      }
                    } catch (e) {
                      if (kDebugMode) {
                        print("Token refresh failed for endpoint $endpoint: $e");
                      }
                    }
                  }

                  if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
                    final data = response.data;
                    final newAccessToken = (data['access_token'] ?? data['access'] ?? data['token'])?.toString() ?? '';
                    final newRefreshToken = (data['refresh_token'] ?? data['refresh'])?.toString() ?? '';
                    if (newAccessToken.isNotEmpty) {
                      await appData.write(kKeyAccessToken, newAccessToken);
                      if (newRefreshToken.isNotEmpty) {
                        await appData.write('refresh_token', newRefreshToken);
                      }
                      
                      dio.options.headers[NetworkConstants.AUTHORIZATION] = "Bearer $newAccessToken";
                      
                      for (final comp in refreshCompleters) {
                        comp.complete(newAccessToken);
                      }
                      refreshCompleters.clear();
                      isRefreshing = false;

                      final options = error.requestOptions;
                      options.headers[NetworkConstants.AUTHORIZATION] = "Bearer $newAccessToken";
                      final cloneReq = await dio.fetch(options);
                      return handler.resolve(cloneReq);
                    }
                  }
                  throw Exception("Invalid token response");
                } catch (e) {
                  for (final comp in refreshCompleters) {
                    comp.complete(null);
                  }
                  refreshCompleters.clear();
                  isRefreshing = false;
                  return handler.next(error);
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}

Future<Response> postHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.post(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> putHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.put(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> patchHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.patch(path, data: data, cancelToken: DioSingleton.cancelToken);

Future<Response> getHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.get(path, cancelToken: DioSingleton.cancelToken);

Future<Response> deleteHttp(String path, [dynamic data]) =>
    DioSingleton.instance.dio.delete(path, data: data, cancelToken: DioSingleton.cancelToken);
