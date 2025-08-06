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
  final _commentsController = TextEditingController();
  String _selectedPaymentMethod = 'cash';

  @override
  void dispose() {
    _amountPaidController.dispose();
    _commentsController.dispose();
    super.dispose();
  }
  Widget _buildReceiptDialog(BuildContext context, CartProvider cart, AuthProvider auth) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Receipt', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),

            // Receipt Content
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Header
                  Center(
                    child: Column(
                      children: [
                        const Text('DAPP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Location: ${auth.user?.store?.storeLocation ?? ''}', style: const TextStyle(fontSize: 12)),
                        Text('Phone: ${auth.user?.store?.storeMobileNo ?? ''}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transaction Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Date:', style: TextStyle(fontSize: 12)),
                      Text(DateTime.now().toString().substring(0, 19), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cashier:', style: TextStyle(fontSize: 12)),
                      Text(auth.user?.fullName ?? 'Unknown', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment:', style: TextStyle(fontSize: 12)),
                      Text(_selectedPaymentMethod.toUpperCase(), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const Divider(),

                  // Items
                  for (var item in cart.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: const TextStyle(fontSize: 12)),
                                Text(
                                  'K${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text('K${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),

                  const Divider(),

                  // Totals
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal:', style: TextStyle(fontSize: 12)),
                      Text('K${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax (${(cart.taxRate * 100).toInt()}%):', style: const TextStyle(fontSize: 12)),
                      Text('K${cart.taxAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  if (cart.discountAmount > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount:', style: TextStyle(fontSize: 12)),
                        Text('-K${cart.discountAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12, color: Colors.green)),
                      ],
                    ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('K${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount Paid:', style: TextStyle(fontSize: 12)),
                      Text('K${cart.amountPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Change:', style: TextStyle(fontSize: 12)),
                      Text('K${cart.changeAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  ),
                  if (_commentsController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Notes:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(_commentsController.text, style: const TextStyle(fontSize: 11)),
                  ],

                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Thank you for your business!',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _printReceipt,
                    icon: const Icon(Icons.print),
                    label: const Text('Print Receipt'),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printReceipt() async {
   //To be implemented
  }


  @override
  Widget build(BuildContext context) {
    final smallTextStyle = TextStyle(fontSize: 14);
    final labelTextStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    final totalTextStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 18);

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
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(item.productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        subtitle: Text('K${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}', style: smallTextStyle),
                        trailing: SizedBox(
                          width: 170,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('K${item.totalPrice.toStringAsFixed(2)}', style: labelTextStyle),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    cart.updateQuantity(item.productId, item.quantity - 1);
                                  }
                                },
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  cart.updateQuantity(item.productId, item.quantity + 1);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Payment Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal:', style: smallTextStyle),
                            Text('K${cart.subtotal.toStringAsFixed(2)}', style: smallTextStyle),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tax (${(cart.taxRate * 100).toInt()}%):', style: smallTextStyle),
                            Text('K${cart.taxAmount.toStringAsFixed(2)}', style: smallTextStyle),
                          ],
                        ),
                        if (cart.discountAmount > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Discount:', style: smallTextStyle),
                              Text('-K${cart.discountAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Colors.green)),
                            ],
                          ),
                        const Divider(thickness: 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total:', style: totalTextStyle),
                            Text('K${cart.totalAmount.toStringAsFixed(2)}', style: totalTextStyle),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Payment Method
                        Text('Payment Method:', style: labelTextStyle),
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
                            const Text('Cash', style: TextStyle(fontSize: 14)),
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
                            const Text('Card', style: TextStyle(fontSize: 14)),
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
                            const Text('Mobile Money', style: TextStyle(fontSize: 14)),
                          ],
                        ),

                        const SizedBox(height: 15),

                        // Amount Paid
                        TextField(
                          controller: _amountPaidController,
                          decoration: const InputDecoration(
                            labelText: 'Amount Paid',
                            prefixText: 'K',
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
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Change: K${cart.changeAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),

                        const SizedBox(height: 15),

                        // Comments TextBox
                        TextField(
                          controller: _commentsController,
                          decoration: const InputDecoration(
                            labelText: 'Add comments',
                            hintText: 'Enter any notes or special instructions',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            cart.setNotes(value); // Make sure your CartProvider supports this
                          },
                        ),

                        const SizedBox(height: 20),

                        // Process Sale Button
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: cart.amountPaid >= cart.totalAmount
                                ? () async {
                              final success = await cart.processSale(auth.user!.id);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sale processed successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) => _buildReceiptDialog(context, cart, auth),
                                );

                                cart.clearCart();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to process sale'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                cart.clearCart();
                              }
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(double.infinity, 25),
                            ),
                            child: const Text(
                              'Process Sale',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
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