import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order.dart';
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/order-screen';

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Order'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: Provider.of<Order>(context, listen: false).fetchANdSetOrder(),
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapShot.error != null) {
                return Center(
                  child: Text('An error occured!'),
                );
              } else {
                return Consumer<Order>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, index) =>
                        OrderItem(orderData.orders[index]),
                  ),
                );
              }
            }
          }),
    );
  }
}
