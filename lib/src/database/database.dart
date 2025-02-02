import 'package:latlong2/latlong.dart';
import 'package:new_truotlo/src/data/account/user.dart';
import 'package:new_truotlo/src/data/forecast/hourly_forecast_response.dart';
import 'package:new_truotlo/src/data/manage/forecast.dart';
import 'package:new_truotlo/src/data/manage/hourly_warning.dart';
import 'package:new_truotlo/src/data/manage/landslide_point.dart';
import 'package:new_truotlo/src/data/map/commune.dart';
import 'package:new_truotlo/src/data/map/district_data.dart';
import 'package:new_truotlo/src/data/map/landslide_point.dart';
import 'package:new_truotlo/src/database/account.dart';
import 'package:new_truotlo/src/database/border.dart';
import 'package:new_truotlo/src/database/district.dart';
import 'package:new_truotlo/src/database/commune.dart';
import 'package:new_truotlo/src/database/landslide.dart';
import 'package:new_truotlo/src/database/about.dart';

class DefaultDatabase {
  bool _connectionFailed = false;

  late BorderDatabase borderDatabase;
  late DistrictDatabase districtDatabase;
  late CommuneDatabase communeDatabase;
  late LandslideDatabase landslideDatabase;
  late AccountQueries accountQueries;
  late AboutDatabase aboutDatabase;


  Future<void> connect() async {
    try {
      _connectionFailed = false;

      borderDatabase = BorderDatabase();
      districtDatabase = DistrictDatabase();
      communeDatabase = CommuneDatabase();
      landslideDatabase = LandslideDatabase();
      accountQueries = AccountQueries();
      aboutDatabase = AboutDatabase();
    } catch (e) {
      print('Failed to connect to database: $e');
      _connectionFailed = true;
    }
  }

  bool get connectionFailed => _connectionFailed;

  Future<List<List<LatLng>>> fetchAndParseGeometry() async {
    return await borderDatabase.fetchAndParseGeometry();
  }

  Future<List<District>> fetchDistrictsData() async {
    return await districtDatabase.fetchDistrictsData();
  }

  Future<List<Commune>> fetchCommunesData() async {
    return await communeDatabase.fetchCommunesData();
  }

  Future<List<LandslidePoint>> fetchLandslidePoints() async {
    return await landslideDatabase.fetchLandslidePoints();
  }

  Future<User?> login(String email, String password) async {
    return await accountQueries.login(email, password);
  }

  Future<List<HourlyWarning>> fetchHourlyWarnings() async {
    return await landslideDatabase.fetchHourlyWarnings();
  }

  Future<List<Forecast>> fetchForecasts() async {
    return await landslideDatabase.fetchForecasts();
  }

  Future<List<ManageLandslidePoint>> fetchListLandslidePoints() async {
    return await landslideDatabase.fetchListLandslidePoints();
  }

  Future<HourlyForecastResponse> fetchHourlyForecastPoints() async {
    return await landslideDatabase.fetchHourlyForecastPoints();
  }

  Future<List<String>> getAllDistricts() async {
    return await landslideDatabase.getAllDistricts();
  }

  Future<String> fetchAboutContent() async {
    return await aboutDatabase.fetchAboutContent();
  }
}
