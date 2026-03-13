import 'dart:convert';
import 'dart:io';

void main() async {
  final ip = '10.232.201.90';
  final url = Uri.parse('http://$ip:3000/api/products');
  
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    final json = jsonDecode(stringData);
    
    if (json['data'] != null && json['data'].isNotEmpty) {
      bool foundImage = false;
      for (var product in json['data']) {
        if (product['sellerId'] != null) {
          final seller = product['sellerId'];
          if (seller['profileImage'] != null) {
            print('Found profile image for seller ${seller['name']}: ${seller['profileImage']}');
            foundImage = true;
          }
        }
      }
      if (!foundImage) {
        print('NO profileImage found for ANY seller in the products response.');
      }
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
