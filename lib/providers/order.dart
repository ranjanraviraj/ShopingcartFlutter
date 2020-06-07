import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/order_item.dart';
import '../models/cart_items.dart';
import '../const/constant.dart';

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  final String _token;
  final String _userId;

  Order(this._token, this._userId, this._orders);

  Future<void> fetchANdSetOrder() async {
    final URL = 'https://shopping-b05ef.firebaseio.com/orders/$_userId.json?auth=$_token';
    try {
      final resposne = await http.get(URL);
      final orderDatas = json.decode(resposne.body) as Map<String, dynamic>;
      if(orderDatas == null) {
        _orders = [];
        notifyListeners();
        return;
      }
      final List<OrderItem> loadedItem = [];
      orderDatas.forEach((orderId, orderData) {
        loadedItem.add(OrderItem(
            id: orderId,
            amount: orderData[Constant.AMOUNT],
            time: DateTime.parse(orderData[Constant.TIME]),
            products: (orderData[Constant.PRODUCT] as List<dynamic>)
                .map(
                  (cartItem) => CartItems(
                    cartItem[Constant.CART_ID],
                    cartItem[Constant.TITLE],
                    cartItem[Constant.PRICE],
                    cartItem[Constant.QUANTITY],
                  ),
                )
                .toList()));
      });
      _orders = loadedItem.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addOrder(List<CartItems> cartProduct, double total) async {
    final URL = 'https://shopping-b05ef.firebaseio.com/orders/$_userId.json?auth=$_token';
    final time = DateTime.now();
    try {
      final reposne = await http.post(URL,
          body: json.encode({
            Constant.AMOUNT: total,
            Constant.TIME: time.toIso8601String(),
            Constant.PRODUCT: cartProduct
                .map((item) => {
                      Constant.CART_ID: item.id,
                      Constant.TITLE: item.title,
                      Constant.QUANTITY: item.quantity,
                      Constant.PRICE: item.price
                    })
                .toList()
          }));

      _orders.insert(
        0,
        OrderItem(
            id: json.decode(reposne.body)[Constant.PRODUCT_ID],
            amount: total,
            products: cartProduct,
            time: time),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
