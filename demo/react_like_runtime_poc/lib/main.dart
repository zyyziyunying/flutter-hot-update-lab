import 'package:flutter/material.dart';
import 'package:react_like_runtime_poc/src/app/poc_shell.dart';
import 'package:react_like_runtime_poc/src/runtime/flutter_js_runtime.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReactLikeRuntimePocApp());
}

class ReactLikeRuntimePocApp extends StatelessWidget {
  const ReactLikeRuntimePocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'React-Like Runtime PoC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF145DA0)),
      ),
      home: PocShell(runtimeFacade: const FlutterJsRuntimeFacade()),
    );
  }
}
