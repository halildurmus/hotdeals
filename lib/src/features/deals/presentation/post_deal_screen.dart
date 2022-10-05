import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../common_widgets/custom_snack_bar.dart';
import '../../../core/hotdeals_repository.dart';
import '../../../helpers/context_extensions.dart';
import 'widgets/deal_form.dart';

class PostDealScreen extends ConsumerStatefulWidget {
  const PostDealScreen({super.key});

  @override
  ConsumerState<PostDealScreen> createState() => _PostDealScreenState();
}

class _PostDealScreenState extends ConsumerState<PostDealScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.l.postADeal),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DealForm(
            buttonTitle: context.l.postDeal,
            onPressed: (deal) async {
              final postedDeal = await AsyncValue.guard(() =>
                  ref.read(hotdealsRepositoryProvider).postDeal(deal: deal));
              if (!mounted) return;
              // Pops the loading dialog.
              Navigator.of(context).pop();
              postedDeal.maybeWhen(
                data: (data) {
                  CustomSnackBar.success(
                    text: context.l.successfullyPostedYourDeal,
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
