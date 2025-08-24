import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsgoo/component/views/feeback/feeback_form.dart';
import 'package:picsgoo/component/views/select_wallpaper/select_wallpaper_view.dart';
import 'package:picsgoo/component/widgets/wallpaper_background.dart';

import '../../blocs/root_bloc/root_bloc.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return WallpaperBackground(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            forceMaterialTransparency: true,
            elevation: 0,
            title: Text('Settings', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: bodyPartOfSettings()
      ),
    );
  }

  Widget bodyPartOfSettings() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.wallpaper, color: Colors.white),
          title: Text(
              'Change Wallpaper', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SelectWallpaperView()));
          },
        ),
        BlocListener<RootBloc, RootState>(
          listener: (context, state) {
            if (state is SelectPriorityAppState) {
              Navigator.pop(context);
            }
          },
          child: ListTile(
            leading: Icon(Icons.apps, color: Colors.white),
            title: Text('Manage Priority Apps', style: TextStyle(color: Colors.white)),
            onTap: () {
              context.read<RootBloc>().add(EditPriorityAppsEvent());
            },
          ),
        ),
        ListTile(
          leading: Icon(Icons.feedback_outlined, color: Colors.white),
          title: Text('Send Feedback', style: TextStyle(color: Colors.white)),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen()));
          },
        ),
      ],
    );
  }
}
