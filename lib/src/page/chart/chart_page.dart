// lib/src/page/chart/chart_page.dart

import 'package:flutter/material.dart';
import 'package:new_truotlo/src/data/chart/chart_data.dart';
import 'package:new_truotlo/src/data/chart/landslide_data.dart';
import 'package:new_truotlo/src/data/chart/rainfall_data.dart';
import 'package:new_truotlo/src/database/landslide.dart';
import 'package:new_truotlo/src/page/chart/chart_app_bar.dart';
import 'package:new_truotlo/src/page/chart/chart_body.dart';
import 'package:new_truotlo/src/page/chart/chart_drawer.dart';
import 'package:new_truotlo/src/page/chart/elements/chart_menu.dart';
import 'package:new_truotlo/src/page/map/widgets/map_loading.dart';
import 'package:new_truotlo/src/user/auth_service.dart';
import 'package:new_truotlo/src/page/chart/elements/chart_data_processor.dart';
import 'package:new_truotlo/src/page/chart/elements/chart_utils.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {
  final LandslideDatabase _dataService = LandslideDatabase();
  final ChartDataProcessor _dataProcessor = ChartDataProcessor();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Data states
  List<LandslideDataModel> _allData = [];
  List<LandslideDataModel> _filteredData = [];
  List<RainfallData> _rainfallData = [];
  List<ChartData> _chartDataList = [];
  
  // UI states  
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _error = '';
  String _selectedChart = '';
  bool _showLegend = true;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final Map<int, bool> _lineVisibility = {};
  
  // User states
  bool _isAdmin = false;
  
  @override
  void initState() {
    super.initState();
    _fetchUserRoleAndData();
  }

  Future<void> _fetchUserRoleAndData() async {
    try {
      final role = await UserPreferences.getUserRole();
      final isLoggedIn = await UserPreferences.isLoggedIn();
      if (mounted) {
        setState(() {
          _isAdmin = isLoggedIn && role == 'admin';
        });
        await _fetchData(showLoadingIndicator: true);
      }
    } catch (e) {
      _handleError('Lỗi khi lấy dữ liệu người dùng: $e');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _error = message;
        _isLoading = false;
        _isRefreshing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _fetchData({bool showLoadingIndicator = false}) async {
    if (!mounted) return;

    setState(() {
      if (showLoadingIndicator) {
        _isLoading = true;
      } else {
        _isRefreshing = true; 
      }
      _error = '';
      
      // Clear existing data
      _allData = [];
      _rainfallData = [];
      _filteredData = [];
      _chartDataList = [];
    });

    try {
      final landslideFuture = _dataService.fetchLandslideData(
        startDate: _startDateTime,
        endDate: _endDateTime,
      );
      
      final rainfallFuture = RainfallDataService.fetchRainfallData(
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
      );

      final results = await Future.wait([landslideFuture, rainfallFuture]);
      
      final landslideData = results[0] as List<LandslideDataModel>;
      final rainfallData = results[1] as List<RainfallData>;

      if (!mounted) return;

      if (landslideData.isEmpty && rainfallData.isEmpty) {
        _handleError('Không có dữ liệu trong khoảng thời gian đã chọn');
        return;
      }

      setState(() {
        _allData = landslideData;
        _rainfallData = rainfallData;
        _filterDataBasedOnUserRole();
        _processData();
        
        if (_lineVisibility.isEmpty) {
          ChartUtils.initLineVisibility(_lineVisibility, _filteredData.length);
        }
        
        if (_selectedChart.isEmpty || !_chartDataList.any((chart) => chart.name == _selectedChart)) {
          _selectedChart = _chartDataList.isNotEmpty ? _chartDataList[0].name : '';
        }
        
        _isLoading = false;
        _isRefreshing = false;
      });

    } catch (e) {
      _handleError('Lỗi khi tải dữ liệu vui lòng thử lại sau');
    }
  }

  void _filterDataBasedOnUserRole() {
    _filteredData = ChartUtils.filterDataBasedOnUserRole(_allData, _isAdmin);
    if (!_isAdmin && _startDateTime == null && _endDateTime == null) {
      _rainfallData = ChartUtils.filterRainfallDataBasedOnUserRole(_rainfallData, _isAdmin);
    }
  }

  void _processData() {
    _chartDataList = _dataProcessor.processData(_filteredData, _rainfallData);
  }

  Future<void> _selectDateTimeRange() async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDateTime != null && _endDateTime != null
          ? DateTimeRange(start: _startDateTime!, end: _endDateTime!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null && mounted) {
      final startDateTime = DateTime(
        dateRange.start.year,
        dateRange.start.month,
        dateRange.start.day,
      );

      final endDateTime = DateTime(
        dateRange.end.year,
        dateRange.end.month,
        dateRange.end.day,
        23,
        59,
        59,
      );

      setState(() {
        _startDateTime = startDateTime;
        _endDateTime = endDateTime;
      });

      await _fetchData(showLoadingIndicator: true);
    }
  }

  void _toggleLineVisibility(int index) {
    setState(() {
      _lineVisibility[index] = !(_lineVisibility[index] ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: ChartAppBar(
        isRefreshing: _isRefreshing,
        onRefresh: _fetchData,
        scaffoldKey: _scaffoldKey,
      ),
      endDrawer: ChartDrawerWidget(
        chartNames: _chartDataList.map((c) => c.name).toList(),
        selectedChart: _selectedChart,
        showLegend: _showLegend,
        onChartTypeChanged: (value) {
          setState(() {
            _selectedChart = value;
          });
          Navigator.pop(context);
        },
        onShowLegendChanged: (value) {
          setState(() {
            _showLegend = value;
          });
        },
        isAdmin: _isAdmin,
        onDateRangeSelect: _selectDateTimeRange,
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
      ),
      body: ChartBody(
        isLoading: _isLoading,
        error: _error,
        fetchData: _fetchData,
        chartDataList: _chartDataList,
        selectedChart: _selectedChart,
        showLegend: _showLegend,
        lineVisibility: _lineVisibility,
        filteredData: _filteredData,
        isAdmin: _isAdmin,
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        onDateRangeSelect: _selectDateTimeRange,
        onToggleLineVisibility: _toggleLineVisibility,
      ),
    );
  }

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    super.dispose();
  }
}