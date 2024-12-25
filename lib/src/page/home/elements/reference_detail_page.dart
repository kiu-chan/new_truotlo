import 'package:flutter/material.dart';
import 'package:new_truotlo/src/database/home.dart';
import 'package:new_truotlo/src/config/api.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class ReferenceDetailPage extends StatefulWidget {
  final int id;

  const ReferenceDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  _ReferenceDetailPageState createState() => _ReferenceDetailPageState();
}

class _ReferenceDetailPageState extends State<ReferenceDetailPage> {
  final HomeDatabase homeDatabase = HomeDatabase();
  final ApiConfig apiConfig = ApiConfig();
  Map<String, dynamic> referenceDetails = {};
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _fetchReferenceDetails();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() => _showTitle = false);
    }
  }

  Future<void> _fetchReferenceDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      final details = await homeDatabase.fetchReferenceDetails(widget.id);
      setState(() {
        referenceDetails = details;
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải chi tiết tài liệu: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('HH:mm dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không thể tải nội dung',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _fetchReferenceDetails,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final imageUrl = referenceDetails['file_path'] != null 
      ? '${apiConfig.getImgUrl()}/${referenceDetails['file_path']}'
      : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referenceDetails['title'] ?? 'Chi tiết tài liệu',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(referenceDetails['published_at'] ?? ''),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.remove_red_eye, size: 16, color: Colors.purple.shade700),
                          const SizedBox(width: 6),
                          Text(
                            '${referenceDetails['views'] ?? 0} lượt xem',
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showTitle ? Colors.blue : Colors.transparent,
        elevation: _showTitle ? 2 : 0,
        title: AnimatedOpacity(
          opacity: _showTitle ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            referenceDetails['title'] ?? 'Chi tiết tài liệu',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: _showTitle ? Colors.white : Colors.black,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : referenceDetails.isEmpty
              ? _buildErrorPlaceholder()
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      if (referenceDetails['content'] != null)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Html(
                            data: referenceDetails['content'],
                            style: {
                              "body": Style(
                                fontSize: FontSize(16.0),
                                lineHeight: LineHeight(1.6),
                                textAlign: TextAlign.justify,
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "p, div, span": Style(
                                textAlign: TextAlign.justify,
                                margin: Margins.only(bottom: 16),
                              ),
                              "h1": Style(
                                fontSize: FontSize(28.0),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(top: 24, bottom: 16),
                              ),
                              "h2": Style(
                                fontSize: FontSize(24.0),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(top: 20, bottom: 12),
                              ),
                              "h3": Style(
                                fontSize: FontSize(20.0),
                                fontWeight: FontWeight.bold,
                                margin: Margins.only(top: 16, bottom: 8),
                              ),
                              "img": Style(
                                alignment: Alignment.center,
                                margin: Margins.symmetric(vertical: 24),
                              ),
                              "table": Style(
                                alignment: Alignment.center,
                                border: Border.all(color: Colors.grey.shade300),
                                margin: Margins.symmetric(vertical: 24),
                                backgroundColor: Colors.grey.shade50,
                              ),
                              "th": Style(
                                padding: HtmlPaddings.all(12),
                                backgroundColor: Colors.grey.shade100,
                                fontWeight: FontWeight.bold,
                              ),
                              "td": Style(
                                padding: HtmlPaddings.all(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              "ul, ol": Style(
                                margin: Margins.only(bottom: 16, left: 20),
                              ),
                              "li": Style(
                                margin: Margins.only(bottom: 8),
                              ),
                            },
                          ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Không có nội dung',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}