import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _amountPaidController = TextEditingController();
  String _selectedPaymentMethod = 'cash';

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (ctx, cart, auth, _) {
          return Column(
            children: [
            // Cart Items
            Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(item.productName),
                    subtitle: Text('\K${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}'),
                    trailing: SizedBox(
                      width: 150, // Adjust width as needed
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('\K${item.totalPrice.toStringAsFixed(2)}'),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              cart.updateQuantity(item.productId, item.quantity - 1);
                            },
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              cart.updateQuantity(item.productId, item.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),                );
              },
            ),
          ),

          // Payment Section
          Expanded(
          child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Summary
            Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text('Subtotal:', style: TextStyle(fontSize: 8)),
            Text('\K${cart.subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 8)),
          ],
          ),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text('Tax (${(cart.taxRate * 100).toInt()}%):', style: const TextStyle(fontSize: 8)),
           Text('\K${cart.taxAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 8)),
          ],
          ),
          if (cart.discountAmount > 0)
           Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text('Discount:', style: TextStyle(fontSize: 8)),
          Text('-\K${cart.discountAmount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16, color: Colors.green)),
          ],
          ),
          const Divider(),
           Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Text('Total:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          Text('\K${cart.totalAmount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ],
          ),
          const SizedBox(height: 10),

          // Payment Method
          const Text('Payment Method:', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
          Row(
          children: [
          Radio<String>(
          value: 'cash',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
          setState(() {
          _selectedPaymentMethod = value!;
          cart.setPaymentMethod(value);
          });
          },
          ),
          const Text('Cash'),
          Radio<String>(
          value: 'card',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
          setState(() {
          _selectedPaymentMethod = value!;
          cart.setPaymentMethod(value);
          });
          },
          ),
          const Text('Card'),
          Radio<String>(
          value: 'mobile_money',
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
          setState(() {
          _selectedPaymentMethod = value!;
          cart.setPaymentMethod(value);
          });
          },
          ),
          const Text('Mobile Money'),
          ],
          ),

          // Amount Paid
          TextField(
          controller: _amountPaidController,
          decoration: const InputDecoration(
          labelText: 'Amount Paid',
          prefixText: '\\',
          border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          onChanged: (value) {
          final amount = double.tryParse(value) ?? 0.0;
          cart.setAmountPaid(amount);
          },
          ),

          if (cart.amountPaid > 0 && cart.changeAmount >= 0)
           Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
          'Change: \K${cart.changeAmount.toStringAsFixed(2)}',
          style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: Colors.green,
          ),
          ),
          ),


          // Process Sale Button
          ElevatedButton(
          onPressed: cart.amountPaid >= cart.totalAmount
          ? () async {
          final success = await cart.processSale(auth.user!.id);
          if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('Sale processed successfully!'),
          backgroundColor: Colors.green,
          ),
          );
          } else {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('Failed to process sale'),
          backgroundColor: Colors.red,
          ),
          );
          }
          }
              : null,
          style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 25),
          ),
          child: const Text(
          'Process Sale',
          style: TextStyle(fontSize: 9),
          ),
          ),
          ],
          ),
          ),
          ),
          ],
          );
        },
      ),
    );
  }
}