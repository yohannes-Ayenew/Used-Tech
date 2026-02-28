import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

abstract class ProductRemoteDataSource {
  Future<ProductModel> createProduct({
    required String category,
    required String brand,
    required String model,
    required String condition,
    required String title,
    required String description,
    required double price,
    required String location,
    String? storage,
    String? ram,
    String? processor,
    required List<XFile> images,
  });

  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client client;
  final SharedPreferences sharedPreferences;

  ProductRemoteDataSourceImpl({
    required this.client,
    required this.sharedPreferences,
  });

  @override
  Future<ProductModel> createProduct({
    required String category,
    required String brand,
    required String model,
    required String condition,
    required String title,
    required String description,
    required double price,
    required String location,
    String? storage,
    String? ram,
    String? processor,
    required List<XFile> images,
  }) async {
    final token = sharedPreferences.getString('CACHED_TOKEN');
    if (token == null) {
      throw ServerException('Not authenticated');
    }

    final uri = Uri.parse(ApiEndpoints.createProduct); // Make sure this exists in ApiEndpoints
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
      ..fields['category'] = category
      ..fields['brand'] = brand
      ..fields['model'] = model
      ..fields['condition'] = condition
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['price'] = price.toString()
      ..fields['location'] = location;

    if (storage != null && storage.isNotEmpty) request.fields['storage'] = storage;
    if (ram != null && ram.isNotEmpty) request.fields['ram'] = ram;
    if (processor != null && processor.isNotEmpty) request.fields['processor'] = processor;

    for (var image in images) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'images',
          bytes,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType.parse(mimeType),
        ));
      }
    }

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return ProductModel.fromJson(jsonData['data'] ?? jsonData['product'] ?? jsonData);
    } else {
      final jsonData = json.decode(response.body);
      throw ServerException(jsonData['message'] ?? 'Failed to create product');
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final uri = Uri.parse(ApiEndpoints.getProducts);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['data'];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      final jsonData = json.decode(response.body);
      throw ServerException(jsonData['message'] ?? 'Failed to fetch products');
    }
  }
}
