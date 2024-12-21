import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';
import 'package:new_truotlo/src/database/landslide.dart';

// Hàm chính để hiển thị thông tin chi tiết điểm trượt lở
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

    // Gọi API lấy dữ liệu chi tiết
    final LandslideDatabase database = LandslideDatabase();
    final detail = await database.fetchLandslideDetail(landslideId);

    // Đóng loading indicator
    Navigator.of(context).pop();

    // Xử lý danh sách hình ảnh
    List<String> processedImages = [];
    if (detail['images'] != null) {
      processedImages = (detail['images'] as List).map((imagePath) {
        return 'https://truotlobinhdinh.girc.edu.vn/storage/$imagePath';
      }).toList();
    }

    // Hiển thị dialog với thông tin chi tiết
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
    // Đóng loading indicator nếu có lỗi
    Navigator.of(context).pop();
    
    // Hiển thị thông báo lỗi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Có lỗi xảy ra: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Widget cho phần header của dialog
Widget _buildDialogHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

// Widget hiển thị thông tin chi tiết
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

// Widget hiển thị một dòng thông tin
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

// Widget hiển thị phần hình ảnh
Widget _buildImageSection(BuildContext context, List<String> images) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Hình ảnh:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text('${images.length} hình'),
        ],
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

// Widget hiển thị một item hình ảnh
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
            errorWidget: (context, url, error) {
              print('Error loading image: $error for URL: $url');
              return Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Không thể tải hình',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

// Chức năng xem hình ảnh toàn màn hình
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
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          'Không thể tải hình',
                          style: TextStyle(
                            color: Colors.red[300],
                          ),
                        ),
                      ],
                    ),
                  ),
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
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black26,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SafeArea(
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
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}