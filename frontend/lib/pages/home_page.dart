import 'package:flutter/material.dart';
import '../api/api_client.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _response = 'No data';
  final ApiClient _apiClient = ApiClient();

  Future<void> _fetchData(String tenantId) async {
    try {
      final data = await _apiClient.get('/test', tenantId: tenantId);
      setState(() {
        _response = 'Tenant: $tenantId\nResponse: $data';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Client'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'API Response:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _response,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _fetchData('tenant1'),
              child: const Text('Test Tenant 1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _fetchData('tenant2'),
              child: const Text('Test Tenant 2'),
            ),
          ],
        ),
      ),
    );
  }
}
