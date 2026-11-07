import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/product.dart';

import 'pages/cart_page.dart';

import 'widgets/quantity_selector.dart';

void main() {
  runApp(const MyApp());
}

Future<List<Product>> loadProducts() async {
  final String jsonString = await rootBundle.loadString(
    'assets/data/products.json',
  );

  final List<dynamic> jsonList = jsonDecode(jsonString);

  return jsonList
      .map((item) => Product.fromJson(item as Map<String, dynamic>))
      .toList();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Katalog',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Mini Katalog'),
      onGenerateRoute: (settings) {
        if (settings.name == '/product-detail') {
          final product = settings.arguments as Product;
          return MaterialPageRoute<int>(
            builder: (context) => ProductDetailPage(product: product),
          );
        }

        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final loadedProducts = await loadProducts();

      if (!mounted) return;

      setState(() {
        products = loadedProducts;
        isLoading = false;
        loadError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = 'Ürünler yüklenemedi: $error';
      });
    }
  }

  List<Product> products = [];
  bool isLoading = true;
  String? loadError;
  String searchQuery = '';
  String sortOrder = 'default';

  final List<Product> cart = [];

  int remainingStock(Product product) {
    final int cartQuantity = cart
        .where((item) => item.name == product.name)
        .length;

    return (product.stock ?? 0) - cartQuantity;
  }

  bool addToCart(Product product) {
    if (remainingStock(product) <= 0) {
      return false;
    }

    setState(() {
      cart.add(product);
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      return product.name.toLowerCase().contains(
        searchQuery.trim().toLowerCase(),
      );
    }).toList();
    if (sortOrder == 'price_asc') {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOrder == 'price_desc') {
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage(cart: cart)),
                ).then((_) {
                  if (mounted) {
                    setState(() {});
                  }
                });
              },
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(
                '${cart.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),
          const WelcomeWidget(),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ürün ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.sort, size: 20),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: sortOrder,
                  items: const [
                    DropdownMenuItem(
                      value: 'default',
                      child: Text('Varsayılan'),
                    ),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Fiyat: Artan'),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Fiyat: Azalan'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        sortOrder = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : loadError != null
                ? Center(child: Text(loadError!))
                : filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Aradığınız ürün bulunamadı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text('Farklı bir ürün adı aramayı deneyin.'),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  child: Image.asset(
                                    product.image,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.image_not_supported,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${product.price.toStringAsFixed(2)} TL'),
                              const SizedBox(height: 4),
                              Text(
                                remainingStock(product) > 0
                                    ? 'Stok: ${remainingStock(product)}'
                                    : 'Tükendi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: remainingStock(product) > 0
                                      ? null
                                      : Colors.red,
                                  fontWeight: remainingStock(product) > 0
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final int? selectedQuantity =
                                            await Navigator.pushNamed<int>(
                                              context,
                                              '/product-detail',
                                              arguments: Product(
                                                name: product.name,
                                                price: product.price,
                                                stock: remainingStock(product),
                                                image: product.image,
                                                description:
                                                    product.description,
                                              ),
                                            );

                                        if (!context.mounted ||
                                            selectedQuantity == null) {
                                          return;
                                        }

                                        int addedCount = 0;

                                        for (
                                          int i = 0;
                                          i < selectedQuantity;
                                          i++
                                        ) {
                                          if (addToCart(product)) {
                                            addedCount++;
                                          } else {
                                            break;
                                          }
                                        }

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '$addedCount adet ${product.name} sepete eklendi!',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('İncele'),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 36,
                                    child: OutlinedButton(
                                      onPressed: remainingStock(product) <= 0
                                          ? null
                                          : () {
                                              final bool added = addToCart(
                                                product,
                                              );

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    added
                                                        ? '${product.name} sepete eklendi!'
                                                        : '${product.name} için yeterli stok yok!',
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            },

                                      child: const Text('Sepete Ekle'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.storefront_outlined,
          size: 80,
          color: Colors.deepPurple,
        ),
        const SizedBox(height: 20),
        const Text(
          'Hoş Geldiniz!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Detayı')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  product.image,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.deepPurple,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Fiyat: ${product.price.toStringAsFixed(2)} TL',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Stok: ${product.stock ?? "Bilinmiyor"}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Ürün Açıklaması',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if ((product.stock ?? 0) > 0) ...[
                const Text(
                  'Adet Seçimi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                QuantitySelector(
                  maxQuantity: product.stock ?? 0,
                  onChanged: (value) {
                    setState(() {
                      selectedQuantity = value;
                    });
                  },
                ),
              ] else
                const Text('Ürün tükendi', style: TextStyle(color: Colors.red)),

              const SizedBox(height: 16),

              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: (product.stock ?? 0) > 0
                      ? () {
                          Navigator.pop(context, selectedQuantity);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text(
                    'Sepete Ekle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Listeye Dön'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
