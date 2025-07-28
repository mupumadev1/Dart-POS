import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (ctx, productProvider, _) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productProvider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${productProvider.error}'),
                ElevatedButton(
                  onPressed: () => productProvider.loadProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final products = productProvider.filteredProducts
            .where((p) => p.isActive)
            .toList();

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (ctx, i) {
            final product = products[i];
            return Card(
              elevation: 4,
              color: product.isLowStock ? Colors.orange[50] : null,
              child: InkWell(
                onTap: () {
                  if (product.stockQuantity > 0) {
                    Provider.of<CartProvider>(context, listen: false)
                        .addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.isLowStock)
                            const Icon(Icons.warning, color: Colors.orange, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(
                          color: product.stockQuantity > 0
                              ? Colors.grey[600]
                              : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                      if (product.category != null)
                        Text(
                          product.category!.name,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}