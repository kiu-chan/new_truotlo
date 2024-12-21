import 'package:flutter/material.dart';
import 'package:new_truotlo/src/data/map/district_data.dart';
import 'package:new_truotlo/src/data/map/map_data.dart';

class MapMenu extends StatelessWidget {
  final List<MapStyleCategory> styleCategories;
  final String currentStyle;
  final bool isDistrictsVisible;
  final bool isBorderVisible;
  final bool isCommunesVisible;
  final bool isLandslidePointsVisible;
  final List<District> districts;
  final Map<int, bool> districtVisibility;
  final Map<String, bool> districtLandslideVisibility;
  final Function(String?) onStyleChanged;
  final Function(bool?) onDistrictsVisibilityChanged;
  final Function(bool?) onBorderVisibilityChanged;
  final Function(int, bool?) onDistrictVisibilityChanged;
  final Function(bool?) onCommunesVisibilityChanged;
  final Function(bool?) onLandslidePointsVisibilityChanged;
  final Function(String, bool?) onDistrictLandslideVisibilityChanged;
  final bool showOnlyLandslideRisk;
  final Function(bool?) onShowOnlyLandslideRiskChanged;
  final bool showOnlyFlashFloodRisk;
  final bool showOnlyLargeSlideRisk;
  final Function(bool?) onShowOnlyFlashFloodRiskChanged;
  final Function(bool?) onShowOnlyLargeSlideRiskChanged;

  const MapMenu({
    super.key,
    required this.styleCategories,
    required this.currentStyle,
    required this.isDistrictsVisible,
    required this.isBorderVisible,
    required this.districts,
    required this.districtVisibility,
    required this.onStyleChanged,
    required this.onDistrictsVisibilityChanged,
    required this.onBorderVisibilityChanged,
    required this.onDistrictVisibilityChanged,
    required this.isCommunesVisible,
    required this.onCommunesVisibilityChanged,
    required this.isLandslidePointsVisible,
    required this.onLandslidePointsVisibilityChanged,
    required this.districtLandslideVisibility,
    required this.onDistrictLandslideVisibilityChanged,
    required this.showOnlyLandslideRisk,
    required this.onShowOnlyLandslideRiskChanged,
    required this.showOnlyFlashFloodRisk,
    required this.showOnlyLargeSlideRisk,
    required this.onShowOnlyFlashFloodRiskChanged,
    required this.onShowOnlyLargeSlideRiskChanged,
  });

  Widget _buildHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blue,
        image: DecorationImage(
          image: AssetImage('lib/assets/map/header_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.blue,
            BlendMode.softLight,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tùy chọn bản đồ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tùy chỉnh hiển thị các lớp bản đồ',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapStyleSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.map, color: Colors.blue),
        title: const Text(
          'Kiểu bản đồ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: styleCategories.map((category) => 
          Theme(
            data: ThemeData(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Text(
                category.name,
                style: const TextStyle(fontSize: 14),
              ),
              children: category.styles.map((style) => 
                RadioListTile<String>(
                  title: Text(
                    style.name,
                    style: const TextStyle(fontSize: 13),
                  ),
                  value: style.url,
                  groupValue: currentStyle,
                  onChanged: onStyleChanged,
                  dense: true,
                  activeColor: Colors.blue,
                ),
              ).toList(),
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildLayersSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.layers, color: Colors.green),
        title: const Text(
          'Lớp hiển thị',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          _buildCheckboxTile(
            'Huyện',
            isDistrictsVisible,
            onDistrictsVisibilityChanged,
            Icons.location_city,
          ),
          _buildCheckboxTile(
            'Ranh giới',
            isBorderVisible,
            onBorderVisibilityChanged,
            Icons.border_all,
          ),
          _buildCheckboxTile(
            'Xã',
            isCommunesVisible,
            onCommunesVisibilityChanged,
            Icons.location_on,
          ),
          _buildCheckboxTile(
            'Điểm trượt lở',
            isLandslidePointsVisible,
            onLandslidePointsVisibilityChanged,
            Icons.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFiltersSection() {
    if (!isLandslidePointsVisible) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.filter_alt, color: Colors.orange),
        title: const Text(
          'Bộ lọc cảnh báo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          _buildRiskFilterTile(
            'Nguy cơ trượt nông',
            showOnlyLandslideRisk,
            onShowOnlyLandslideRiskChanged,
            Colors.red,
          ),
          _buildRiskFilterTile(
            'Nguy cơ lũ quét',
            showOnlyFlashFloodRisk,
            onShowOnlyFlashFloodRiskChanged,
            Colors.blue,
          ),
          _buildRiskFilterTile(
            'Nguy cơ trượt lớn',
            showOnlyLargeSlideRisk,
            onShowOnlyLargeSlideRiskChanged,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictsSection() {
    if (!isDistrictsVisible) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.map_outlined, color: Colors.brown),
        title: const Text(
          'Quản lý huyện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: districts.map((district) =>
          _buildDistrictTile(district),
        ).toList(),
      ),
    );
  }

  Widget _buildLandslideLocationsSection() {
    if (!isLandslidePointsVisible) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.place, color: Colors.red),
        title: const Text(
          'Vị trí trượt lở theo huyện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: districtLandslideVisibility.entries.map((entry) =>
          _buildLandslideLocationTile(entry.key, entry.value),
        ).toList(),
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
      dense: true,
    );
  }

  Widget _buildRiskFilterTile(
    String title,
    bool value,
    Function(bool?) onChanged,
    Color color,
  ) {
    return ListTile(
      leading: Icon(Icons.warning, size: 20, color: color),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
      dense: true,
    );
  }

  Widget _buildDistrictTile(District district) {
    return ListTile(
      leading: const Icon(Icons.location_city, size: 20),
      title: Text(
        district.name,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Switch(
        value: districtVisibility[district.id] ?? true,
        onChanged: (value) => onDistrictVisibilityChanged(district.id, value),
        activeColor: Colors.blue,
      ),
      dense: true,
    );
  }

  Widget _buildLandslideLocationTile(String district, bool value) {
    return ListTile(
      leading: const Icon(Icons.place, size: 20),
      title: Text(
        district,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Switch(
        value: value,
        onChanged: (bool? newValue) =>
            onDistrictLandslideVisibilityChanged(district, newValue),
        activeColor: Colors.red,
      ),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildMapStyleSection(),
            _buildLayersSection(),
            _buildRiskFiltersSection(),
            _buildDistrictsSection(),
            _buildLandslideLocationsSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}