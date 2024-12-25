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
      print('Lỗi khi tải dự báo: $e');
    }
  }

  Future<void> _loadHourlyWarnings() async {
    try {
      hourlyWarnings = await database.fetchHourlyWarnings();
      setState(() {});
    } catch (e) {
      print('Lỗi khi tải cảnh báo theo giờ: $e');
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
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}