import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/notification.dart';

class NotificationService {
  Future<List<NotificationModel>> getNotificationsFromUser(receptorId) async {
    try{
      final List<Map<String, dynamic>> rawNotifications =
          await ApiService().getNotificationsFromUser(receptorId);

      return rawNotifications.map((data) => NotificationModel.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error en getNotificationsFromUser: $e');
      return [];
    }
  }
}
