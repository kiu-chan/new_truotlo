import 'package:flutter/material.dart';
import 'package:new_truotlo/src/data/manage/forecast.dart';
import 'package:new_truotlo/src/data/manage/hourly_warning.dart';
import 'package:new_truotlo/src/data/manage/landslide_point.dart';
import 'package:new_truotlo/src/database/database.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  ManagePageState createState() => ManagePageState();
}

class ManagePageState extends State<ManagePage> with SingleTickerProviderStateMixin {
  final DefaultDatabase database = DefaultDatabase();
  List<Forecast> forecasts = [];
  List<HourlyWarning> hourlyWarnings = [];
  List<ManageLandslidePoint> landslidePoints = [];

  late TabController _tabController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    try {
      await connectToDatabase();
      await Future.wait([
        _loadForecasts(),
        _loadHourlyWarnings(),
        _loadLandslidePoints(),
      ]);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> connectToDatabase() async {
    await database.connect();
  }

  Future<void> _loadForecasts() async {
    try {
      forecasts = await database.fetchForecasts();
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải dự báo: $e');
    }
  }

  Future<void> _loadHourlyWarnings() async {
    try {
      hourlyWarnings = await database.fetchHourlyWarnings();
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải cảnh báo theo giờ: $e');
    }
  }

  Future<void> _loadLandslidePoints() async {
    try {
      landslidePoints = await database.fetchListLandslidePoints();
      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải điểm trượt lở: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Quản lý',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(
                  icon: Icon(Icons.calendar_today),
                  text: 'Dự báo',
                ),
                Tab(
                  icon: Icon(Icons.access_time),
                  text: 'Cảnh báo',
                ),
                Tab(
                  icon: Icon(Icons.location_on),
                  text: 'Điểm trượt lở',
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _initializeData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildForecastList(forecasts),
                  buildHourlyWarningList(hourlyWarnings),
                  buildLandslidePointList(landslidePoints),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng thêm mới đang được phát triển'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm mới'),
      ),
    );
  }

  Widget buildForecastList(List<Forecast> forecasts) {
    if (forecasts.isEmpty) {
      return const Center(
        child: Text('Chưa có dự báo nào'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: forecasts.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              forecasts[index].name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'Xem chi tiết',
                  onPressed: () => showForecastDetails(forecasts[index].id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Xóa',
                  onPressed: () => deleteForecast(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildHourlyWarningList(List<HourlyWarning> hourlyWarnings) {
    if (hourlyWarnings.isEmpty) {
      return const Center(
        child: Text('Chưa có cảnh báo nào'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: hourlyWarnings.length,
      itemBuilder: (context, index) {
        final warning = hourlyWarnings[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              warning.formattedDate,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        warning.location,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'Xem chi tiết',
                  onPressed: () => showHourlyWarningDetails(warning),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Xóa',
                  onPressed: () => deleteHourlyWarning(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildLandslidePointList(List<ManageLandslidePoint> landslidePoints) {
    if (landslidePoints.isEmpty) {
      return const Center(
        child: Text('Chưa có điểm trượt lở nào'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: landslidePoints.length,
      itemBuilder: (context, index) {
        final point = landslidePoints[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              point.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.code, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Mã: ${point.code}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.blue),
              tooltip: 'Thông tin chi tiết',
              onPressed: () => showLandslidePointDetails(point),
            ),
          ),
        );
      },
    );
  }

  void showForecastDetails(int forecastId) async {
    try {
      final detail = await database.landslideDatabase.fetchForecastDetail(forecastId);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Chi tiết dự báo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Tên điểm:', detail.tenDiem),
                  _buildDetailRow('Vị trí:', detail.viTri),
                  _buildDetailRow('Kinh độ:', detail.kinhDo as String),
                  _buildDetailRow('Vĩ độ:', detail.viDo as String),
                  _buildDetailRow('Tỉnh:', detail.tinh),
                  _buildDetailRow('Huyện:', detail.huyen),
                  _buildDetailRow('Xã:', detail.xa),
                  const SizedBox(height: 16),
                  const Text(
                    'Dự báo các ngày:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...detail.days.map((day) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Ngày ${day.day} (${day.date.day}/${day.date.month}/${day.date.year}) - Nguy cơ: ${day.riskLevel}',
                    ),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Đóng'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      );
    } catch (e) {
      _showErrorSnackBar('Lỗi khi tải chi tiết dự báo: $e');
    }
  }

  void showHourlyWarningDetails(HourlyWarning warning) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cảnh báo ${warning.formattedDate}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Vị trí:', warning.location),
                _buildDetailRow('Mức độ cảnh báo:', warning.warningLevel),
                _buildDetailRow('Mô tả:', warning.description),
                _buildDetailRow('Vĩ độ:', warning.lat.toString()),
                _buildDetailRow('Kinh độ:', warning.lon.toString()),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Đóng'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void showLandslidePointDetails(ManageLandslidePoint point) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            point.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Mã:', point.code),
                _buildDetailRow('Vĩ độ:', point.latitude.toString()),
                _buildDetailRow('Kinh độ:', point.longitude.toString()),
                _buildDetailRow('Mô tả:', point.description),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Đóng'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteForecast(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn xóa dự báo này?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                setState(() {
                  forecasts.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa dự báo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void deleteHourlyWarning(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Bạn có chắc chắn muốn xóa cảnh báo này?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                setState(() {
                  hourlyWarnings.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa cảnh báo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}