import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/orders_controller.dart';

class DisputeFormScreen extends ConsumerStatefulWidget {
  final String orderId;

  const DisputeFormScreen({super.key, required this.orderId});

  @override
  ConsumerState<DisputeFormScreen> createState() => _DisputeFormScreenState();
}

class _DisputeFormScreenState extends ConsumerState<DisputeFormScreen> {
  final _reasonCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reasonCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(orderRepositoryProvider).submitDispute(
        orderId: widget.orderId,
        reason: _reasonCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispute submitted successfully!'), backgroundColor: AppTheme.emeraldGreen),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File a Dispute')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(label: 'Dispute Reason', hintText: 'e.g. Material damaged / Wrong quantity', controller: _reasonCtrl),
            const SizedBox(height: 16),
            CustomTextField(label: 'Detailed Description', hintText: 'Explain the issue in detail...', controller: _descCtrl, maxLines: 4),
            const Spacer(),
            CustomButton(text: 'Submit Dispute', isLoading: _isSubmitting, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
