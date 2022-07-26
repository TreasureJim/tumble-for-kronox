// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumble/api/apiservices/api_response.dart';
import 'package:tumble/api/repository/implementation_repository.dart';
import 'package:tumble/database/repository/database_repository.dart';
import 'package:tumble/extensions/extensions.dart';
import 'package:tumble/models/api_models/schedule_model.dart';
import 'package:tumble/models/ui_models/week_model.dart';
import 'package:tumble/shared/preference_types.dart';
import 'package:tumble/startup/get_it_instances.dart';
import 'package:tumble/ui/home_page_widget/data/event_types.dart';

import '../../search_page_widgets/search/schedule_search_page.dart';

part 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit() : super(const HomePageInitial());

  final _sharedPrefs = locator<SharedPreferences>();
  final _implementationService = locator<ImplementationRepository>();
  List<HomePageState> _states = [];

  int _currentPageIndex = 0;

  late List<Week> _listOfWeeks;
  late List<Day> _listOfDays;

  int? get defaultViewType => locator<SharedPreferences>().getInt(PreferenceTypes.view);
  int get currentPageIndex => _currentPageIndex;

  /// Handles the loading of the schedule upon choosing a program
  Future<void> init(String scheduleId) async {
    log("BEFORE HOME PAGE LOAD");
    emit(const HomePageLoading());
    log("AFTER HOME PAGE LOAD");
    _currentPageIndex = defaultViewType!;
    log("BEFORE GET SCHEDULE");
    final _response = await _implementationService.getSchedule(scheduleId);
    log("Response: ${_response.message}\nStatus:${_response.status}");
    switch (_response.status) {
      case Status.COMPLETED:
        log('here');
        final ScheduleModel scheduleModel = _response.data!;

        /// Now we have an instance of the list used in
        /// [TumbleListView] and an instance of the list
        /// used in [TumbleWeekView]
        _listOfDays = scheduleModel.days;
        _listOfWeeks = scheduleModel.splitToWeek();
        setStateParameters(scheduleId, _listOfDays, _listOfWeeks);
        emit(_states[locator<SharedPreferences>().getInt(PreferenceTypes.view)!]);
        break;
      case Status.ERROR:
        emit(HomePageError(errorType: _response.message!));
        break;
      default:
        emit(const HomePageInitial());
        break;
    }
  }

  void setStateParameters(String scheduleId, List<Day> listOfDays, List<Week> listOfWeeks) {
    _states = [
      HomePageListView(scheduleId: scheduleId, listOfDays: listOfDays),
      HomePageWeekView(scheduleId: scheduleId, listOfWeeks: listOfWeeks)
    ];
  }

  void setPage(int index) {
    _currentPageIndex = index;
    if (state is! HomePageError) {
      emit(_states[index]);
    }
  }

  void navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => const ScheduleSearchPage()),
    );
  }

  void assignFavorite(String scheduleId) {
    final currentFavorites = _sharedPrefs.getStringList(PreferenceTypes.favorites);
    currentFavorites!.add(scheduleId);
    _sharedPrefs.setStringList(PreferenceTypes.favorites, currentFavorites);
  }

  handleDrawerEvent(Enum eventType, BuildContext context) {
    switch (eventType) {
      case EventType.CANCEL_ALL_NOTIFICATIONS:
        break;
      case EventType.CANCEL_NOTIFICATIONS_FOR_PROGRAM:
        break;
      case EventType.CHANGE_SCHOOL:
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const ScheduleSearchPage()),
        );
        break;
      case EventType.CHANGE_THEME:
        break;
      case EventType.CONTACT:
        break;
      case EventType.EDIT_NOTIFICATION_TIME:
        break;
      case EventType.SET_DEFAULT_SCHEDULE:
        break;
      case EventType.SET_DEFAULT_VIEW:
        break;
    }
  }
}
