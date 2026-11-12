import 'package:flutter/material.dart';

import '../data/laundry_repository.dart';
import '../models/laundry_order.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/status_chip.dart';
import 'order_ticket_screen.dart';
import 'reservation_screen.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.repository,
    super.key,
  });

  final LaundryRepository repository;

  @override
  Widget build(BuildContext context) {
    final sampleOrder = repository.orderById(kDemoOrderId);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandHeader(),
                  const SizedBox(height: 30),
                  Text(
                    'WELCOME TO FOLDFLOW',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF6C7D70),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Laundry day,\nmade lighter.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 36,
                          height: 1.14,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Schedule your drop-off and follow every load from our '
                    'counter back to your closet.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 26),
                  AppButton(
                    label: 'Book a drop-off',
                    icon: Icons.calendar_month_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReservationScreen(
                            repository: repository,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Track my laundry',
                    icon: Icons.local_laundry_service_outlined,
                    outlined: true,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TrackingScreen(
                            repository: repository,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  const _LaundryIllustration(),
                  if (sampleOrder != null) ...[
                    const SizedBox(height: 16),
                    _SampleOrderCard(
                      order: sampleOrder,
                      repository: repository,
                    ),
                  ],
                  const SizedBox(height: 22),
                  const _ServiceNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE9EFE7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.local_laundry_service_rounded,
            color: Color(0xFF214A3A),
          ),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FoldFlow',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 19,
                  ),
            ),
            Text(
              'SMART LAUNDRY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.4,
                    color: const Color(0xFF78847B),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LaundryIllustration extends StatelessWidget {
  const _LaundryIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -26,
            top: -46,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFD7E4D8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFD8E4D7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF62806A),
              ),
            ),
          ),
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: const Color(0xFF214A3A),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22344737),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_laundry_service_rounded,
              size: 58,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 26,
            left: 42,
            child: _FloatingIcon(
              icon: Icons.checkroom_rounded,
              backgroundColor: Color(0xFFF9F5EA),
            ),
          ),
          Positioned(
            right: 42,
            bottom: 24,
            child: _FloatingIcon(
              icon: Icons.dry_cleaning_rounded,
              backgroundColor: Color(0xFFF9F5EA),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({
    required this.icon,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: const Color(0xFF49684E), size: 23),
    );
  }
}

/// Clearly labeled demo order shown under the illustration.
class _SampleOrderCard extends StatelessWidget {
  const _SampleOrderCard({
    required this.order,
    required this.repository,
  });

  final LaundryOrder order;
  final LaundryRepository repository;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderTicketScreen(
                repository: repository,
                orderId: order.orderId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF214A3A),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAMPLE ORDER · DEMO DATA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7C8A7F),
                          ),
                    ),
                    const SizedBox(height: 3),
                    SelectableText(
                      order.orderId,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Preview the ticket. This is not a real order.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B776F),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(status: order.status),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF8A948C),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceNote extends StatelessWidget {
  const _ServiceNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.eco_outlined,
          size: 17,
          color: Color(0xFF64806A),
        ),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            'Thoughtful laundry care, at your pace',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF657168),
                ),
          ),
        ),
      ],
    );
  }
}
