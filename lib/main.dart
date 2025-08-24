import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsgoo/component/blocs/root_bloc/root_bloc.dart';
import 'package:picsgoo/component/views/root_screen.dart';

void main() {
  MaterialApp myApp = MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    routes: {
      '/': (context) => BlocProvider(
          create: (context) => RootBloc()..add(RootInitialEvent()),
          child: const RootScreen()
      ),
    }
  );
  runApp(myApp);
}