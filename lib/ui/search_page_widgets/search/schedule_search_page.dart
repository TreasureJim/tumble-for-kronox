import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tumble/theme/colors.dart';
import 'package:tumble/ui/home_page_widget/home_page.dart';
import 'package:tumble/ui/search_page_widgets/search/program_card.dart';
import 'package:tumble/ui/search_page_widgets/search/schedule_search_bar.dart';
import 'package:tumble/ui/search_page_widgets/search_bar_widget/searchbar_and_logo_container.dart';

import '../cubit/search_page_cubit.dart';

class ScheduleSearchPage extends StatefulWidget {
  const ScheduleSearchPage({Key? key}) : super(key: key);

  @override
  State<ScheduleSearchPage> createState() => _ScheduleSearchPageState();
}

class _ScheduleSearchPageState extends State<ScheduleSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top + 50),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: BlocBuilder<SearchPageCubit, SearchPageState>(
                        builder: (context, state) {
                          if (state is SearchPageLoading) {
                            return const SpinKitThreeBounce(
                                color: CustomColors.orangePrimary);
                          }
                          if (state is SearchPageFoundSchedules) {
                            return ListView(
                              padding: const EdgeInsets.only(top: 70),
                              children: state.programList
                                  .map((program) => ProgramCard(
                                      programName: program.scheduleName,
                                      programId: program.scheduleId,
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => HomePage(
                                                    currentScheduleId:
                                                        program.scheduleId)));
                                      }))
                                  .toList(),
                            );
                          }
                          if (state is SearchPageNoSchedules) {
                            return Center(
                              child: Text(
                                "No schedules found",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      )),
                )
              ],
            ),
          ),
          const SearchBarAndLogoContainer(),
        ],
      ),
    );
  }
}
