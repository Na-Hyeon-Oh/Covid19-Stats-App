import 'package:flutter/material.dart';

class Navigation extends StatelessWidget {
  String userId;
  String previousPage;

  final Map<String, String> arguments;

  Navigation(this.arguments) {
    this.userId = arguments["user-msg1"];
    this.previousPage = arguments["user-msg2"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 450,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.coronavirus_outlined),
                    title: Text('Cases/Deaths'),
                    onTap: (){
                      Navigator.pushNamed(
                        context,
                        '/loginNext/navi/case_death',
                        arguments: {
                          "user-msg1": '$userId',
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.local_hospital),
                    title: Text('Vaccine'),
                    onTap: (){
                      Navigator.pushNamed(
                        context,
                        '/loginNext/navi/vaccine',
                        arguments: {
                          "user-msg1": '$userId',
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: Column(children: <Widget>[
                Text(
                  'Welcome! $userId',
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                    'Previous: $previousPage',
                    style: TextStyle(color: Colors.blue, fontSize: 17),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
