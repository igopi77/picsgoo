import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/root_bloc/root_bloc.dart';

class WallpaperBackground extends StatelessWidget {
  final Widget child;

  const WallpaperBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RootBloc, RootState>(
      buildWhen: (previous, current) => current is WallpaperLoadedState,
      builder: (context, state) {
        String wallpaperPath = 'assets/wallpapers/0.jpg'; // default

        if (state is WallpaperLoadedState) {
          wallpaperPath = state.currentWallpaper;
        } else {
          // Get current wallpaper from bloc
          wallpaperPath = context.read<RootBloc>().currentWallpaper;
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(wallpaperPath),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        );
      },
    );
  }
}