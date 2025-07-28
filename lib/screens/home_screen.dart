import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_summary.dart';
import '../widgets/category_tabs.dart';
import 'checkout_screen.dart';
import 'stock_management_screen.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.loadCategories();
      productProvider.loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS System'),
        actions: [
          // Stock Management Button
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StockManagementScreen(),
                ),
              );
            },
            tooltip: 'Stock Management',
          ),
          // Low Stock Indicator
          Consumer<ProductProvider>(
            builder: (ctx, productProvider, _) {
              final lowStockCount = productProvider.products
                  .where((product) => product.isLowStock && product.stockQuantity > 0)
                  .length;
              final outOfStockCount = productProvider.products
                  .where((product) => product.stockQuantity == 0)
                  .length;

              if (lowStockCount > 0 || outOfStockCount > 0) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.warning),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StockManagementScreen(),
                          ),
                        );
                      },
                      tooltip: 'Stock Alerts',
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${lowStockCount + outOfStockCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer<AuthProvider>(
            builder: (ctx, auth, _) => Row(
              children: [
                Text('Hello, ${auth.user?.fullName ?? ''}'),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => auth.logout(),
                ),
              ],
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          CategoryTabs(),
          Expanded(
            flex: 3,
            child: ProductGrid(),
          ),
          Expanded(
            flex: 1,
            child: CartSummary(),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (ctx, cart, _) => cart.itemCount > 0
            ? FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            );
          },
          label: const Text('Checkout'),
          icon: const Icon(Icons.shopping_cart),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}