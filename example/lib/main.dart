import 'package:flutter/material.dart';
import 'package:transformable_frame/transformable_frame.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.black12,
          child: Center(
            child: Stack(
              children: <Widget>[
                TransformableFrame(
                  onCloseTap: (_) {
                    print('object');
                  },
                  child: Text(
                    'Hello Hello Hello Hello Hello Hello Hello Hello',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Center(
                  child: TransformableFrame(
                    onCloseTap: (_) {
                      print('object');
                    },
                    child: Image.asset('assets/5.png'),
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
