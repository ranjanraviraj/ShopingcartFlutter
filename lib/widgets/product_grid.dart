import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products.dart';

class ProductGrid extends StatelessWidget {
final bool isFavorite;

ProductGrid(this.isFavorite);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Products>(context);
    final productData = isFavorite? product.favoriteItems : product.items;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 3 / 2,
      ),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        // create: (ctx) => productData[index],
        value: productData[index],
        child: ProductItem(
          // productData[index].id,
          // productData[index].title,
          // productData[index].price,
          // productData[index].imageUrl,
        ),
      ),
      itemCount: productData.length,
      padding: const EdgeInsets.all(10),
    );
  }
}
