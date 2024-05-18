import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:untitled5/app_model.dart';

// https://pub.dev/packages/get_it/example

class Engine {
  void startEngine() {
    print("Start enging!");
  }
}
class BadCar {
  late Engine _engine;
  MainBloc() {
    _engine= Engine();
    _engine.startEngine();
  }
}
class GoodCar {
  late Engine _engine;
  GoodCar(Engine e) {
    _engine = e;
    _engine.startEngine();
  }
}

// This is our global ServiceLocator
GetIt getIt = GetIt.instance;


void main() {
  runApp(const MyApp());

  getIt.registerSingleton<AppModel>(AppModelImplementation(),signalsReady: true);


  BadCar badCar = BadCar();

  // DI via constructor
  Engine gas_engine = Engine();
  Engine e_engine = Engine();
  GoodCar goodCar = GoodCar(gas_engine);
  GoodCar goodCar2 = GoodCar(e_engine);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Home page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // Access the instance of the registered AppModel
    // As we don't know for sure if AppModel is already ready we use isReady
    getIt
        .isReady<AppModel>()
        .then((_) => getIt<AppModel>().addListener(update));

    super.initState();
  }

  void update() => setState(() => {});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
          future: getIt.allReady(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'You have pushed the button this many times:',
                      ),
                      Text(
                        getIt<AppModel>().counter.toString(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: getIt<AppModel>().incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              );
            } else {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Waiting for initialisation'),
                  SizedBox(
                    height: 16,
                  ),
                  CircularProgressIndicator(),
                ],
              );
            }
          }),
    );
  }
}