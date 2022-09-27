import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../../common_widgets/custom_alert_dialog.dart';
import '../../../../../common_widgets/custom_snack_bar.dart';
import '../../../../../helpers/context_extensions.dart';
import '../../../../auth/presentation/user_controller.dart';
import '../../../domain/deal.dart';
import '../deal_details_controller.dart';
import 'report_deal_dialog.dart';

enum _DealPopup {
  deleteDeal,
  markAsActive,
  markAsExpired,
  reportDeal,
  updateDeal
}

class DealDetailsScreenAppBar extends ConsumerWidget {
  const DealDetailsScreenAppBar({required this.deal, super.key});

  final Deal deal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final userIsPoster = user.id! == deal.postedBy!;

    Future<void> onDeleteButtonPressed() => CustomAlertDialog(
          title: context.l.deleteConfirm,
          cancelActionText: context.l.cancel,
          defaultAction: () => ref
              .read(dealDetailsControllerProvider(deal.id!).notifier)
              .deleteDeal(
                onSuccess: context.pop,
                onFailure: () =>
                    CustomSnackBar.error(text: context.l.deleteDealError)
                        .showSnackBar(context),
              ),
          defaultActionText: context.l.delete,
        ).show(context);

    void updateDealStatus(DealStatus status) => ref
        .read(dealDetailsControllerProvider(deal.id!).notifier)
        .updateDealStatus(
          status,
          onSuccess: () => CustomSnackBar.success(
            text: status == DealStatus.active
                ? context.l.markAsActiveSuccess
                : context.l.markAsExpiredSuccess,
          ).showSnackBar(context),
          onFailure: () => const CustomSnackBar.error().showSnackBar(context),
        );

    Future<void> onReportButtonPressed() => showDialog<void>(
          context: context,
          builder: (context) => ReportDealDialog(dealId: deal.id!),
        );

    void onUpdateButtonPressed(Deal deal) =>
        context.go('/update-deal', extra: deal);

    final items = <PopupMenuItem<_DealPopup>>[
      if (userIsPoster) ...[
        if (deal.status == DealStatus.expired)
          PopupMenuItem<_DealPopup>(
            value: _DealPopup.markAsActive,
            child: Text(context.l.markAsActive),
          )
        else if (deal.status == DealStatus.active)
          PopupMenuItem<_DealPopup>(
            value: _DealPopup.markAsExpired,
            child: Text(context.l.markAsExpired),
          ),
        PopupMenuItem<_DealPopup>(
          value: _DealPopup.updateDeal,
          child: Text(context.l.updateDeal),
        ),
        PopupMenuItem<_DealPopup>(
          value: _DealPopup.deleteDeal,
          child: Text(context.l.deleteDeal),
        ),
      ],
      if (!userIsPoster)
        PopupMenuItem<_DealPopup>(
          value: _DealPopup.reportDeal,
          child: Text(context.l.reportDeal),
        ),
    ];

    return AppBar(
      actions: [
        if (items.isNotEmpty)
          PopupMenuButton<_DealPopup>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => items,
            onSelected: (result) async {
              switch (result) {
                case _DealPopup.deleteDeal:
                  await onDeleteButtonPressed();
                  break;
                case _DealPopup.markAsActive:
                  updateDealStatus(DealStatus.active);
                  break;
                case _DealPopup.markAsExpired:
                  updateDealStatus(DealStatus.expired);
                  break;
                case _DealPopup.reportDeal:
                  await onReportButtonPressed();
                  break;
                case _DealPopup.updateDeal:
                  onUpdateButtonPressed(deal);
                  break;
              }
            },
          ),
      ],
      centerTitle: true,
      leading: IconButton(
        onPressed: context.pop,
        icon: const Icon(FontAwesomeIcons.arrowLeft, size: 20),
      ),
      title: Text(deal.title),
    );
  }
}
