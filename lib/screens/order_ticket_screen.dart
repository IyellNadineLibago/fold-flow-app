import 'package:flutter/material.dart';

import '../data/laundry_repository.dart';
import '../models/laundry_order.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/demo_data_banner.dart';
import '../widgets/status_chip.dart';
import 'order_details_screen.dart';

/// Digital order ticket: the screen staff hand to a customer after the
/// laundry is received. It is only shown for orders staff actually created.
class OrderTicketScreen extends StatelessWidget {
  const OrderTicketScreen({
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
            appBar: AppBar(title: const Text('Order ticket')),
            body: const Center(child: Text('This order ticket is no longer available.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Order ticket')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    Text(
                      'Your laundry ticket',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep this Order ID for tracking and pickup.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    _TicketCard(order: order),
                    if (order.isDemo) ...[
                      const SizedBox(height: 14),
                      const DemoDataBanner(
                        message: 'Sample ticket for preview only. This is '
                            'demo data, not a real customer order.',
                      ),
                    ],
                    const SizedBox(height: 14),
                    _SaveInstructions(orderId: order.orderId),
                    const SizedBox(height: 22),
                    AppButton(
                      label: 'Track this order',
                      icon: Icons.insights_rounded,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => OrderDetailsScreen(
                              repository: repository,
                              orderId: order.orderId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Done',
                      icon: Icons.check_rounded,
                      outlined: true,
                      onPressed: () =>
                          Navigator.of(context).popUntil((route) => route.isFirst),
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

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.order});

  final LaundryOrder order;

  @override
  Widget build(BuildContext context) {
    final receivedDate = MaterialLocalizations.of(context)
        .formatMediumDate(order.receivedAt);
    final receivedTime =
        TimeOfDay.fromDateTime(order.receivedAt).format(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4E8E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14344737),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            color: const Color(0xFF214A3A),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.local_laundry_service_rounded,
                    size: 20,
                    color: Color(0xFF214A3A),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FOLDFLOW',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                            ),
                      ),
                      Text(
                        'Laundry drop-off ticket',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFC8DACD),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORDER ID',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7C8A7F),
                      ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  order.orderId,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 34,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 12),
                StatusChip(status: order.status),
                const SizedBox(height: 18),
                DetailRow(label: 'Customer', value: order.customerName),
                DetailRow(label: 'Contact', value: order.contactNumber),
                DetailRow(label: 'Received', value: '$receivedDate · $receivedTime'),
                DetailRow(
                  label: 'Weight',
                  value: '${order.weightKg.toStringAsFixed(1)} kg',
                ),
                if (order.reservationReference != null)
                  DetailRow(
                    label: 'Reservation',
                    value: order.reservationReference!,
                  ),
                if (order.payment != null)
                  DetailRow(
                    label: 'Payment',
                    value: '${order.payment!.amount.toStringAsFixed(2)} · '
                        '${order.payment!.method}',
                    emphasised: true,
                  )
                else
                  const DetailRow(
                    label: 'Payment',
                    value: 'Settled at the shop',
                  ),
              ],
            ),
          ),
          const _DashedDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Present this Order ID to staff for tracking and pickup.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF425648),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment and release of the laundry are handled at the shop.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B776F),
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

class _SaveInstructions extends StatelessWidget {
  const _SaveInstructions({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Screenshot or note the Order ID — you need it to track your laundry.',
      'Enter the Order ID under “Track my laundry” any time.',
      'Present the Order ID to staff when you pick up your laundry.',
      'Pay at the shop; staff release the laundry after payment.',
    ];

    return AppCard(
      color: const Color(0xFFF0F4EA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW TO USE YOUR ORDER ID',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4E6554),
                ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF214A3A),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      i == 0 ? steps[i].replaceAll('Order ID', 'Order ID ($orderId)') : steps[i],
                      style: Theme.of(context).textTheme.bodyMedium,
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

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    // Fixed dash count: the row is inside a bounded card, so the perforation
    // always fits without needing to measure the available width.
    const dashCount = 40;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < dashCount; i++)
            Container(
              width: 6,
              height: 2,
              color: const Color(0xFFDCE3DB),
            ),
        ],
      ),
    );
  }
}
