import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';

enum FilterOption {
  FAVORITE,
  ALL,
}

class ProductOverview extends StatefulWidget {

static const routeName = 'product-overview';

  @override
  _ProductOverviewState createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  var _isFavorite = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('My Shop'),
          actions: <Widget>[
            Consumer<Cart>(
              builder: (_, cart, ch) =>
                  Badge(child: ch, value: '${cart.itemCount}'),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
            ),
            PopupMenuButton(
              onSelected: (FilterOption selectedItem) {
                setState(() {
                  if (selectedItem == FilterOption.FAVORITE) {
                    _isFavorite = true;
                  } else {
                    _isFavorite = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Text('Show Favorite'),
                  value: FilterOption.FAVORITE,
                ),
                PopupMenuItem(
                  child: Text('Show All'),
                  value: FilterOption.ALL,
                ),
              ],
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: Provider.of<Products>(context, listen: false)
                .fetchAndSetProduct(),
            builder: (ctx, dataSnapShot) {
              if (dataSnapShot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (dataSnapShot.error != null) {
                  return Center(child: Text('An error occured!'),);
                } else {
                  return ProductGrid(_isFavorite);
                }
              }
            }));
  }
}
