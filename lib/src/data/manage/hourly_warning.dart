class HourlyWarning {
  final int id;
  final int hour;
  final int day;
  final int month;
  final int year;
  final String location;
  final String truotNong;
  final String luQuet;
  final String truotLon;
  final String description;
  final double lat;
  final double lon;

  HourlyWarning({
    required this.id,
    required this.hour,
    required this.day,
    required this.month,
    required this.year,
    required this.location,
    required this.truotNong,
    required this.luQuet,
    required this.truotLon,
    required this.description,
    required this.lat,
    required this.lon,
  });

  String get formattedDate => 'Giờ $hour - Ngày $day/$month/$year';

  factory HourlyWarning.fromJson(Map<String, dynamic> json) {
    return HourlyWarning(
      id: json['id'],
      hour: json['hour'],
      day: json['day'],
      month: json['month'],
      year: json['year'],
      location: json['location'],
      truotNong: json['nguy_co_truot_nong'],
      luQuet: json['nguy_co_lu_quet'],
      truotLon: json['nguy_co_truot_lon'],
      description: json['description'],
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}