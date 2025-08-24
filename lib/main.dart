import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsgoo/component/blocs/root_bloc/root_bloc.dart';
import 'package:picsgoo/component/views/root_screen.dart';

void main() {
  Widget myApp = BlocProvider(
    create: (context) => RootBloc()..add(RootInitialEvent()),
    child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          '/': (context) =>
              const RootScreen(),
        }
    ),
  );
  runApp(myApp);
}