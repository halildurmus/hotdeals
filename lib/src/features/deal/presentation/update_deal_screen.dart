import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common_widgets/custom_snack_bar.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../helpers/context_extensions.dart';
import '../domain/deal.dart';
import 'widgets/deal_form.dart';

class UpdateDealScreen extends ConsumerStatefulWidget {
  const UpdateDealScreen({required this.deal, super.key});

  final Deal deal;

  @override
  ConsumerState<UpdateDealScreen> createState() => _UpdateDealScreenState();
}

class _UpdateDealScreenState extends ConsumerState<UpdateDealScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.l.updateDeal),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DealForm(
            buttonTitle: context.l.updateDeal,
            deal: widget.deal,
            onPressed: (deal) async {
              final updatedDeal = await AsyncValue.guard(() =>
                  ref.read(hotdealsRepositoryProvider).updateDeal(deal: deal));
              if (!mounted) return;
              // Pops the loading dialog.
              Navigator.of(context).pop();
              updatedDeal.maybeWhen(
                data: (data) {
                  CustomSnackBar.success(
                    text: context.l.successfullyUpdatedYourDeal,
                  ).showSnackBar(context);
                  context.go('/deals/${data.id}');
                },
                orElse: () =>
                    const CustomSnackBar.error().showSnackBar(context),
              );
            },
          ),
        ),
      ),
    );
  }
}
