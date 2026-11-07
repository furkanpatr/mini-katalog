import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const QuantitySelector({
    super.key,
    required this.maxQuantity,
    required this.onChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int quantity = 1;

  void changeQuantity(int value) {
    if (value < 1 || value > widget.maxQuantity) {
      return;
    }

    setState(() {
      quantity = value;
    });

    widget.onChanged(quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: quantity > 1 ? () => changeQuantity(quantity - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$quantity',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: quantity < widget.maxQuantity
              ? () => changeQuantity(quantity + 1)
              : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
