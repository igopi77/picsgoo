import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsgoo/component/blocs/root_bloc/root_bloc.dart';
import 'package:picsgoo/component/widgets/wallpaper_background.dart';

import 'all_apps/show_all_apps.dart';
import 'all_apps/show_prioritized_apps.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WallpaperBackground(
        child: bodyPartOfRootScreen(context),
      ),
    );
  }

  Widget bodyPartOfRootScreen(BuildContext context) {
    return BlocBuilder<RootBloc, RootState>(
      buildWhen: (previous, current) => current is RootScreeBuildState,
      builder: (context, state) {
         if (state is SelectPriorityAppState) {
          return appsToSelectPriorityView(state, context);
        } else if (state is LoadPrioritizedAppsState) {
          return ShowPrioritizedMainApps(state: state,);
        }
        return SizedBox();
      },
    );
  }


  Widget appsToSelectPriorityView(SelectPriorityAppState state, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 50, left: 20, bottom: 20),
          child: Text('Select Priority Apps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: state.allApps.length,
            itemBuilder: (context, index) {
              final app = state.allApps[index].app;
              final packageName = app.packageName;
              return CheckboxListTile(
                value: state.selectedPackages.contains(packageName),
                onChanged: (_) {
                  context.read<RootBloc>().add(TogglePriorityAppEvent(packageName));
                },
                title: Row(
                  children: [
                    if (state.allApps[index].app is ApplicationWithIcon)
                      Image.memory(
                        (state.allApps[index].app as ApplicationWithIcon).icon,
                        width: 40,
                        height: 40,
                      ),
                    const SizedBox(width: 20,),
                    Text(state.allApps[index].app.appName,
                      style: const TextStyle(color: Colors.white),),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.blue,
                checkColor: Colors.white,
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: Size(MediaQuery.of(context).size.width, 50)
            ),
              onPressed: state.selectedPackages.isEmpty ? null : () {
                // Save prioritized apps and load them
                context.read<RootBloc>().add(
                  SavePriorityAppsEvent(
                    packageNames: state.selectedPackages.toList(),
                  ),
                );
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                ),
              )
          ),
        )
      ],
    );
  }


  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
