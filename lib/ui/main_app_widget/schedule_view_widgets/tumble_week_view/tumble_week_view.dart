import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tumble/ui/main_app_widget/cubit/main_app_cubit.dart';
import 'package:tumble/ui/main_app_widget/main_app_bottom_nav_bar/cubit/bottom_nav_cubit.dart';
import 'package:tumble/ui/main_app_widget/main_app_bottom_nav_bar/data/nav_bar_items.dart';
import 'package:tumble/ui/main_app_widget/schedule_view_widgets/no_schedule.dart';
import 'package:tumble/ui/main_app_widget/schedule_view_widgets/tumble_list_view/data/cupertino_alerts.dart';
import 'package:tumble/ui/main_app_widget/schedule_view_widgets/tumble_week_view/week_list_view.dart';

import '../../../../theme/data/colors.dart';

class TumbleWeekView extends StatefulWidget {
  const TumbleWeekView({Key? key}) : super(key: key);

  @override
  State<TumbleWeekView> createState() => _TumbleWeekViewState();
}

class _TumbleWeekViewState extends State<TumbleWeekView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainAppCubit, MainAppState>(
      builder: (context, state) {
        if (state is MainAppScheduleSelected) {
          final List<TumbleWeekPageContainer> tumbleWeekPageContainer =
              state.listOfWeeks
                  .map((e) => TumbleWeekPageContainer(
                        scheduleId: state.currentScheduleId,
                        week: e,
                      ))
                  .toList();
          if (tumbleWeekPageContainer.any((element) =>
              element.week.days.any((element) => element.events.isNotEmpty))) {
            return Stack(children: [
              SizedBox(
                  child: PageView.builder(
                      itemCount: state.listOfWeeks.length,
                      itemBuilder: (context, index) {
                        return tumbleWeekPageContainer[index];
                      }))
            ]);
          }
          return NoScheduleAvailable(
            errorType: 'Schedule is empty',
            cupertinoAlertDialog: CustomCupertinoAlerts.scheduleContainsNoViews(
                context,
                () => context
                    .read<MainAppNavigationCubit>()
                    .getNavBarItem(NavbarItem.SEARCH)),
          );
        }
        if (state is MainAppLoading) {
          return const SpinKitThreeBounce(color: CustomColors.orangePrimary);
        }
        return NoScheduleAvailable(
          errorType: 'No bookmarked schedules',
          cupertinoAlertDialog: CustomCupertinoAlerts.noBookMarkedSchedules(
              context,
              () => context
                  .read<MainAppNavigationCubit>()
                  .getNavBarItem(NavbarItem.SEARCH)),
        );
      },
    );
  }
}
