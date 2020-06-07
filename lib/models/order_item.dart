import 'package:flutter/foundation.dart';

import './cart_items.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItems> products;
  final DateTime time;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.time,
  });
}
