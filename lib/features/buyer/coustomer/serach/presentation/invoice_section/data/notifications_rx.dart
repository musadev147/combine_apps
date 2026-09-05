import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/notification_model.dart';
import 'notifications_api.dart';

class GetNotificationsRx extends RxResponseInt<List<NotificationModel>> {
  final api = NotificationsApi.instance;

  GetNotificationsRx({required super.empty, required super.dataFetcher});

  ValueStream<List<NotificationModel>> get valueStreamData => dataFetcher.stream;

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      List<NotificationModel> data = await api.fetchNotifications();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  List<NotificationModel> handleSuccessWithReturn(List<NotificationModel> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  List<NotificationModel> handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return [];
  }
}
