import 'package:flutter/material.dart';
import 'package:new_truotlo/src/data/manage/hourly_warning.dart';
import 'detail_row.dart';

class HourlyWarningList extends StatelessWidget {
  final List<HourlyWarning> hourlyWarnings;
  final Function(int) onDelete;

  const HourlyWarningList({
    Key? key,
    required this.hourlyWarnings,
    required this.onDelete,
  }) : super(key: key);

  static const primaryBlue = Color(0xFF2196F3);
  static const lightBlue = Color(0xFFE3F2FD);

  // Chuyển đổi string sang double
  double parseRiskLevel(String risk) {
    try {
      return double.parse(risk);
    } catch (e) {
      return 0.0;
    }
  }

  // Xác định màu sắc dựa trên giá trị
  Color getRiskColor(String riskString) {
    final risk = parseRiskLevel(riskString);
    
    if (risk == 0) return Colors.grey;
    if (risk < 2) return const Color(0xFF00BCD4);  // Cyan - Rất thấp
    if (risk < 3) return const Color(0xFF4CAF50);  // Xanh lá - Thấp
    if (risk < 4) return const Color(0xFFFFEB3B);  // Vàng - Trung bình
    if (risk < 5) return const Color(0xFFF44336);  // Đỏ - Cao
    return const Color(0xFF9C27B0);                // Tím - Rất cao
  }

  // Lấy text mô tả mức độ
  String getRiskText(String riskString) {
    final risk = parseRiskLevel(riskString);
    
    if (risk == 0) return "Không có";
    if (risk < 2) return "Rất thấp";
    if (risk < 3) return "Thấp";
    if (risk < 4) return "Trung bình";
    if (risk < 5) return "Cao";
    return "Rất cao";
  }

  // Widget hiển thị chỉ số trong list
  Widget _buildListRiskIndicator(String shortLabel, String riskValue, String fullLabel) {
    final color = getRiskColor(riskValue);
    final riskLevel = parseRiskLevel(riskValue);
    
    return Tooltip(
      message: '$fullLabel: ${getRiskText(riskValue)} (${riskLevel.toStringAsFixed(1)})',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                width: 12,
                height: 12,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$shortLabel: ${riskLevel.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị chỉ số trong dialog chi tiết
  Widget _buildDetailRiskIndicator(String label, String riskValue) {
    final color = getRiskColor(riskValue);
    final riskText = getRiskText(riskValue);
    final riskLevel = parseRiskLevel(riskValue);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              width: 16,
              height: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: ${riskLevel.toStringAsFixed(1)} - $riskText',
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hourlyWarnings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có cảnh báo nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: hourlyWarnings.length,
      itemBuilder: (context, index) {
        final warning = hourlyWarnings[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => _showHourlyWarningDetails(context, warning),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              warning.formattedDate,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    warning.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: primaryBlue,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Xem chi tiết',
                        onPressed: () => _showHourlyWarningDetails(context, warning),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildListRiskIndicator(
                          'TN',
                          warning.nguy_co_truot_nong,
                          'Trượt nông'
                        ),
                        const SizedBox(width: 8),
                        _buildListRiskIndicator(
                          'LQ',
                          warning.nguy_co_lu_quet,
                          'Lũ quét'
                        ),
                        const SizedBox(width: 8),
                        _buildListRiskIndicator(
                          'TL',
                          warning.nguy_co_truot_lon,
                          'Trượt lớn'
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
    );
  }

  void _showHourlyWarningDetails(BuildContext context, HourlyWarning warning) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Cảnh báo ${warning.formattedDate}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailRow(label: 'Vị trí:', value: warning.location),
                      const SizedBox(height: 16),
                      const Text(
                        'Mức độ nguy cơ:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRiskIndicator(
                        'Nguy cơ trượt nông',
                        warning.nguy_co_truot_nong,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRiskIndicator(
                        'Nguy cơ lũ quét',
                        warning.nguy_co_lu_quet,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRiskIndicator(
                        'Nguy cơ trượt lớn',
                        warning.nguy_co_truot_lon,
                      ),
                      const SizedBox(height: 16),
                      DetailRow(
                        label: 'Vĩ độ:',
                        value: warning.lat.toString(),
                      ),
                      DetailRow(
                        label: 'Kinh độ:',
                        value: warning.lon.toString(),
                      ),
                      if (warning.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Mô tả:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          warning.description,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Đóng',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}