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
      final product = json['data'][0];
      print('First Product Seller Info:');
      print(jsonEncode(product['sellerId']));
    } else {
      print('No products found or different structure.');
      print(stringData.substring(0, 500));
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
