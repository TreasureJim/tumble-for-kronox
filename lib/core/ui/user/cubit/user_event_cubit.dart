import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tumble/core/api/apiservices/api_booking_response.dart';
import 'package:tumble/core/api/apiservices/api_user_response.dart';
import 'package:tumble/core/api/apiservices/runtime_error_type.dart';
import 'package:tumble/core/api/repository/user_repository.dart';
import 'package:tumble/core/dependency_injection/get_it_instances.dart';
import 'package:tumble/core/models/api_models/kronox_user_model.dart';
import 'package:tumble/core/models/api_models/resource_model.dart';
import 'package:tumble/core/models/api_models/user_event_collection_model.dart';
import 'package:tumble/core/shared/preference_types.dart';
import 'package:tumble/core/ui/login/cubit/auth_cubit.dart';
import 'package:tumble/core/ui/scaffold_message.dart';

part 'user_event_state.dart';

/// Handles user events and resource booking
class UserEventCubit extends Cubit<UserEventState> {
  UserEventCubit()
      : super(UserEventState(
          userEventListStatus: UserOverviewStatus.INITIAL,
          resourcePageStatus: ResourcePageStatus.INITIAL,
          userBookingsStatus: UserBookingsStatus.INITIAL,
          bookUnbookStatus: BookUnbookStatus.INITIAL,
          autoSignup: getIt<SharedPreferences>().getBool(PreferenceTypes.autoSignup)!,
        ));

  final _userRepo = getIt<UserRepository>();

  Future<void> getUserEvents(AuthStatus authStatus, KronoxUserModel? userSession) async {
    switch (authStatus) {
      case AuthStatus.AUTHENTICATED:
        emit(state.copyWith(userEventListStatus: UserOverviewStatus.LOADING));
        ApiUserResponse userEventResponse = await _userRepo.getUserEvents(userSession!.sessionToken);
        switch (userEventResponse.status) {
          case ApiUserResponseStatus.COMPLETED:
            emit(state.copyWith(
              userEventListStatus: UserOverviewStatus.LOADED,
              userEvents: userEventResponse.data!,
            ));
            break;
          case ApiUserResponseStatus.ERROR:
            emit(state);
            break;
          default:
            emit(state.copyWith(
              userEventListStatus: UserOverviewStatus.ERROR,
            ));
        }
        break;
      default:
        break;
    }
  }

  Future<void> registerUserEvent(String id, AuthStatus authStatus, KronoxUserModel? userSession) async {
    emit(state.copyWith(userEventListStatus: UserOverviewStatus.LOADING));
    ApiUserResponse registerResponse = await _userRepo.putRegisterUserEvent(id, userSession!.sessionToken);
    log(registerResponse.status.name);
    switch (registerResponse.status) {
      case ApiUserResponseStatus.COMPLETED:
      case ApiUserResponseStatus.AUTHORIZED:
        getUserEvents(authStatus, userSession);
        break;
      case ApiUserResponseStatus.UNAUTHORIZED:
        emit(
            state.copyWith(userEventListStatus: UserOverviewStatus.ERROR, errorMessage: RuntimeErrorType.loginError()));
        break;
      case ApiUserResponseStatus.ERROR:
        emit(state.copyWith(
            userEventListStatus: UserOverviewStatus.ERROR, errorMessage: RuntimeErrorType.failedExamSignUp()));
        break;
      default:
        emit(state.copyWith(
            userEventListStatus: UserOverviewStatus.ERROR, errorMessage: RuntimeErrorType.failedExamSignUp()));
    }
  }

  Future<void> unregisterUserEvent(String id, AuthStatus authStatus, KronoxUserModel? userSession) async {
    emit(state.copyWith(userEventListStatus: UserOverviewStatus.LOADING));
    ApiUserResponse unregisterResponse = await _userRepo.putUnregisterUserEvent(id, userSession!.sessionToken);

    switch (unregisterResponse.status) {
      case ApiUserResponseStatus.COMPLETED:
      case ApiUserResponseStatus.AUTHORIZED:
        getUserEvents(authStatus, userSession);
        break;
      case ApiUserResponseStatus.UNAUTHORIZED:
        emit(
            state.copyWith(userEventListStatus: UserOverviewStatus.ERROR, errorMessage: RuntimeErrorType.loginError()));
        break;
      case ApiUserResponseStatus.ERROR:
        emit(state.copyWith(
            userEventListStatus: UserOverviewStatus.ERROR, errorMessage: RuntimeErrorType.failedExamSignUp()));
        break;
      default:
        emit(state.copyWith(
            userEventListStatus: UserOverviewStatus.ERROR, errorMessage: RuntimeErrorType.failedExamSignUp()));
    }
  }

  Future<void> autoSignupToggle(bool value) async {
    getIt<SharedPreferences>().setBool(PreferenceTypes.autoSignup, value);
    emit(state.copyWith(autoSignup: value));
  }

  Future<void> getSchoolResources(KronoxUserModel? userSession) async {
    emit(state.copyWith(resourcePageStatus: ResourcePageStatus.LOADING));
    ApiBookingResponse schoolResources = await _userRepo.getSchoolResources(userSession!.sessionToken);

    switch (schoolResources.status) {
      case ApiBookingResponseStatus.SUCCESS:
        emit(state.copyWith(resourcePageStatus: ResourcePageStatus.LOADED, schoolResources: schoolResources.data));
        break;
      case ApiBookingResponseStatus.ERROR:
      case ApiBookingResponseStatus.UNAUTHORIZED:
      case ApiBookingResponseStatus.NOT_FOUND:
        emit(state.copyWith(
            resourcePageStatus: ResourcePageStatus.ERROR, resourcePageErrorMessage: schoolResources.data));
        break;
    }
  }

  Future<void> getResourceAvailabilities(KronoxUserModel? userSession, String resourceId, DateTime date) async {
    emit(state.copyWith(resourcePageStatus: ResourcePageStatus.LOADING));
    ApiBookingResponse currentSelectedResource =
        await _userRepo.getResourceAvailabilities(resourceId, date, userSession!.sessionToken);

    switch (currentSelectedResource.status) {
      case ApiBookingResponseStatus.SUCCESS:
        emit(state.copyWith(
            resourcePageStatus: ResourcePageStatus.LOADED, currentLoadedResource: currentSelectedResource.data));
        break;
      case ApiBookingResponseStatus.ERROR:
      case ApiBookingResponseStatus.UNAUTHORIZED:
      case ApiBookingResponseStatus.NOT_FOUND:
        emit(state.copyWith(
            resourcePageStatus: ResourcePageStatus.ERROR, resourcePageErrorMessage: currentSelectedResource.data));
        break;
    }
  }

  Future<void> getUserBookings(KronoxUserModel? userSession) async {
    emit(state.copyWith(userBookingsStatus: UserBookingsStatus.LOADING));
    ApiBookingResponse userBookings = await _userRepo.getUserBookings(userSession!.sessionToken);

    switch (userBookings.status) {
      case ApiBookingResponseStatus.SUCCESS:
        emit(state.copyWith(userBookingsStatus: UserBookingsStatus.LOADED, userBookings: userBookings.data));
        break;
      case ApiBookingResponseStatus.ERROR:
      case ApiBookingResponseStatus.UNAUTHORIZED:
      case ApiBookingResponseStatus.NOT_FOUND:
        emit(state.copyWith(userBookingsStatus: UserBookingsStatus.ERROR, userBookingsErrorMessage: userBookings.data));
        break;
    }
  }

  Future<void> bookResource(
      KronoxUserModel? userSession, String resourceId, DateTime date, AvailabilityValue bookingSlot) async {
    emit(state.copyWith(bookUnbookStatus: BookUnbookStatus.LOADING));
    ApiBookingResponse bookResource =
        await _userRepo.putBookResources(resourceId, date, bookingSlot, userSession!.sessionToken);

    switch (bookResource.status) {
      case ApiBookingResponseStatus.SUCCESS:
        getResourceAvailabilities(userSession, resourceId, date);
        break;
      default:
        break;
    }
    emit(state.copyWith(bookUnbookStatus: BookUnbookStatus.INITIAL));
    return bookResource.data;
  }

  Future<void> unbookResource(KronoxUserModel? userSession, String resourceId, DateTime date, String bookingId) async {
    emit(state.copyWith(bookUnbookStatus: BookUnbookStatus.LOADING));
    ApiBookingResponse bookResource = await _userRepo.putUnbookResources(userSession!.sessionToken, bookingId);

    switch (bookResource.status) {
      case ApiBookingResponseStatus.SUCCESS:
        getUserBookings(userSession);
        break;
      default:
        break;
    }
    emit(state.copyWith(bookUnbookStatus: BookUnbookStatus.INITIAL));
    return bookResource.data;
  }
}
