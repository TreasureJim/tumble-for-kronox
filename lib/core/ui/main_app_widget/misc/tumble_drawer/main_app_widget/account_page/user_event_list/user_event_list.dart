import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tumble/core/ui/main_app_widget/misc/tumble_drawer/auth_cubit/auth_cubit.dart';
import 'package:tumble/core/ui/main_app_widget/misc/tumble_drawer/main_app_widget/account_page/user_event_list/cubit/user_event_list_cubit.dart';
import 'package:tumble/core/ui/main_app_widget/misc/tumble_drawer/main_app_widget/account_page/widgets/available_event_card.dart';

class UserEventList extends StatefulWidget {
  const UserEventList({Key? key}) : super(key: key);

  @override
  State<UserEventList> createState() => _UserEventListState();
}

class _UserEventListState extends State<UserEventList> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserEventListCubit, UserEventListState>(
      listener: (context, state) {
        if (state.status == UserEventListStatus.LOADING &&
            state.refreshSession) {
          BlocProvider.of<AuthCubit>(context).login();
          BlocProvider.of<UserEventListCubit>(context).getUserEvents(
              BlocProvider.of<AuthCubit>(context)
                  .state
                  .userSession!
                  .sessionToken);
        }
      },
      bloc: BlocProvider.of(context)
        ..getUserEvents(
          BlocProvider.of<AuthCubit>(context).state.userSession!.sessionToken,
        ),
      builder: (context, state) {
        return Builder(
          builder: (context) {
            switch (state.status) {
              case UserEventListStatus.LOADING:
                return SpinKitThreeBounce(
                    color: Theme.of(context).colorScheme.primary);
              case UserEventListStatus.LOADED:
                return _loaded(context, state);
              case UserEventListStatus.ERROR:
                return Text(
                  "We couldn't get your exams, try again in a bit.",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground),
                );
            }
          },
        );
      },
    );
  }
}

Widget _loaded(BuildContext context, UserEventListState state) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      _availableUserEventsDivider(context, state),
      state.userEvents!.registeredEvents.isEmpty
          ? Text(
              "No exams available right now.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )
          : Container(),
      Column(
        children: state.userEvents!.unregisteredEvents.isNotEmpty
            ? state.userEvents!.unregisteredEvents
                .map((e) => AvailableEventCard(event: e))
                .toList()
            : state.userEvents!.registeredEvents
                .map((e) => AvailableEventCard(event: e))
                .toList(),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: TextButton(
          onPressed: () => {},
          style: ButtonStyle(
              side: MaterialStateProperty.all(BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ))),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "See all exams",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(
                  CupertinoIcons.chevron_down,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      )
    ],
  );
}

Widget _availableUserEventsDivider(
    BuildContext context, UserEventListState state) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          state.userEvents!.unregisteredEvents.isNotEmpty
              ? "Available exams"
              : "Your upcoming exams",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      Expanded(
        child: Divider(
          color: Theme.of(context).colorScheme.onBackground,
          thickness: 1,
        ),
      ),
      IconButton(
          padding: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.primary,
          splashRadius: 24,
          onPressed: () =>
              BlocProvider.of<UserEventListCubit>(context).getUserEvents(
                BlocProvider.of<AuthCubit>(context)
                    .state
                    .userSession!
                    .sessionToken,
              ),
          icon: const Icon(CupertinoIcons.refresh)),
    ],
  );
}

Widget _seeAllUserEvents(BuildContext context, UserEventListState state) {
  return TextButton(
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        backgroundColor:
            MaterialStateProperty.resolveWith((states) => Colors.transparent),
      ),
      onPressed: () => {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "see all exams",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Icon(
              CupertinoIcons.arrow_right,
              size: 14,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          )
        ],
      ));
}
