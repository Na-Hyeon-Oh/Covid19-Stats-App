import 'package:flutter/material.dart';

class LoginNext extends StatelessWidget {
  String userId;
  String previousPage;

  final Map<String, String> arguments;

  LoginNext(this.arguments){
    this.userId=arguments["user-msg1"];
    this.previousPage=arguments["user-msg2"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("2019311923 OhNaHyeon"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'CORONA LIVE',
                style: TextStyle(color: Colors.blueGrey, fontSize: 33),
              ),
              Text(
                'Login Success. Hello $userId\n\n\n',
                style: TextStyle(color: Colors.blue, fontSize: 17),
              ),
              Image.asset('assets/images/corona.jpg'),
              Text(
                '\n\n',
              ),
              ElevatedButton(
                child: Text("Start CORONA LIVE"),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/loginNext/navi',
                    arguments: {
                      "user-msg1": '$userId',
                      "user-msg2": '$previousPage',
                    }
                  );
                },
              ),
            ],
        ),
      ),
    );
  }
}