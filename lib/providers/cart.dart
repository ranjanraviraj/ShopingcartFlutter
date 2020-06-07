import 'package:flutter/foundation.dart';

import '../models/cart_items.dart';

class Cart with ChangeNotifier {
  Map<String, CartItems> _items = {};

  Map<String, CartItems> get items {
    return {..._items};
  }

  int get itemCount {
    var itemCount = 0;
    _items.forEach((key, cartItem) {
      itemCount += cartItem.quantity;
    });
    return itemCount;
  }

  double get totalPrice {
    var totalPrice = 0.0;
    _items.forEach((key, cartItems) {
      totalPrice += cartItems.price * cartItems.quantity;
    });
    return totalPrice;
  }

  void addItem(
    String productId,
    double price,
    String title,
  ) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingValue) => CartItems(
                existingValue.id,
                existingValue.title,
                existingValue.price,
                existingValue.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItems(DateTime.now().toString(), title, price, 1),
      );
    }
    notifyListeners();
  }

  void removeQuantity(String productId){
    if(!_items.containsKey(productId)){
      return;
    }
    if(_items[productId].quantity > 1){
     _items.update(
          productId,
          (existingValue) => CartItems(
                existingValue.id,
                existingValue.title,
                existingValue.price,
                existingValue.quantity - 1,
              )); 
    } else{
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
