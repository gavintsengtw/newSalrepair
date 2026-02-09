import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';
import '../config.dart';
import 'progress_gallery_page.dart';

class ProgressDateSelectorPage extends StatefulWidget {
  const ProgressDateSelectorPage({super.key});

  @override
  State<ProgressDateSelectorPage> createState() =>
      _ProgressDateSelectorPageState();
}

class _ProgressDateSelectorPageState extends State<ProgressDateSelectorPage> {
  bool _isLoading = true;
  List<String> _dates = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDates();
  }

  Future<void> _fetchDates() async {
    final userProvider = context.read<UserProvider>();
    final pjnoid = userProvider.currentPjno;

    if (pjnoid.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = '未選擇案場';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final uri = Uri.parse('${AppConfig.apiUrl}/api/progress/dates/$pjnoid');
      final response = await http.get(
        uri,
        headers: userProvider.authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _dates = data.cast<String>();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = '無法取得日期資料 (${response.statusCode})';
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
        title: const Text('工程進度 - 日期選擇'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _dates.isEmpty
                  ? const Center(child: Text('目前沒有工程進度資料'))
                  : ListView.builder(
                      itemCount: _dates.length,
                      itemBuilder: (context, index) {
                        final date = _dates[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              date,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProgressGalleryPage(date: date),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
