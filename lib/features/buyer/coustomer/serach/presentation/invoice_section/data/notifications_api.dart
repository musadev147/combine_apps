import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/notification_model.dart';

class NotificationsApi {
  static final NotificationsApi _singleton = NotificationsApi._internal();
  NotificationsApi._internal();
  static NotificationsApi get instance => _singleton;

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await getHttp(Endpoints.notifications());

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data as List<dynamic>? ?? [];
        return dataList
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH NOTIFICATIONS API ERROR: $error");
      rethrow;
    }
  }
}
