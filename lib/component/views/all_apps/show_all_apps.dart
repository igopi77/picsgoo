import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsgoo/component/models/apps_model.dart';
import 'package:picsgoo/component/widgets/wallpaper_background.dart';

import '../../blocs/root_bloc/root_bloc.dart';

class AllAppsView extends StatefulWidget {
  final InitialAllAppsLoadedState state;

  const AllAppsView({super.key, required this.state});

  @override
  State<AllAppsView> createState() => _AllAppsViewState();
}

class _AllAppsViewState extends State<AllAppsView> {
  final TextEditingController _searchController = TextEditingController();
  List<AppsModel> _filteredApps = [];

  @override
  void initState() {
    super.initState();
    _filteredApps = widget.state.allApps; // initial
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps = widget.state.allApps
          .where((appInfo) =>
          appInfo.app.appName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WallpaperBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Time + Date
            Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: StreamBuilder<DateTime>(
                stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                initialData: DateTime.now(),
                builder: (context, snapshot) {
                  final now = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            /// Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search apps...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white10,
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// Apps List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredApps.length,
                itemBuilder: (context, index) {
                  final app = _filteredApps[index].app;
                  return ListTile(
                    title: Row(
                      children: [
                        if (app is ApplicationWithIcon)
                          Image.memory(
                            app.icon,
                            width: 40,
                            height: 40,
                          ),
                        const SizedBox(width: 20),
                        Text(
                          app.appName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onTap: () {
                      context.read<RootBloc>().add(
                        LaunchAppEvent(packageName: app.packageName),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
