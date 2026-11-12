import 'package:flutter/material.dart';

import '../data/laundry_repository.dart';
import '../models/reservation.dart';
import '../widgets/app_button.dart';
import '../widgets/labeled_text_field.dart';
import 'reservation_confirmation_screen.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({
    required this.repository,
    super.key,
  });

  final LaundryRepository repository;

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dropOffDate;
  TimeOfDay? _dropOffTime;
  bool _isSubmitting = false;
  bool _hasAttemptedSubmit = false;
  String? _submissionError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: _dropOffDate ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Choose a drop-off date',
    );

    if (selected != null && mounted) {
      setState(() => _dropOffDate = selected);
    }
  }

  Future<void> _chooseTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _dropOffTime ?? const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Choose a drop-off time',
    );

    if (selected != null && mounted) {
      setState(() => _dropOffTime = selected);
    }
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid contact number';
    }
    return null;
  }

  Future<void> _submit() async {
    setState(() {
      _hasAttemptedSubmit = true;
      _submissionError = null;
    });
    final formIsValid = _formKey.currentState?.validate() ?? false;
    if (!formIsValid || _dropOffDate == null || _dropOffTime == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      late final ReservationRequest request;
      try {
        request = await widget.repository.submitReservation(
          customerName: _nameController.text.trim(),
          contactNumber: _phoneController.text.trim(),
          dropOffDate: _dropOffDate!,
          dropOffTime: _dropOffTime!.format(context),
        );
      } catch (error) {
        debugPrint('FoldFlow reservation request failed: $error');
        if (!mounted) return;
        setState(() {
          _submissionError = 'Could not save your reservation: $error';
        });
        return;
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReservationConfirmationScreen(request: request),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a drop-off')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  Text(
                    'Plan your visit',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your details and a convenient time. Our team '
                    'will need to confirm your request.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  LabeledTextField(
                    label: 'Customer name',
                    controller: _nameController,
                    hintText: 'Your full name',
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if ((value ?? '').trim().length < 2) {
                        return 'Enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  LabeledTextField(
                    label: 'Contact number',
                    controller: _phoneController,
                    hintText: 'e.g. +1 555 010 1234',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Preferred drop-off date',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: Icons.calendar_today_rounded,
                    value: _dropOffDate == null
                        ? 'Select a date'
                        : MaterialLocalizations.of(context)
                            .formatMediumDate(_dropOffDate!),
                    onTap: _chooseDate,
                    error: _hasAttemptedSubmit && _dropOffDate == null
                        ? 'Choose a date to continue'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Preferred drop-off time',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _PickerTile(
                    icon: Icons.schedule_rounded,
                    value: _dropOffTime?.format(context) ?? 'Select a time',
                    onTap: _chooseTime,
                    error: _hasAttemptedSubmit && _dropOffTime == null
                        ? 'Choose a time to continue'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4EA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      widget.repository.isDemoDataOnly
                          ? 'This is a booking request, not a confirmed '
                              'appointment. It is prepared for this app '
                              'session only and is not sent to the laundry '
                              'shop or saved to a server.'
                          : 'This is a booking request, not a confirmed '
                              'appointment. The shop saves it in its system '
                              'and staff confirm it at the counter, where '
                              'your Order ID is issued.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF46594A),
                            height: 1.45,
                          ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppButton(
                    label: _isSubmitting
                        ? 'Preparing request...'
                        : 'Submit Reservation',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                  if (_submissionError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _submissionError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.value,
    required this.onTap,
    required this.error,
  });

  final IconData icon;
  final String value;
  final VoidCallback onTap;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final selected = error == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFE3E7E1)
                      : const Color(0xFFDAA2A0),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: const Color(0xFF52705B)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const Icon(
                    Icons.expand_more_rounded,
                    color: Color(0xFF647068),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(left: 14, top: 6),
            child: Text(
              error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }
}
