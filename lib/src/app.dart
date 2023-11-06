import 'package:flutter/material.dart';
import 'package:provide_addlistener/src/app_provider.dart';
import 'package:provider/provider.dart';

import './app_exports.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppProvider>(
      // App 전체에서 AppProvider() 의 인스턴스를 사용할 수 있도록 생성
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'addListener of ChangeNotifier Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Form 처리를 위한 GlobalKey 선언
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // Form 자동 Validation 시 1차 form submit 처리 후에만 validation 수행 선언
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  // 검색어
  String? searchTerm;

  void submit() async {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    // form 처리
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    // AppProvider() 의 intance 를 사용하여 검색작업 시작
    try {
      await context.read<AppProvider>().getResult(searchTerm);
      // AppProvider() 의 state 에 따라 화면 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SuccessPage(),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Something went wrong !'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppProvider() 의 state 관찰
    final appState = context.watch<AppProvider>().state;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(
          child: Form(
            key: formKey,
            autovalidateMode: autovalidateMode,
            child: ListView(
              shrinkWrap: true, // Center() 와 함께 children 중앙 배치
              children: [
                TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    label: Text('search'),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter search keyword';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    searchTerm = value;
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  // 중복된 Submit 방지
                  onPressed: appState == AppState.loading ? null : submit,
                  child: Text(
                    appState == AppState.loading ? 'Loading' : 'Get Result',
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
