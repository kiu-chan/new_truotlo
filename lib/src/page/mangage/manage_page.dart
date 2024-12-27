import 'package:flutter/material.dart';
import 'package:new_truotlo/src/data/manage/forecast.dart';
import 'package:new_truotlo/src/data/manage/hourly_warning.dart';
import 'package:new_truotlo/src/data/manage/landslide_point.dart';
import 'package:new_truotlo/src/database/database.dart';
import 'widgets/forecast_list.dart';
import 'widgets/hourly_warning_list.dart';
import 'widgets/landslide_point_list.dart';

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

  static const primaryBlue = Color(0xFF2196F3);
  static const darkBlue = Color(0xFF1976D2);
  static const surfaceBlue = Color(0xFFE3F2FD);

  late TabController _tabController;
  bool isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _initializeData();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      isLoading = true;
      _isError = false;
      _errorMessage = '';
    });
    
    try {
      await connectToDatabase();
      await Future.wait([
        _loadForecasts(),
        _loadHourlyWarnings(),
        _loadLandslidePoints(),
      ]);
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại.';
      });
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
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [darkBlue, primaryBlue],
              ),
            ),
            child: SafeArea(
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelPadding: EdgeInsets.zero,
                tabs: [
                  _buildTabIcon(
                    Icons.calendar_today,
                    'Dự báo',
                    _tabController.index == 0,
                  ),
                  _buildTabIcon(
                    Icons.access_time,
                    'Cảnh báo',
                    _tabController.index == 1,
                  ),
                  _buildTabIcon(
                    Icons.location_on,
                    'Điểm trượt lở',
                    _tabController.index == 2,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Đang tải dữ liệu...',
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _isError
                    ? _buildErrorView()
                    : RefreshIndicator(
                        color: primaryBlue,
                        onRefresh: _initializeData,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            ForecastList(
                              forecasts: forecasts,
                              database: database,
                              onDelete: (index) {
                                setState(() {
                                  forecasts.removeAt(index);
                                });
                              },
                            ),
                            HourlyWarningList(
                              hourlyWarnings: hourlyWarnings,
                              onDelete: (index) {
                                setState(() {
                                  hourlyWarnings.removeAt(index);
                                });
                              },
                            ),
                            LandslidePointList(
                              landslidePoints: landslidePoints,
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }
}