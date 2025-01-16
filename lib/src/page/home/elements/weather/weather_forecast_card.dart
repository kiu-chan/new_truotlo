import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_truotlo/src/data/weather/weather_district.dart';

class WeatherForecastCard extends StatelessWidget {
  final Map<String, dynamic>? currentWeather;
  final Map<String, dynamic>? forecast;
  final WeatherDistrict selectedDistrict;
  final Ward selectedWard;
  final bool isLoading;
  final List<WeatherDistrict> districts;
  final Function(WeatherDistrict?) onDistrictChanged;
  final Function(Ward?) onWardChanged;
  final VoidCallback onRetry;

  const WeatherForecastCard({
    super.key,
    required this.currentWeather,
    required this.forecast,
    required this.selectedDistrict,
    required this.selectedWard,
    required this.isLoading,
    required this.districts,
    required this.onDistrictChanged,
    required this.onWardChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
            stops: [0.0, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DỰ BÁO THỜI TIẾT (THEO OPENWEATHERMAP)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildLocationSelectors(),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else if (currentWeather == null || forecast == null)
                _buildErrorState()
              else
                _buildWeatherInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelectors() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<WeatherDistrict>(
            value: selectedDistrict,
            decoration: InputDecoration(
              labelText: 'Quận/Huyện',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            dropdownColor: const Color(0xFF2196F3),
            style: const TextStyle(color: Colors.white),
            items: districts.map((WeatherDistrict district) {
              return DropdownMenuItem<WeatherDistrict>(
                value: district,
                child: Text(district.name),
              );
            }).toList(),
            onChanged: onDistrictChanged,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Ward>(
            value: selectedWard,
            decoration: InputDecoration(
              labelText: 'Phường/Xã',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            dropdownColor: const Color(0xFF2196F3),
            style: const TextStyle(color: Colors.white),
            items: selectedDistrict.wards.map((Ward ward) {
              return DropdownMenuItem<Ward>(
                value: ward,
                child: Text(ward.name),
              );
            }).toList(),
            onChanged: onWardChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Không thể tải dữ liệu thời tiết',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2196F3),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    final temp = currentWeather!['main']['temp'];
    final humidity = currentWeather!['main']['humidity'];
    final windSpeed = currentWeather!['wind']['speed'];
    final description = currentWeather!['weather'][0]['description'];
    final iconPath = currentWeather!['iconPath'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedWard.name}, ${selectedDistrict.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      iconPath,
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${temp.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildWeatherDetail(Icons.water_drop, '$humidity%', 'Độ ẩm'),
                        const SizedBox(height: 8),
                        _buildWeatherDetail(
                          Icons.air,
                          '${windSpeed.toStringAsFixed(1)} m/s',
                          'Tốc độ gió',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dự báo 5 ngày tới',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildForecastDays(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildForecastDays() {
    final List<Widget> forecastWidgets = [];
    final List<dynamic> forecastList = forecast!['list'];

    for (int i = 0; i < 5; i++) {
      final dailyForecast = forecastList[i * 8];
      final temp = dailyForecast['main']['temp'];
      final date = DateTime.fromMillisecondsSinceEpoch(dailyForecast['dt'] * 1000);
      final dayName = DateFormat('E').format(date);
      final iconCode = dailyForecast['weather'][0]['icon'];
      final iconPath = 'lib/assets/clouds/$iconCode.png';

      forecastWidgets.add(
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(12),
          width: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  iconPath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${temp.toStringAsFixed(1)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return forecastWidgets;
  }
}