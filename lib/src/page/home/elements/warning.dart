import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DisasterWarningCard extends StatefulWidget {
  const DisasterWarningCard({super.key});

  @override
  DisasterWarningCardState createState() => DisasterWarningCardState();
}

class DisasterWarningCardState extends State<DisasterWarningCard> {
  bool _isLoading = true;
  bool _hasData = false;
  Map<String, int> _riskLevelCounts = {
    '5': 0, // Rất cao (>=5)
    '4': 0, // Cao (>=4)
    '3': 0, // Trung bình (>=3)
    '2': 0, // Thấp (>=2)
    '1': 0, // Rất thấp (<2)
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupPeriodicUpdate();
  }

  void _setupPeriodicUpdate() {
    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://truotlobinhdinh.girc.edu.vn/api/forecast-points')
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final Map<String, dynamic> data = jsonResponse['data'];
          if (data.isEmpty) {
            setState(() {
              _hasData = false;
              _isLoading = false;
            });
            return;
          }

          final String currentHourKey = data.keys.first;
          final List<dynamic> hourlyPoints = data[currentHourKey] ?? [];
          
          if (hourlyPoints.isEmpty) {
            setState(() {
              _hasData = false;
              _isLoading = false;
            });
            return;
          }
          
          Map<String, int> counts = {
            '5': 0, '4': 0, '3': 0, '2': 0, '1': 0,
          };

          bool hasNonZeroRisk = false;

          for (var point in hourlyPoints) {
            final nguyCoTruotNong = double.tryParse(point['nguy_co_truot_nong']?.toString() ?? '0') ?? 0;
            
            if (nguyCoTruotNong > 0) {
              hasNonZeroRisk = true;
              
              if (nguyCoTruotNong >= 5) {
                counts['5'] = (counts['5'] ?? 0) + 1;
              } else if (nguyCoTruotNong >= 4) {
                counts['4'] = (counts['4'] ?? 0) + 1;
              } else if (nguyCoTruotNong >= 3) {
                counts['3'] = (counts['3'] ?? 0) + 1;
              } else if (nguyCoTruotNong >= 2) {
                counts['2'] = (counts['2'] ?? 0) + 1;
              } else {
                counts['1'] = (counts['1'] ?? 0) + 1;
              }
            }
          }

          if (mounted) {
            setState(() {
              _riskLevelCounts = counts;
              _hasData = hasNonZeroRisk;
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _hasData = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading forecast data: $e');
      if (mounted) {
        setState(() {
          _hasData = false;
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildRiskLevelIndicator(String level, int count) {
    String riskText;
    Color riskColor;
    String description;
    IconData icon;

    switch (level) {
      case '5':
        riskText = 'RẤT CAO';
        riskColor = Colors.red;
        description = 'Trượt lở trên diện rộng';
        icon = Icons.warning;
        break;
      case '4':
        riskText = 'CAO';
        riskColor = Colors.orange;
        description = 'Có thể phát sinh trượt lở quy mô lớn';
        icon = Icons.warning_amber;
        break;
      case '3':
        riskText = 'TRUNG BÌNH';
        riskColor = Colors.yellow.shade700;
        description = 'Chủ yếu trượt lở có quy mô nhỏ';
        icon = Icons.info;
        break;
      case '2':
        riskText = 'THẤP';
        riskColor = Colors.blue;
        description = 'Trượt lở có thể phát sinh cục bộ';
        icon = Icons.info_outline;
        break;
      default:
        riskText = 'RẤT THẤP';
        riskColor = Colors.green;
        description = 'Ít có khả năng xảy ra trượt lở';
        icon = Icons.check_circle_outline;
    }

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: riskColor, width: 4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: riskColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        riskText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count điểm',
                          style: TextStyle(
                            color: riskColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Cảnh báo trượt nông',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cập nhật lúc: ${_getCurrentTime()}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (!_hasData)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Không có cảnh báo nguy cơ trượt nông',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _riskLevelCounts.entries
                        .where((e) => e.value > 0)
                        .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildRiskLevelIndicator(e.key, e.value),
                        ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}