import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tumble/ui/main_app_widget/search_page_widgets/cubit/search_page_cubit.dart';

class ScheduleSearchBar extends StatefulWidget {
  const ScheduleSearchBar({Key? key}) : super(key: key);

  @override
  State<ScheduleSearchBar> createState() => _ScheduleSearchBarState();
}

class _ScheduleSearchBarState extends State<ScheduleSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                  color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
            ],
          ),
          child: BlocBuilder<SearchPageCubit, SearchPageState>(
            builder: (context, state) {
              return TextField(
                  onSubmitted: (value) async {
                    if (value.trim().isNotEmpty) {
                      await context.read<SearchPageCubit>().search();
                    }
                  },
                  autocorrect: false,
                  focusNode: context.read<SearchPageCubit>().focusNode,
                  controller:
                      context.read<SearchPageCubit>().textEditingController,
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    suffixIcon: () {
                      if (state is SearchPageFocused) {
                        return IconButton(
                          onPressed: context
                              .read<SearchPageCubit>()
                              .textEditingController
                              .clear,
                          icon: const Icon(CupertinoIcons.clear),
                        );
                      }
                    }(),
                    border: InputBorder.none,
                    hintText: "Search schedules",
                    hintMaxLines: 1,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                  ));
            },
          ),
        )),
        Container(
          height: 50,
          width: 50,
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                  color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))
            ],
          ),
          child: MaterialButton(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            onPressed: () async {
              await context.read<SearchPageCubit>().search();
            },
            disabledColor: Colors.orange.shade200,
            visualDensity: VisualDensity.compact,
            splashColor: Colors.white.withOpacity(0.4),
            child: Icon(
              CupertinoIcons.search,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
