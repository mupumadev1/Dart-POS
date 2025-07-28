import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items: ${cart.itemCount}',
                  style: const TextStyle(fontSize: 8),
                ),
                Text(
                  'Subtotal: \$${cart.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 8),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax: \$${cart.taxAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 8),
                ),
                Text(
                  'Total: \$${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: cart.itemCount > 0 ? cart.clearCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Clear Cart'),
            ),
          ],
        ),
      ),
    );
  }
}