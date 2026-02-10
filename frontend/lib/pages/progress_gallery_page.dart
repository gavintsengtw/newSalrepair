import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';
import '../config.dart';

class ProgressGalleryPage extends StatefulWidget {
  final String date;

  const ProgressGalleryPage({super.key, required this.date});

  @override
  State<ProgressGalleryPage> createState() => _ProgressGalleryPageState();
}

class _ProgressGalleryPageState extends State<ProgressGalleryPage> {
  bool _isLoading = true;
  List<dynamic> _images = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final userProvider = context.read<UserProvider>();
    final pjnoid = userProvider.currentPjno;
    final date = widget.date;

    try {
      final uri =
          Uri.parse('${AppConfig.apiUrl}/api/progress/images/$pjnoid/$date');
      final response = await http.get(
        uri,
        headers: userProvider.authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _images = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = '無法取得影像資料 (${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '網路錯誤: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date} 工程進度'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _images.isEmpty
                  ? const Center(child: Text('目前沒有照片'))
                  : Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                constraints.maxWidth > 800 ? 3 : 2;
                            final spacing =
                                constraints.maxWidth > 800 ? 16.0 : 8.0;

                            return GridView.builder(
                              padding: EdgeInsets.all(spacing),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: spacing,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                return _buildProgressCard(
                                    _images[index], userProvider);
                              },
                            );
                          },
                        );
                      },
                    ),
    );
  }

  Widget _buildProgressCard(dynamic image, UserProvider userProvider) {
    final memo = image['memo'] ?? '';
    final filename = image['filename'] ?? '';
    // Use proxy URL
    final proxyUrl =
        '${AppConfig.apiUrl}/api/progress/image?filename=${Uri.encodeComponent(filename)}';

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero, // Margin controlled by parent
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (filename.isNotEmpty)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showFullImage(
                      context, proxyUrl, userProvider.authHeaders, memo);
                },
                child: Hero(
                  tag: proxyUrl,
                  child: Image.network(
                    proxyUrl,
                    headers: userProvider.authHeaders,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Image load error: $error');
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                            child: Icon(Icons.broken_image, size: 50)),
                      );
                    },
                  ),
                ),
              ),
            ),
          if (memo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                memo,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl,
      Map<String, String> headers, String memo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Expanded Image Area - Tap to close
            GestureDetector(
              onTap: () => Navigator.of(context).pop(), // Tap outside to close
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black54, // Dim background
              ),
            ),
            // The Image
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Hero(
                tag: imageUrl,
                child: Image.network(
                  imageUrl,
                  headers: headers,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Close Button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            // Memo (Optional, at bottom)
            if (memo.isNotEmpty)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    memo,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
