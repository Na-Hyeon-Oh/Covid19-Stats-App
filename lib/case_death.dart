import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class Code {
  final String iso_code;

  Code({@required this.iso_code});

  factory Code.fromJson(Map<String, dynamic> json) {
    return Code(
      iso_code: json['iso_code'],
    );
  }
}

Future<List<Code>> fetchCode(http.Client client) async {
  final response = await client.get(
      'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json');

  if (response.statusCode == 200) {
    //print('res : ${response.body}');
    return compute(parseCode, response.body);
  } else {
    throw Exception('Failed to load code from url');
  }
}

List<Code> parseCode(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Code>((json) => Code.fromJson(json)).toList();
}

class Info2 {
  final String location;
  final String date;
  final double total_cases;
  final double total_deaths;
  final double new_cases;

  Info2(
      {@required this.location,
      @required this.date,
      @required this.total_cases,
      @required this.total_deaths,
      @required this.new_cases});

  factory Info2.fromJson(dynamic json) {
    int lastIdx = json['data'].length - 1;
    double totalCases = 0;
    double totalDeath = 0;
    double dailyCases = 0;
    int _tmpIdx;

    if (lastIdx >= 0) {
      while (json['data'][lastIdx] == null && lastIdx > 0) {
        lastIdx--;
      }

      if (json['data'][lastIdx]['total_cases'] == null) {
        if (lastIdx > 0) {
          _tmpIdx = lastIdx - 1;
          if (json['data'][_tmpIdx]['total_cases'] == null) {
            totalCases = 0;
          } else
            totalCases = json['data'][_tmpIdx]['total_cases'];
        }
        else totalCases = 0;
      } else
        totalCases = json['data'][lastIdx]['total_cases'];

      if (json['data'][lastIdx]['total_deaths'] == null) {
        if (lastIdx > 0) {
          _tmpIdx = lastIdx - 1;
          if (json['data'][_tmpIdx]['total_deaths'] == null) {
            totalDeath = 0;
          } else
            totalDeath = json['data'][_tmpIdx]['total_deaths'];
        }
        else totalDeath = 0;
      } else
        totalDeath = json['data'][lastIdx]['total_deaths'];

      if (json['data'][lastIdx]['new_cases'] == null) {
        if (lastIdx > 0) {
          _tmpIdx = lastIdx - 1;
          if (json['data'][_tmpIdx]['new_cases'] == null) {
            dailyCases = 0;
          } else
            dailyCases = json['data'][_tmpIdx]['new_cases'];
        }
        else dailyCases = 0;
      } else
        dailyCases = json['data'][lastIdx]['new_cases'];
    }

    /*print('${json['location']}');
    print('${json['data'][lastIdx]['date']}');
    print('$totalCases  $totalDeath  $dailyCases');*/

    return Info2(
      location: json['location'],
      date: json['data'][lastIdx]['date'],
      total_cases: totalCases,
      total_deaths: totalDeath,
      new_cases: dailyCases,
    );
  }
}

Future<List<Info2>> fetchInfo2(http.Client client) async {
  final response = await client
      .get('https://covid.ourworldindata.org/data/owid-covid-data.json');

  if (response.statusCode == 200) {
    //print('res : ${response.body}');
    return compute(parseInfo2, response.body);
  } else {
    throw Exception('Failed to load Info from url');
  }
}

Future<List<Info2>> parseInfo2(String responseBody) async {
  List<Info2> ret = new List<Info2>();
  List<Code> isoCode = await fetchCode(http.Client());
  int size = isoCode.length;
  String code;

  final parsed = json.decode(responseBody).cast<String, dynamic>();
  for (int i = 0; i < size; i++) {
    code = isoCode.elementAt(i).iso_code;
    //print('$code\nparsed : ${parsed[isoCode.elementAt(i).iso_code]}');
    if (parsed[code] != null) ret.add(Info2.fromJson(parsed[code]));
  }
  return ret;
}

class Provider1 extends ChangeNotifier{
  List<String> _table;
  get table => _table;

  Provider1(this._table);

  void tableChange(List<String> src){
    _table = List.from(src);
    notifyListeners();
  }
}

class Content1 extends StatelessWidget {
  String userId;

  final Map<String, String> arguments;

  Content1(this.arguments) {
    this.userId = arguments["user-msg1"];
  }

  @override
  Widget build(BuildContext context) {
    List<Info2> data = [];
    List<Info2> data1, data2;

    Provider1 tableData=Provider.of<Provider1>(context);
    List<String> tableData1, tableData2;

    void setDataforTable() {
      data1  = List.from(data);
      data2 = List.from(data);
      tableData1 = new List<String>(); // initialize
      tableData2 = new List<String>();
      String tmp = "Country   total cases   daily cases   total deaths";
      tableData1.add(tmp);
      tableData2.add(tmp);

      //descending order according to total cases
      data1..sort((a,b)=>b.total_cases.compareTo(a.total_cases));
      for (int i = 0; i < 7; i++) {
        tmp = "";

        if (data1[i].location != null)
          tmp += data1[i].location.toString() + "    ";
        else
          tmp += "null            ";
        if (data1[i].total_cases != 0)
          tmp += data1[i].total_cases.toString() + "    ";
        else
          tmp += "null            ";
        if (data1[i].new_cases != 0)
          tmp += data1[i].new_cases.toString() + "    ";
        else
          tmp += "null            ";
        if (data1[i].total_deaths != 0)
          tmp += data1[i].total_deaths.toString();
        else
          tmp += "null";

        tableData1.add(tmp);
      }

      //descending order according to total death
      data2..sort((a,b)=>b.total_deaths.compareTo(a.total_deaths));
      for (int i = 0; i < 7; i++) {
        tmp = "";

        if (data2[i].location != null)
          tmp += data2[i].location.toString() + "    ";
        else
          tmp += "null               ";
        if (data2[i].total_cases != 0)
          tmp += data2[i].total_cases.toString() + "    ";
        else
          tmp += "null               ";
        if (data2[i].new_cases != 0)
          tmp += data2[i].new_cases.toString() + "    ";
        else
          tmp += "null               ";
        if (data2[i].total_deaths != 0)
          tmp += data2[i].total_deaths.toString();
        else
          tmp += "null";

        tableData2.add(tmp);
      }
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List<Info2>>(
              future: fetchInfo2(http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  data = snapshot.data;

                  String firstInfo;
                  String latestDate_korea;
                  double total_case = 0;
                  double total_death = 0;
                  double daily_case = 0;

                  //get parsed info data
                  for (int m = 0; m < snapshot.data.length; m++) {
                    if (snapshot.data[m].location.toString() ==
                        'South Korea') {
                      latestDate_korea = snapshot.data[m].date.toString();
                    }
                    total_case += snapshot.data[m].total_cases;
                    total_death += snapshot.data[m].total_deaths;
                    daily_case += snapshot.data[m].new_cases;
                  }

                  setDataforTable();

                  firstInfo = sprintf(
                      '%-35s%35s\n%-35s%37s\n\n%-40s%35s\n%-35s%38s', [
                    'Total Cases.',
                    'Parsed latest date',
                    '$total_case',
                    latestDate_korea,
                    'Total Deaths',
                    'Daily Cases.',
                    '$total_death',
                    '$daily_case'
                  ]
                  );
                  return Column(
                    children: <Widget>[
                      Container(
                        width: 370.0,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 2,
                            color: Colors.blueGrey,
                          ),
                        ),
                        child: Text(firstInfo),
                      ),
                      Text('\n'),
                      Container(
                        width: 370.0,
                        //padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 2,
                            color: Colors.blueGrey,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                TextButton(onPressed: () {}, child: Text("Graph 1")),
                                TextButton(onPressed: () {}, child: Text("Graph 2")),
                                TextButton(onPressed: () {}, child: Text("Graph 3")),
                                TextButton(onPressed: () {}, child: Text("Graph 4")),
                              ],
                            ),
                            Container(height: 2, width: 370, color: Colors.blueGrey),
                            Container(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  // read about it in the LineChartData section
                                ),
                              ),
                            ), //graph
                          ],
                        ),
                      ),
                      Text('\n'),
                      Container(
                        width: 370.0,
                        //padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 2,
                            color: Colors.blueGrey,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      tableData.tableChange(tableData1);
                                    },
                                    child: Text("Total Cases")),
                                TextButton(
                                    onPressed: () {
                                      tableData.tableChange(tableData2);
                                    },
                                    child: Text("Total Deaths")),
                              ],
                            ),
                            Container(height: 2, width: 370, color: Colors.blueGrey),
                            Container(
                              height: 200,
                              child: Consumer<Provider1>(
                                builder: (context, table, child) => ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: table.table.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text('${table.table[index]}'),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tableData.tableChange(new List<String>());
          Navigator.pushNamed(
            context,
            '/loginNext/navi',
            arguments: {
              "user-msg1": '$userId',
              "user-msg2": 'Cases/Death Page',
            },
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.list),
      ),
    );
  }
}

/*
 List<DataRow> getRows(int flag) {
      if (data != null) {
        List<DataRow> row = [];
        for (int m = 0; m < data.length; m++) {
          List<DataCell> cells = [];

          if(data[m].location!="") cells.add(DataCell(Container(width:40, child: Text(data[m].location, style: TextStyle(fontSize: 11)))));
          else cells.add(DataCell(Container(width: 45, child: Text('null', style: TextStyle(fontSize: 11)))));
          if(data[m].total_cases!=0)cells.add(DataCell(Container(width:33, child: Text(data[m].total_cases.toString(), style: TextStyle(fontSize: 11)))));
          else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));
          if(data[m].new_cases!=0) cells.add(DataCell(Container(width:33, child: Text(data[m].new_cases.toString(), style: TextStyle(fontSize: 11)))));
          else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));
          if(data[m].total_deaths!=0) cells.add(DataCell(Container(width:33, child: Text(data[m].total_deaths.toString(), style: TextStyle(fontSize: 11)))));
          else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));

          //data1
          if(flag==0){
            if(data1[m].location!="") cells.add(DataCell(Container(width:40, child: Text(data1[m].location, style: TextStyle(fontSize: 11)))));
            else cells.add(DataCell(Container(width: 45, child: Text('null', style: TextStyle(fontSize: 11)))));
            if(data1[m].total_cases!=0)cells.add(DataCell(Container(width:33, child: Text(data1[m].total_cases.toString(), style: TextStyle(fontSize: 11)))));
            else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));
            if(data1[m].new_cases!=0) cells.add(DataCell(Container(width:33, child: Text(data1[m].new_cases.toString(), style: TextStyle(fontSize: 11)))));
            else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));
            if(data1[m].total_deaths!=0) cells.add(DataCell(Container(width:33, child: Text(data1[m].total_deaths.toString(), style: TextStyle(fontSize: 11)))));
            else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));
          }
          //data2
          else if(flag==1){
            if(data2[m].location!="") cells.add(DataCell(Container(width:40, child: Text(data2[m].location, style: TextStyle(fontSize: 11)))));
            else cells.add(DataCell(Container(width: 45, child: Text('null', style: TextStyle(fontSize: 11)))));
            if(data2[m].total_cases!=0)cells.add(DataCell(Container(width:33, child: Text(data2[m].total_cases.toString(), style: TextStyle(fontSize: 11)))));
            else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));
            if(data2[m].new_cases!=0) cells.add(DataCell(Container(width:33, child: Text(data2[m].new_cases.toString(), style: TextStyle(fontSize: 11)))));
            else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));
            if(data2[m].total_deaths!=0) cells.add(DataCell(Container(width:33, child: Text(data2[m].total_deaths.toString(), style: TextStyle(fontSize: 11)))));
            else cells.add(DataCell(Container(width: 33, child: Text('null', style: TextStyle(fontSize: 11)))));
          }

          row.add(DataRow(cells: cells));
        }
        return row;
      }
      return null;
    }


FutureBuilder(
                    future: fetchInfo2(http.Client()),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        return Container(
                          height: 200,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            physics : ClampingScrollPhysics(),
                            child:
                          ),
                        );
                      }
                      else if(snapshot.hasError){
                        return Text("${snapshot.error}");
                      }
                      return CircularProgressIndicator();
                      //return Center();
                    },
                  ),//table*/
