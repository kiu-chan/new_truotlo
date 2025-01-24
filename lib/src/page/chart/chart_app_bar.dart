// lib/src/page/chart/widgets/chart_app_bar.dart

import 'package:flutter/material.dart';

class ChartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ChartAppBar({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Biểu đồ', style: TextStyle(color: Colors.white)),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.blue,
      elevation: 2,
      actions: [
        if (isRefreshing)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: isRefreshing ? null : onRefresh,
          tooltip: 'Làm mới dữ liệu',
        ),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            scaffoldKey.currentState?.openEndDrawer();
          },
          tooltip: 'Menu biểu đồ',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}