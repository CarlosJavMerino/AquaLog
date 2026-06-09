import 'package:dio/dio.dart';
import '../models/gear_search_result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GearSearchService {
  final Dio _dio = Dio();
  
  // API CONFIGURATION
  // In a production environment, these keys should be stored in .env files using flutter_dotenv
  // or passed via --dart-define during build to avoid committing secrets to version control.
  final String _apiKey = dotenv.get('GOOGLE_SEARCH_API_KEY'); 
  final String _searchEngineId = dotenv.get('GOOGLE_SEARCH_ENGINE_ID'); 
  final bool _useMockData = false; 

  Future<List<GearSearchResult>> searchGear(String query) async {
    if (_useMockData) return _getMockData(query);

    try {
      final String refinedQuery = '$query scuba diving gear OR equipo de buceo';

      final response = await _dio.get(
        'https://www.googleapis.com/customsearch/v1',
        queryParameters: {
          'key': _apiKey,
          'cx': _searchEngineId,
          'q': refinedQuery,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['items'] == null) return [];

        final List items = data['items'];
        final results = items
            .map((item) => GearSearchResult.fromJson(item))
            .toList();

        // Filter out results without images for a better UI experience
        return results.where((r) => r.imageUrl != null).toList();

      } else {
        throw Exception('Google API Error: ${response.statusCode}');
      }

    } on DioException catch (e) {
       // Detailed error handling for better debugging
       if (e.response?.statusCode == 403) {
           throw Exception('Quota exceeded or invalid API Key.');
       }
       throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // MOCK DATA GENERATOR
  Future<List<GearSearchResult>> _getMockData(String query) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
    final q = query.toLowerCase();
    
    List<GearSearchResult> mocks = [
      GearSearchResult(
        title: 'Mares Puck Pro +',
        snippet: 'Entry level dive computer, RGBM algorithm.',
        link: 'https://www.mares.com',
        imageUrl: 'https://www.scubastore.com/f/13676/136768364/mares-puck-pro-computer.jpg', 
      ),
      // ... more items
    ];

    if (q.isNotEmpty) {
      return mocks.where((element) => 
        element.title.toLowerCase().contains(q)
      ).toList();
    }
    return mocks;
  }
}