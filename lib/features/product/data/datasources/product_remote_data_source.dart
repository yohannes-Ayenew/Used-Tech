// lib/features/product/data/datasources/product_remote_data_source.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<void> createProduct({
    required Map<String, dynamic> productData,
    required List<File> images,
  });

  Future<List<ProductModel>> getProducts({String? category, String? search});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  ProductRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<void> createProduct({
    required Map<String, dynamic> productData,
    required List<File> images,
  }) async {
    final token = sharedPreferences.getString('CACHED_TOKEN');
    if (token == null) throw ServerException('Not authenticated');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.createProduct),
      );

      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add text fields
      productData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add images
      print("📸 Adding ${images.length} images to request");
      for (var image in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // Ensure this matches backend expectation
            image.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        final message =
            jsonDecode(response.body)['message'] ?? "Failed to create listing";
        throw ServerException(message);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
  }) async {
    try {
      // Build Query
      String query = '';
      if (category != null) query += '?category=$category';
      if (search != null) query += '${query.isEmpty ? '?' : '&'}search=$search';

      final uri = Uri.parse('${ApiEndpoints.getProducts}$query');

      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productsJson = data['data'];
        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load products');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
