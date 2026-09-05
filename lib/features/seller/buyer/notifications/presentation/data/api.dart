import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/buyer/notifications/presentation/model/model.dart';

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
      log("FETCH NOTIFICATIONS API ERROR: $error - Falling back to short notes");
      try {
        // Fallback: If notifications API is missing (404), fetch short notes and convert them
        final shortNotes = await getHttp(Endpoints.shortNotes());
        if (shortNotes.statusCode == 200 || shortNotes.statusCode == 201) {
          final data = shortNotes.data;
          List<dynamic> results = [];
          if (data is List) {
            results = data;
          } else if (data is Map && data.containsKey('results')) {
            results = data['results'] as List<dynamic>;
          }
          
          return results.map((item) {
             return NotificationModel(
               id: item['id'] != null ? int.tryParse(item['id'].toString()) ?? 0 : 0,
               title: "New Short Note",
               body: "Invoice for '${item['product_name'] ?? 'Item'}' received.",
               createdAt: item['created_at'],
               type: 'short_notes',
               isRead: false,
             );
          }).toList();
        }
      } catch (fallbackError) {
         log("FETCH NOTIFICATIONS FALLBACK ERROR: $fallbackError");
      }
      return []; // Return empty list instead of crashing if both fail
    }
  }
}
