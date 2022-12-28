import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class Info {
  final String country;
  final String iso_code;
  final String date;
  final int total_vaccinations;
  final int people_fully_vaccinated;
  final int daily_vaccinations;

  Info(
      {@required this.country,
      @required this.iso_code,
      @required this.date,
      @required this.total_vaccinations,
      @required this.people_fully_vaccinated,
      @required this.daily_vaccinations});

  factory Info.fromJson(Map<String, dynamic> json) {
    int lastIdx = json['data'].length - 1;
    int totalVacc = 0;
    int fullyVacc = 0;
    int dailyVacc = 0;
    int _tmpIdx;

    if (lastIdx >= 0) {
      while (json['data'][lastIdx] == null && lastIdx > 0) {
        lastIdx--;
      }

      if (json['data'][lastIdx]['total_vaccinations'] == null) {
        if (json['data'][lastIdx]['people_vaccinated'] == null) {
          if (json['data'][lastIdx]['people_fully_vaccinated'] == null) {
            totalVacc = 0;
          } else
            totalVacc = json['data'][lastIdx]['people_fully_vaccinated'];
        } else
          totalVacc = json['data'][lastIdx]['people_vaccinated'];
      } else
        totalVacc = json['data'][lastIdx]['total_vaccinations'];

      if (json['data'][lastIdx]['people_fully_vaccinated'] == null) {
        if (lastIdx > 0) {
          _tmpIdx = lastIdx - 1;
          if (json['data'][_tmpIdx]['people_fully_vaccinated'] == null) {
            fullyVacc = 0;
          } else
            fullyVacc = json['data'][_tmpIdx]['people_fully_vaccinated'];
        }
        else fullyVacc = 0;
      } else
        fullyVacc = json['data'][lastIdx]['people_fully_vaccinated'];

      if (json['data'][lastIdx]['daily_vaccinations'] == null) {
        if (lastIdx > 0) {
          _tmpIdx = lastIdx - 1;
          if (json['data'][_tmpIdx]['daily_vaccinations'] == null) {
            dailyVacc = 0;
          } else
            dailyVacc = json['data'][_tmpIdx]['daily_vaccinations'];
        }
        else dailyVacc = 0;
      } else
        dailyVacc = json['data'][lastIdx]['daily_vaccinations'];
    }

    /*print('${json['country']}  ${json['iso_code']}');
    print('${json['data'][lastIdx]['date']}');
    print('$totalVacc  $fullyVacc  $dailyVacc');*/

    return Info(
      country: json['country'],
      iso_code: json['iso_code'],
      date: json['data'][lastIdx]['date'],
      total_vaccinations: totalVacc,
      people_fully_vaccinated: fullyVacc,
      daily_vaccinations: dailyVacc,
    );
  }
}

Future<List<Info>> fetchInfo(http.Client client) async {
  final response = await client.get(
      'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json');

  if (response.statusCode == 200) {
    //print('res : ${response.body}');
    return compute(parseInfo, response.body);
  } else {
    throw Exception('Failed to load Info from url');
  }
}

List<Info> parseInfo(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  //print('parsed : $parsed');
  //map iterator
  return parsed.map<Info>((json) => Info.fromJson(json)).toList();
}

class Provider2 extends ChangeNotifier{
  List<String> _table;
  get table => _table;

  Provider2(this._table);

  void tableChange(List<String> src){
    _table = List.from(src);
    notifyListeners();
  }
}

class Content2 extends StatelessWidget {
  String userId;

  final Map<String, String> arguments;

  Content2(this.arguments) {
    this.userId = arguments["user-msg1"];
  }

  @override
  Widget build(BuildContext context) {
    List<Info> data = [];
    List<Info> data2 = [];
    List<String> code = [];

    Provider2 tableData=Provider.of<Provider2>(context);
    List<String> tableData1 = new List<String>();
    List<String> tableData2 = new List<String>();

    void setDataforTable() {
      data2 = List.from(data);
      String tmp =
          "Country             total             fully             daily";
      tableData1.add(tmp);
      tableData2.add(tmp);

      //ascending order according to country
      for (int i = 0; i < 7; i++) {
        tmp = "";

        if (data[i].country != null)
          tmp += data[i].country + "        ";
        else
          tmp += "null         ";
        if (data[i].total_vaccinations != 0)
          tmp += data[i].total_vaccinations.toString() + "        ";
        else
          tmp += "null         ";
        if (data[i].people_fully_vaccinated != 0)
          tmp += data[i].people_fully_vaccinated.toString() + "         ";
        else
          tmp += "null         ";
        if (data[i].daily_vaccinations != 0)
          tmp += data[i].daily_vaccinations.toString();
        else
          tmp += "null";

        tableData1.add(tmp);
      }

      //descending order according to total vaccination
      data2..sort((a,b)=>b.total_vaccinations.compareTo(a.total_vaccinations));
      for (int i = 0; i < 7; i++) {
        tmp = "";

        if (data2[i].country != null)
          tmp += data2[i].country + "      ";
        else
          tmp += "null         ";
        if (data2[i].total_vaccinations != 0)
          tmp += data2[i].total_vaccinations.toString() + "      ";
        else
          tmp += "null         ";
        if (data2[i].people_fully_vaccinated != 0)
          tmp += data2[i].people_fully_vaccinated.toString() + "       ";
        else
          tmp += "null         ";
        if (data2[i].daily_vaccinations != 0)
          tmp += data2[i].daily_vaccinations.toString();
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
            FutureBuilder<List<Info>>(
              future: fetchInfo(http.Client()),
              builder: (context, snapshot) {
                data = [];
                if (snapshot.hasData) {
                  data = snapshot.data;

                  String latestDate_korea;
                  int total_vacc = 0;
                  int total_fully_vacc = 0;
                  int total_daily_vacc = 0;
                  String firstInfo;

                  //get parsed info data
                  for (int i = 0; i < snapshot.data.length; i++) {
                    if (snapshot.data[i].country.toString() ==
                        'South Korea') {
                      latestDate_korea = snapshot.data[i].date.toString();
                    }
                    total_vacc += snapshot.data[i].total_vaccinations;
                    total_fully_vacc +=
                        snapshot.data[i].people_fully_vaccinated;
                    total_daily_vacc +=
                        snapshot.data[i].daily_vaccinations;
                    code.add(snapshot.data[i].iso_code.toString());
                  }

                  setDataforTable();

                  firstInfo = sprintf(
                      '%-36s %36s\n%-35s %30s\n\n%-36s %40s\n%-35s %25s',
                      [
                        'Total Vacc.',
                        'Parsed latest date',
                        '$total_vacc people',
                        latestDate_korea,
                        'Total fully Vacc.',
                        'Daily Vacc.',
                        '$total_fully_vacc people',
                        '$total_daily_vacc people'
                      ]);

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
                                    child: Text("Country_name")),

                                TextButton(
                                    onPressed: () {
                                      tableData.tableChange(tableData2);
                                    },
                                    child: Text("Total_vacc")),
                              ],
                            ),
                            Container(height: 2, width: 370, color: Colors.blueGrey),
                            Container(
                              height: 200,
                              child: Consumer<Provider2>(
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
              "user-msg2": 'Vaccine Page',
            },
          );
        },
        tooltip: 'Back',
        child: Icon(Icons.list),
      ),
    );
  }
}
/*
List<DataRow> getRows(int flag) {
      if (data != null) {
        List<DataRow> row = [];

        for (int j = 0; j < data.length; j++) {
          List<DataCell> cells = [];

          //sorted by country
          if(flag==0) {
            if (data[j].country != "")
              cells.add(DataCell(Container(width: 45,
                  child: Text(
                      data[j].country, style: TextStyle(fontSize: 11)))));
            else
              cells.add(DataCell(Container(width: 45,
                  child: Text('null', style: TextStyle(fontSize: 11)))));
            if (data[j].total_vaccinations != 0)
              cells.add(DataCell(Container(width: 33,
                  child: Text(data[j].total_vaccinations.toString(),
                      style: TextStyle(fontSize: 11)))));
            else
              cells.add(DataCell(Container(width: 33,
                  child: Text('null', style: TextStyle(fontSize: 11)))));
            if (data[j].people_fully_vaccinated != 0)
              cells.add(DataCell(Container(width: 33,
                  child: Text(data[j].people_fully_vaccinated.toString(),
                      style: TextStyle(fontSize: 11)))));
            else
              cells.add(DataCell(Container(width: 33,
                  child: Text('null', style: TextStyle(fontSize: 11)))));
            if (data[j].daily_vaccinations != 0)
              cells.add(DataCell(Container(width: 33,
                  child: Text(data[j].daily_vaccinations.toString(),
                      style: TextStyle(fontSize: 11)))));
            else
              cells.add(DataCell(Container(width: 33,
                  child: Text('null', style: TextStyle(fontSize: 11)))));
          }
          //sorted by total vacc
          else if(flag==1){
            if (data2[j].country != "")
              cells.add(DataCell(Container(width: 45,
                  child: Text(
                      data2[j].country, style: TextStyle(fontSize: 11)))));
            else
              cells.add(DataCell(Container(width: 45,
                  child: Text('null', style: TextStyle(fontSize: 11)))));
            if (data2[j].total_vaccinations != 0)
              cells.add(DataCell(Container(width: 33,
                  child: Text(data2[j].total_vaccinations.toString(),
                      style: TextStyle(fontSize: 11)))));
            else
              cells.add(DataCell(Container(width: 33,
                  child: Text('null', style: TextStyle(fontSize: 11)))));
            if (data2[j].people_fully_vaccinated != 0)
              cells.add(DataCell(Container(width: 33,
                  child: Text(data2[j].people_fully_vaccinated.toString(),
                      style: TextStyle(fontSize: 11)))));
            else
              cells.add(DataCell(Container(width: 33,
                  child: Text('null', style: TextStyle(fontSize: 11)))));
            if (data2[j].daily_vaccinations != 0)
              cells.add(DataCell(Container(width: 33,
                  child: Text(data2[j].daily_vaccinations.toString(),
                      style: TextStyle(fontSize: 11)))));
            else
              cells.add(DataCell(Container(width: 33,
                  child: Text('null', style: TextStyle(fontSize: 11)))));
          }

          row.add(DataRow(cells: cells));
        }
        return row;
      }
      return null;
    }

DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.blueGrey[200]),
                              headingRowHeight: 30,
                              columns: [
                                DataColumn(label: Text('Country', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),)),
                                DataColumn(label: Text('total', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),)),
                                DataColumn(label: Text('fully', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),)),
                                DataColumn(label: Text('daily', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),)),
                              ],
                              rows: getRows(_currentTable),
                            ),


                            void changeTable(int num) {
      switch (num) {
        case 0:
          tableData = tableData1;
          break;
        case 1:
          tableData = tableData2;
          break;
        default:
        //error
          throw Exception('Invalid Graph num');
      }
    }

    void changeGraph(int num) {
      switch (num) {
        case 1:
          break;
        case 2:
          break;
        case 3:
          break;
        case 4:
          break;
        default:
        //error
          throw Exception('Invalid Graph num');
      }
    }
 */
