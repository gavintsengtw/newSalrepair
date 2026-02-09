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
                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            final image = _images[index];
                            final memo = image['memo'] ?? '';
                            final filename = image['filename'] ?? '';
                            // Use proxy URL
                            final proxyUrl =
                                '${AppConfig.apiUrl}/api/progress/image?filename=${Uri.encodeComponent(filename)}';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (filename.isNotEmpty)
                                    Image.network(
                                      proxyUrl,
                                      headers: userProvider.authHeaders,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return SizedBox(
                                          height: 200,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        debugPrint('Image load error: $error');
                                        return Container(
                                          height: 200,
                                          color: Colors.grey[200],
                                          child: const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 50)),
                                        );
                                      },
                                    ),
                                  if (memo.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        memo,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
