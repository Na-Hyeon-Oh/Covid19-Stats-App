import 'package:flutter/material.dart';
import 'package:pa3/loginNext.dart';
import 'package:pa3/navigation.dart';
import 'package:pa3/case_death.dart';
import 'package:pa3/vaccine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

void main() => runApp(CoronaLive());

class CoronaLive extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Provider1(new List<String>())),
          ChangeNotifierProvider(create: (context) => Provider2(new List<String>())),
        ],
        child: MaterialApp(
            title: 'Flutter PA3',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: '/',
            onGenerateRoute: (routerSettings) {
              switch (routerSettings.name) {
                case '/':
                  return MaterialPageRoute(
                      builder: (_) => Login(title: "2019311923 OhNaHyeon"));
                case '/loginNext':
                  return MaterialPageRoute(
                      builder: (_) => LoginNext(routerSettings.arguments));
                case '/loginNext/navi':
                  return MaterialPageRoute(
                      builder: (_) => Navigation(routerSettings.arguments));
                case '/loginNext/navi/case_death':
                  return MaterialPageRoute(
                      builder: (_) => Content1(routerSettings.arguments));
                case '/loginNext/navi/vaccine':
                  return MaterialPageRoute(
                      builder: (_) => Content2(routerSettings.arguments));
                default:
                  return MaterialPageRoute(
                      builder: (_) => Login(title: "ErrorUnknown Route!"));
              }
            }),
    );
  }
}

class Login extends StatelessWidget {
  Login({Key key, this.title}) : super(key: key);

  final String title;

  final IDcontroller = TextEditingController();
  final PWcontroller = TextEditingController();

  String _id = "skkuMoapp";
  String _pw = "1234";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'CORONA LIVE',
              style: TextStyle(color: Colors.blueGrey, fontSize: 33),
              //Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Login Please...\n\n\n',
              style: Theme.of(context).textTheme.subtitle1,
            ),

            //box
            Container(
              width: 270.0,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 3,
                  color: Colors.blueGrey,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'ID:   ',
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        width: 200.0,
                        child: TextField(
                          controller: IDcontroller,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'PW: ',
                        style: TextStyle(fontSize: 20),
                      ),
                      Container(
                        width: 200.0,
                        child: TextField(
                          controller: PWcontroller,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: Text("Login"),
                    onPressed: () {
                      if (IDcontroller.text == _id && PWcontroller.text == _pw) {
                        Navigator.pushNamed(
                            context,
                            '/loginNext',
                            arguments: {
                            "user-msg1": '$_id',
                            "user-msg2": 'Login Page',
                            },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
