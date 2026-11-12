import 'package:flutter/material.dart';

import '../data/laundry_repository.dart';
import '../models/laundry_order.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/demo_data_banner.dart';
import '../widgets/status_chip.dart';
import '../widgets/status_timeline.dart';
import 'order_ticket_screen.dart';

/// Customer tracking result. It listens to the repository, so the moment
/// staff change a status the customer sees the update.
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    required this.repository,
    required this.orderId,
    super.key,
  });

  final LaundryRepository repository;
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final order = repository.orderById(orderId);

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order details')),
            body: const Center(
              child: Text('We could not find this order anymore.'),
            ),
          );
        }

        final isReady = order.status == LaundryStatus.readyForPickup;
        final isClaimed = order.status == LaundryStatus.claimed;

        return Scaffold(
          appBar: AppBar(title: const Text('Order details')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    Text(
                      'Laundry progress',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep this Order ID for tracking and pickup.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ORDER ID',
                            style: TextStyle(
                              color: Color(0xFF77837A),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            order.orderId,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          StatusChip(status: order.status),
                          const Divider(height: 26),
                          DetailRow(label: 'Customer', value: order.customerName),
                          DetailRow(
                            label: 'Contact',
                            value: order.contactNumber,
                          ),
                          DetailRow(
                            label: 'Received',
                            value: MaterialLocalizations.of(context)
                                .formatMediumDate(order.receivedAt),
                          ),
                          DetailRow(
                            label: 'Recorded weight',
                            value: '${order.weightKg.toStringAsFixed(1)} kg',
                          ),
                        ],
                      ),
                    ),
                    if (order.isDemo) ...[
                      const SizedBox(height: 14),
                      const DemoDataBanner(
                        message: 'This order is sample data for preview only. '
                            'The current app is not connected to staff orders.',
                      ),
                    ],
                    if (isReady) ...[
                      const SizedBox(height: 16),
                      _PickupNotice(orderId: order.orderId, completed: false),
                    ] else if (isClaimed) ...[
                      const SizedBox(height: 16),
                      _PickupNotice(orderId: order.orderId, completed: true),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      'Order status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    StatusTimeline(currentStatus: order.status),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'View order ticket',
                      icon: Icons.confirmation_number_outlined,
                      outlined: true,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => OrderTicketScreen(
                              repository: repository,
                              orderId: order.orderId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PickupNotice extends StatelessWidget {
  const _PickupNotice({
    required this.orderId,
    required this.completed,
  });

  final String orderId;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        completed ? const Color(0xFFE9EFE7) : const Color(0xFFEAF2E8);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD5E1D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                completed
                    ? Icons.task_alt_rounded
                    : Icons.notifications_active_outlined,
                color: const Color(0xFF315A3F),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  completed ? 'Order completed' : 'Ready for pickup',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF254B34),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            completed
                ? 'Order $orderId has been marked claimed/completed by staff. '
                    'Thank you for choosing FoldFlow!'
                : 'Your laundry is ready! Visit the laundry shop and present '
                    'Order ID $orderId to our staff. Payment and release of '
                    'your laundry are handled at the shop.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF425648),
                ),
          ),
        ],
      ),
    );
  }
}
