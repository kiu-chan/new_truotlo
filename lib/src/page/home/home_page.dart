import 'package:flutter/material.dart';
import 'package:new_truotlo/src/config/api.dart';
import 'package:new_truotlo/src/config/weather.dart';
import 'package:new_truotlo/src/data/weather/location_data.dart';
import 'package:new_truotlo/src/data/weather/weather_district.dart';
import 'package:new_truotlo/src/database/home.dart';
import 'package:new_truotlo/src/page/home/elements/landslide/landslide_forecast_card.dart';
import 'package:new_truotlo/src/page/home/elements/reference_detail_page.dart';
import 'package:new_truotlo/src/page/home/elements/warning.dart';
import 'package:new_truotlo/src/page/home/elements/weather/weather_forecast_card.dart';
import 'package:new_truotlo/src/page/home/elements/weather/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final WeatherService weatherService = WeatherService(
    apiKey: WeatherConfig().apiKey,
    baseUrl: WeatherConfig().baseUrl,
  );
  final HomeDatabase homeDatabase = HomeDatabase();
  final ApiConfig apiConfig = ApiConfig();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? currentWeather;
  Map<String, dynamic>? forecast;
  late WeatherDistrict selectedDistrict;
  late Ward selectedWard;
  String? errorMessage;
  bool isLoading = false;
  List<dynamic> references = [];

  @override
  void initState() {
    super.initState();
    selectedDistrict = districts.first;
    selectedWard = selectedDistrict.wards.first;
    _fetchWeatherData();
    _fetchReferences();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeatherData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final weatherData = await weatherService.getWeatherByCoordinates(
        selectedWard.latitude,
        selectedWard.longitude,
      );
      final forecastData = await weatherService.getForecastByCoordinates(
        selectedWard.latitude,
        selectedWard.longitude,
      );

      if (!mounted) return;

      setState(() {
        currentWeather = weatherData;
        forecast = forecastData;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Không thể tải dữ liệu thời tiết. Vui lòng thử lại sau.';
        isLoading = false;
      });
      print('Error fetching weather data: $e');
    }
  }

  Future<void> _fetchReferences() async {
    try {
      final fetchedReferences = await homeDatabase.fetchReferences();
      if (mounted) {
        setState(() {
          references = fetchedReferences;
        });
      }
    } catch (e) {
      print('Error fetching references: $e');
    }
  }

  Future<void> _onReferenceClicked(int id) async {
    try {
      await homeDatabase.incrementViews(id);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReferenceDetailPage(id: id),
        ),
      );
      await _fetchReferences();
    } catch (e) {
      print('Error handling reference click: $e');
    }
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferencesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.library_books, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Tài liệu tham khảo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: references.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final reference = references[index];
              final imageUrl = '${apiConfig.getImgUrl()}/${reference['file_path']}';
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onReferenceClicked(reference['id']),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error_outline, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reference['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ngày đăng: ${reference['published_at']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.remove_red_eye,
                                      size: 16, color: Colors.blue.shade300),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${reference['views']} lượt xem',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchWeatherData();
          await _fetchReferences();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMessage != null) _buildErrorBanner(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WeatherForecastCard(
                  currentWeather: currentWeather,
                  forecast: forecast,
                  selectedDistrict: selectedDistrict,
                  selectedWard: selectedWard,
                  isLoading: isLoading,
                  districts: districts,
                  onDistrictChanged: (WeatherDistrict? newDistrict) {
                    if (newDistrict != null) {
                      setState(() {
                        selectedDistrict = newDistrict;
                        selectedWard = newDistrict.wards.first;
                      });
                      _fetchWeatherData();
                    }
                  },
                  onWardChanged: (Ward? newWard) {
                    if (newWard != null) {
                      setState(() {
                        selectedWard = newWard;
                      });
                      _fetchWeatherData();
                    }
                  },
                  onRetry: _fetchWeatherData,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DisasterWarningCard(),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: LandslideForecastCard(),
              ),
              const SizedBox(height: 16),
              _buildReferencesList(),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Designed by GIRC - TUAF',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}