import 'package:flutter/material.dart';

import '../models/reservation.dart';
import '../widgets/app_button.dart';
import '../widgets/demo_data_banner.dart';

class ReservationConfirmationScreen extends StatelessWidget {
  const ReservationConfirmationScreen({
    required this.request,
    super.key,
  });

  final ReservationRequest request;

  @override
  Widget build(BuildContext context) {
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(request.dropOffDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Request details')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F0E6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Color(0xFF356B4F),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  request.isDemo ? 'Request prepared' : 'Request saved',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep this reference handy. Your selected time is a request '
                  'until laundry staff confirm it.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE8EAE4)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REQUEST REFERENCE',
                          style: TextStyle(
                            color: Color(0xFF77837A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SelectableText(
                          request.reference,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(height: 28),
                        _DetailRow(label: 'Name', value: request.customerName),
                        _DetailRow(label: 'Contact', value: request.contactNumber),
                        _DetailRow(label: 'Drop-off date', value: date),
                        _DetailRow(label: 'Drop-off time', value: request.dropOffTime),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                DemoDataBanner(
                  message: request.isDemo
                      ? 'This reference was created for this app session '
                          'only. It has not been sent to staff or saved to a '
                          'server.'
                      : 'Your reservation request was saved. It is not an '
                          'order yet: staff will confirm it and create the '
                          'order when they receive and weigh the laundry.',
                ),
                const SizedBox(height: 22),
                AppButton(
                  label: 'Back to FoldFlow',
                  icon: Icons.home_outlined,
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
