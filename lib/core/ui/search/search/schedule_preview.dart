import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tumble/core/api/apiservices/runtime_error_type.dart';
import 'package:tumble/core/navigation/app_navigator.dart';
import 'package:tumble/core/ui/bottom_nav_bar/cubit/bottom_nav_cubit.dart';
import 'package:tumble/core/ui/schedule/no_schedule.dart';
import 'package:tumble/core/ui/schedule/tumble_list_view/data/cupertino_alerts.dart';
import 'package:tumble/core/ui/schedule/tumble_list_view/data/to_top_button.dart';
import 'package:tumble/core/ui/schedule/tumble_list_view/tumble_list_view_day_container.dart';
import 'package:tumble/core/ui/search/cubit/search_page_cubit.dart';
import 'package:tumble/core/ui/search/search/preview_list_view_day_container.dart';

typedef ToggleBookmark = Function(bool value);

class SchedulePreview extends StatefulWidget {
  final ToggleBookmark toggleBookmark;
  const SchedulePreview({Key? key, required this.toggleBookmark})
      : super(key: key);

  @override
  State<SchedulePreview> createState() => _SchedulePreviewState();
}

/// Requires context from parent SearchPageCubit and MainAppNavigationCubit
class _SchedulePreviewState extends State<SchedulePreview> {
  @override
  Widget build(BuildContext context) {
    final AppNavigator navigator = BlocProvider.of<AppNavigator>(context);
    return BlocConsumer<SearchPageCubit, SearchPageState>(
      listener: (context, state) {
        if (state.previewFetchStatus == PreviewFetchStatus.FETCHED_SCHEDULE ||
            state.previewFetchStatus == PreviewFetchStatus.CACHED_SCHEDULE) {
          widget.toggleBookmark;
        }
      },
      builder: (context, state) {
        switch (state.previewFetchStatus) {
          case PreviewFetchStatus.LOADING:
            return SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.primary);
          case PreviewFetchStatus.FETCHED_SCHEDULE:
          case PreviewFetchStatus.CACHED_SCHEDULE:
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: SingleChildScrollView(
                    controller: context.read<SearchPageCubit>().controller,
                    child: Column(
                        children: state.previewListOfDays!
                            .where((day) =>
                                day.events.isNotEmpty &&
                                day.isoString.isAfter(DateTime.now()
                                    .subtract(const Duration(days: 1))))
                            .map((day) => PreviewListViewDayContainer(
                                  day: day,
                                  searchPageCubit:
                                      BlocProvider.of<SearchPageCubit>(context),
                                ))
                            .toList()),
                  ),
                ),
                AnimatedPositioned(
                  bottom: 30,
                  right: state.previewToTopButtonVisible! ? 35 : -60,
                  duration: const Duration(milliseconds: 200),
                  child: ToTopButton(
                      scrollToTop: () =>
                          context.read<SearchPageCubit>().scrollToTop()),
                ),
              ],
            );
          case PreviewFetchStatus.FETCH_ERROR:
            return NoScheduleAvailable(
              errorType: 'Schedule is missing',
              cupertinoAlertDialog: CustomCupertinoAlerts.fetchError(
                  context, () => null, navigator),
            );
          case PreviewFetchStatus.EMPTY_SCHEDULE:
            return NoScheduleAvailable(
              errorType: RuntimeErrorType.emptyScheduleError,
              cupertinoAlertDialog:
                  CustomCupertinoAlerts.previewContainsNoViews(
                      context, () => null, navigator),
            );
          case PreviewFetchStatus.INITIAL:
            return Container();
        }
      },
    );
  }
}
