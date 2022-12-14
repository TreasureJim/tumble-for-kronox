import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tumble/core/ui/bottom_nav_bar/cubit/bottom_nav_cubit.dart';

import '../data/string_constants.dart';

typedef ChangePageCallBack = void Function(int index);

class TumbleNavigationBar extends StatelessWidget {
  final ChangePageCallBack? onTap;
  const TumbleNavigationBar({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainAppNavigationCubit, MainAppNavigationState>(
      builder: (context, mainappstate) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedIconTheme: const IconThemeData(size: 24),
          unselectedIconTheme: const IconThemeData(size: 22),
          onTap: onTap,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          showUnselectedLabels: false,
          currentIndex: mainappstate.index,
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(
                  CupertinoIcons.search,
                ),
                label: S.searchPage.title()),
            BottomNavigationBarItem(icon: const Icon(CupertinoIcons.collections), label: S.listViewPage.title()),
            BottomNavigationBarItem(icon: const Icon(CupertinoIcons.list_bullet_indent), label: S.weekViewPage.title()),
            BottomNavigationBarItem(icon: const Icon(CupertinoIcons.calendar_today), label: S.calendarViewPage.title()),
            BottomNavigationBarItem(icon: const Icon(CupertinoIcons.person), label: S.authorizedPage.title()),
          ],
        );
      },
    );
  }
}
