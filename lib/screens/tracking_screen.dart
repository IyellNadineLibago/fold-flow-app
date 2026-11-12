import 'package:flutter/material.dart';

import '../data/laundry_repository.dart';
import '../models/laundry_order.dart';
import '../widgets/app_button.dart';
import '../widgets/demo_data_banner.dart';
import '../widgets/labeled_text_field.dart';
import 'order_details_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({
    required this.repository,
    super.key,
  });

  final LaundryRepository repository;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderIdController = TextEditingController();
  String? _lookupError;
  bool _isSearching = false;

  @override
  void dispose() {
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _lookupError = null;
      _isSearching = true;
    });

    try {
      final LaundryOrder? order;
      try {
        order = await widget.repository.findOrder(_orderIdController.text);
      } catch (error) {
        debugPrint('FoldFlow order lookup failed: $error');
        if (!mounted) return;
        setState(() {
          _lookupError =
              'We could not look up this order right now. Please try again.';
        });
        return;
      }
      if (!mounted) return;

      if (order == null) {
        setState(() {
          _lookupError = 'We could not find that Order ID. Check the ID on '
              'your staff-issued ticket, or contact the laundry shop.';
        });
        return;
      }

      final orderId = order.orderId;

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => OrderDetailsScreen(
            repository: widget.repository,
            orderId: orderId,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track my laundry')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                Text(
                  'Where is your order?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the Order ID from the ticket staff gave you after '
                  'receiving your laundry.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: LabeledTextField(
                    label: 'Order ID',
                    controller: _orderIdController,
                    hintText: 'e.g. ORD-1042',
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => _trackOrder(),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter your Order ID';
                      }
                      return null;
                    },
                  ),
                ),
                if (_lookupError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE9CFCA)),
                    ),
                    child: Text(
                      _lookupError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF8D3E36),
                          ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AppButton(
                  label: _isSearching ? 'Looking up order...' : 'Track Order',
                  icon: Icons.search_rounded,
                  onPressed: _isSearching ? null : _trackOrder,
                ),
                const SizedBox(height: 24),
                DemoDataBanner(
                  message: widget.repository.isDemoDataOnly
                      ? 'Local demo mode: try ORD-1042 to preview the '
                          'order timeline. That record is sample data, not a '
                          'real customer order.'
                      : 'Orders are stored live in the laundry shop '
                          'database. Try ORD-1042 (the seeded sample order, '
                          'demo data) or the Order ID on your ticket.',
                ),
                const SizedBox(height: 14),
                Text(
                  'Reservations do not create an Order ID. Staff issue an '
                  'Order ID after accepting your laundry.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
