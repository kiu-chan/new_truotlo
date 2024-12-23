// lib/src/page/map/widgets/landslide_info_dialog.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';
import 'package:new_truotlo/src/database/landslide.dart';
import 'package:new_truotlo/src/data/forecast/hourly_forecast_response.dart';
import 'package:new_truotlo/src/data/forecast/hourly_forecast_point.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class RiskLevel {
  final Color color;
  final String level;
  final String value;

  RiskLevel(this.color, this.level, this.value);
}

Future<void> showLandslideInfoDialog(BuildContext context, int landslideId) async {
  try {
    // Hiển thị loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Lấy dữ liệu từ database
    final LandslideDatabase database = LandslideDatabase();
    final responses = await Future.wait([
      database.fetchLandslideDetail(landslideId),
      database.fetchHourlyForecastPoints(),
    ]);

    final detail = responses[0] as Map<String, dynamic>;
    final forecastResponse = responses[1] as HourlyForecastResponse;

    Navigator.of(context).pop(); // Đóng loading indicator

    // Xử lý danh sách hình ảnh
    List<String> processedImages = [];
    if (detail['images'] != null) {
      processedImages = (detail['images'] as List).map((imagePath) {
        return 'https://truotlobinhdinh.girc.edu.vn/storage/$imagePath';
      }).toList();
    }

    // Lấy dữ liệu cảnh báo mới nhất
    Map<String, dynamic>? warningData;
    if (forecastResponse.data.isNotEmpty) {
      final latestHourKey = forecastResponse.data.keys.first;
      final latestHourData = forecastResponse.data[latestHourKey] ?? [];
      try {
        final matchingPoint = latestHourData.firstWhere(
          (point) => point.landslideId == landslideId,
        );
        warningData = matchingPoint.toJson();
      } catch (e) {
        warningData = null;
      }
    }

    if (!context.mounted) return;

    // Hiển thị dialog thông tin
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(detail),
                      if (warningData != null) ...[
                        const SizedBox(height: 16),
                        _buildWarningSection(warningData),
                      ],
                      const SizedBox(height: 16),
                      _buildDirectionsButton(context, detail),
                      if (processedImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildImageSection(context, processedImages),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Có lỗi xảy ra: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

Widget _buildDialogHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(4),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Thông tin điểm trượt lở',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}

Widget _buildInfoSection(Map<String, dynamic> detail) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow('ID', '${detail['id']}'),
      _buildInfoRow('Quận/Huyện', detail['district_name'] ?? ''),
      _buildInfoRow('Xã/Phường', detail['commune_name'] ?? ''),
      _buildInfoRow('Vị trí', detail['vi_tri'] ?? ''),
      _buildInfoRow('Tọa độ', '${detail['lat']}, ${detail['lon']}'),
      _buildInfoRow('Mô tả', detail['mo_ta'] ?? ''),
    ],
  );
}

Widget _buildWarningSection(Map<String, dynamic> warningData) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          'Cảnh báo hiện tại:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      _buildWarningRow(
        'Nguy cơ lũ quét',
        _getRiskLevel(warningData['nguy_co_lu_quet']),
      ),
      _buildWarningRow(
        'Nguy cơ trượt nông',
        _getRiskLevel(warningData['nguy_co_truot_nong']),
      ),
      _buildWarningRow(
        'Nguy cơ trượt lớn',
        _getRiskLevel(warningData['nguy_co_truot_lon']),
      ),
      const SizedBox(height: 4),
      Text(
        'Cập nhật: ${warningData['created_at']}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    ],
  );
}

Widget _buildWarningRow(String label, RiskLevel risk) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: risk.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: risk.color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                risk.value,
                style: TextStyle(
                  color: risk.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${risk.level})',
                style: TextStyle(
                  color: risk.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDirectionsButton(BuildContext context, Map<String, dynamic> detail) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: ElevatedButton.icon(
      onPressed: () => _openGoogleMaps(context, detail),
      icon: const Icon(Icons.directions),
      label: const Text('Chỉ đường đến điểm này'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    ),
  );
}

Widget _buildImageSection(BuildContext context, List<String> images) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Hình ảnh:',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          itemBuilder: (context, index) => _buildImageItem(
            context,
            images[index],
            () => _showFullScreenImage(context, images, index),
          ),
        ),
      ),
    ],
  );
}

Widget _buildImageItem(BuildContext context, String imageUrl, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void _showFullScreenImage(BuildContext context, List<String> images, int initialIndex) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(images[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              itemCount: images.length,
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              pageController: PageController(initialPage: initialIndex),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hình ${initialIndex + 1}/${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _openGoogleMaps(BuildContext context, Map<String, dynamic> detail) async {
  try {
    // Kiểm tra quyền truy cập vị trí
    final permission = await Permission.location.status;
    if (permission.isDenied) {
      if (context.mounted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Yêu cầu quyền truy cập'),
            content: const Text('Ứng dụng cần quyền truy cập vị trí để tìm đường đi.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Đồng ý'),
              ),
            ],
          ),
        );
        if (result != true) return;
        await Permission.location.request();
      }
    }

    // Lấy vị trí hiện tại
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
    }

    // Tạo URL cho Google Maps
    final double destLat = double.parse(detail['lat'].toString());
    final double destLon = double.parse(detail['lon'].toString());
    String url;

    if (currentPosition != null) {
      // URL với điểm bắt đầu và điểm đến
      url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=${currentPosition.latitude},${currentPosition.longitude}'
          '&destination=$destLat,$destLon'
          '&travelmode=driving';
    } else {
      // URL chỉ với điểm đến
      url = 'https://www.google.com/maps/search/?api=1&query=$destLat,$destLon';
    }

    // Mở Google Maps
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

RiskLevel _getRiskLevel(dynamic value) {
  try {
    final level = double.parse(value.toString());
    if (level >= 5) {
      return RiskLevel(Colors.purple, 'Rất cao', value.toString());
    } else if (level >= 4) {
      return RiskLevel(Colors.red, 'Cao', value.toString());
    } else if (level >= 3) {
      return RiskLevel(Colors.yellow[700]!, 'Trung bình', value.toString());
    } else if (level >= 2) {
      return RiskLevel(Colors.green, 'Thấp', value.toString());
    } else if (level > 1) {
      return RiskLevel(Colors.blue, 'Rất thấp', value.toString());
    } else {
      return RiskLevel(Colors.grey, 'Không có', 'N/A');
    }
  } catch (e) {
    return RiskLevel(Colors.grey, 'Không xác định', 'N/A');
  }
}