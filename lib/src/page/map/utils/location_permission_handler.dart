// lib/src/utils/location_permission_handler.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionHandler {
  // Kiểm tra và xử lý quyền truy cập vị trí
  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra dịch vụ vị trí có được bật không
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Dịch vụ vị trí đang tắt',
          'Vui lòng bật dịch vụ vị trí trên thiết bị của bạn để sử dụng tính năng này.',
          onConfirm: () async {
            // Mở cài đặt vị trí
            await Geolocator.openLocationSettings();
          },
        );
      }
      return false;
    }

    // Kiểm tra quyền truy cập vị trí
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Yêu cầu quyền lần đầu
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          _showPermissionDialog(
            context,
            'Quyền truy cập vị trí bị từ chối',
            'Ứng dụng cần quyền truy cập vị trí để hiển thị vị trí của bạn trên bản đồ.',
            onConfirm: () async {
              permission = await Geolocator.requestPermission();
            },
          );
        }
        return false;
      }
    }

    // Xử lý trường hợp quyền bị từ chối vĩnh viễn
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Quyền truy cập vị trí bị chặn',
          'Vui lòng vào Cài đặt để cấp quyền truy cập vị trí cho ứng dụng.',
          onConfirm: () async {
            await openAppSettings();
          },
        );
      }
      return false;
    }

    return true;
  }

  // Hiển thị dialog thông báo về quyền
  static Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String content, {
    required Function() onConfirm,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Hủy'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          TextButton(
            child: const Text('Đồng ý'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
          ),
        ],
      ),
    );
  }

  // Kiểm tra trạng thái quyền vị trí hiện tại
  static Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }
}