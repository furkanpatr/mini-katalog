import 'package:flutter/material.dart';

import '../models/product.dart';

class CartPage extends StatefulWidget {
  final List<Product> cart;

  const CartPage({super.key, required this.cart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final double totalPrice = widget.cart.fold<double>(
      0.0,
      (total, product) => total + product.price,
    );
    final List<Product> uniqueProducts = [];

    for (final product in widget.cart) {
      final bool alreadyAdded = uniqueProducts.any(
        (item) => item.name == product.name,
      );

      if (!alreadyAdded) {
        uniqueProducts.add(product);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
        actions: [
          if (widget.cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Sepeti Temizle',
              onPressed: () async {
                final bool? confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Sepeti Temizle'),
                    content: const Text('Sepetteki tüm ürünler silinsin mi?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        child: const Text('Vazgeç'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        child: const Text('Temizle'),
                      ),
                    ],
                  ),
                );

                if (!mounted || confirmed != true) {
                  return;
                }

                setState(() {
                  widget.cart.clear();
                });
              },
            ),
        ],
      ),
      body: widget.cart.isEmpty
          ? const Center(
              child: Text('Sepetiniz boş', style: TextStyle(fontSize: 20)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: uniqueProducts.length,
                    itemBuilder: (context, index) {
                      final product = uniqueProducts[index];

                      final int quantity = widget.cart
                          .where((item) => item.name == product.name)
                          .length;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          minLeadingWidth: 64,
                          minVerticalPadding: 16,
                          leading: SizedBox(
                            width: 64,
                            height: 64,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                product.image,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.deepPurple,
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Birim Fiyat: ${product.price.toStringAsFixed(2)} TL',
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    style: IconButton.styleFrom(
                                      foregroundColor: Colors.deepPurple,
                                      iconSize: 16,
                                      fixedSize: const Size(32, 32),
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      side: const BorderSide(
                                        color: Colors.deepPurple,
                                        width: 1,
                                      ),
                                      shape: const CircleBorder(),
                                    ),
                                    tooltip: 'Adedi azalt',
                                    onPressed: () {
                                      setState(() {
                                        final index = widget.cart.indexWhere(
                                          (item) => item.name == product.name,
                                        );

                                        if (index != -1) {
                                          widget.cart.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    style: IconButton.styleFrom(
                                      foregroundColor: Colors.deepPurple,
                                      iconSize: 16,
                                      fixedSize: const Size(32, 32),
                                      padding: EdgeInsets.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      side: const BorderSide(
                                        color: Colors.deepPurple,
                                        width: 1,
                                      ),
                                      shape: const CircleBorder(),
                                    ),
                                    tooltip: 'Adedi artır',
                                    onPressed: quantity < (product.stock ?? 0)
                                        ? () {
                                            setState(() {
                                              widget.cart.add(product);
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Ara Toplam: ${(product.price * quantity).toStringAsFixed(2)} TL',
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Ürünü kaldır',
                            onPressed: () {
                              setState(() {
                                widget.cart.removeWhere(
                                  (item) => item.name == product.name,
                                );
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Toplam Tutar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(2)} TL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
