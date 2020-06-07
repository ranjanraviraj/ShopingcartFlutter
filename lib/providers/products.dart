import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../const/constant.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String _token;
  final String userId;

  Products(this._token,this.userId, this._items,);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((productItem) => productItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProduct([bool filterUser = false]) async {
    final filterString = filterUser? 'orderBy="${Constant.CREATED_BY}"&equalTo="$userId"' : '';
    var URL = 'https://shopping-b05ef.firebaseio.com/products.json?auth=$_token&$filterString';
    try {
      final resposne = await http.get(URL);
      final extractedData = json.decode(resposne.body) as Map<String, dynamic>;
      if(extractedData == null){
        return;
      }
      URL = 'https://shopping-b05ef.firebaseio.com/userFavorite/$userId.json?auth=$_token';
      final favoriteResonse = await http.get(URL);
      final favoriteData = json.decode(favoriteResonse.body);
      final List<Product> loadedData = [];
      extractedData.forEach((productId, prodData) {
        loadedData.add(Product(
          id: productId,
          title: prodData[Constant.TITLE],
          description: prodData[Constant.DESCRIPTION],
          price: prodData[Constant.PRICE],
          imageUrl: prodData[Constant.IMAGE_URL],
          isFavorite: favoriteData == null ? false : favoriteData[productId] ?? false,
        ));
      });
      _items = loadedData;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product newItem) async {
    final URL = 'https://shopping-b05ef.firebaseio.com/products.json?auth=$_token';
    try {
      final response = await http.post(URL,
          body: json.encode({
            Constant.CREATED_BY : userId,
            Constant.TITLE: newItem.title,
            Constant.PRICE: newItem.price,
            Constant.DESCRIPTION: newItem.description,
            Constant.IMAGE_URL: newItem.imageUrl,
          }));
      final addProduct = Product(
          id: json.decode(response.body)[Constant.PRODUCT_ID],
          title: newItem.title,
          description: newItem.description,
          price: newItem.price,
          imageUrl: newItem.imageUrl);
      _items.add(addProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product editedItem) async {
    final productIndex = _items.indexWhere((pro) => pro.id == id);
    if (productIndex >= 0) {
      final url = 'https://shopping-b05ef.firebaseio.com/products/$id.json?auth=$_token';
      try {
        await http.patch(url,
            body: json.encode({
              Constant.CREATED_BY : userId,
              Constant.TITLE: editedItem.title,
              Constant.PRICE: editedItem.price,
              Constant.DESCRIPTION: editedItem.description,
              Constant.IMAGE_URL: editedItem.imageUrl,
            }));
        _items[productIndex] = editedItem;
        notifyListeners();
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://shopping-b05ef.firebaseio.com/products/$id.json?auth=$_token';
    final existingIndex = _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingIndex];
    _items.removeAt(existingIndex);
     notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingIndex, existingProduct);
      existingProduct = null;
      notifyListeners();
      throw HttpException('Could not delete product');
    }
  }
}
