import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/percent_indicator.dart';

class Performance extends StatefulWidget {
  const Performance({Key? key}) : super(key: key);

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  String clicker="";
  dynamic decodedMap;
  List percentage_values=[];
  bool requested=false;
  List normalised_values=[];

  
  //function to send GET request to API
  void performance_api() async{
    var request = http.Request('GET', Uri.parse('https://api.stockedge.com/Api/SecurityDashboardApi/GetTechnicalPerformanceBenchmarkForSecurity/5051?lang=en'));
    percentage_values=[];

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      clicker=await response.stream.bytesToString();
      setState(() {
        requested=true;
        decodedMap = json.decode(clicker) ;

        for(int i=0;i<decodedMap.length;i++){
          percentage_values.add(decodedMap[i]["ChangePercent"].abs());
          
          
        }

      });

      //normalising percentage values to (0,1)
      List temp=percentage_values;
      temp.sort();
      double maximum=temp[temp.length-1];
      for(int j=0;j<decodedMap.length;j++){
        double normalized=(percentage_values[j]/maximum);
        normalised_values.add(normalized);
      }

    }
    else {
    print(response.reasonPhrase);
    }

  }

  @override

  Widget build(BuildContext context) {
    if (requested == false) {
      performance_api();
      return Container(
        color: Colors.white,
      );
    }
    else {
      return Container(
          height: 500,
          width: 500,
          child: Row(
            children: [

              Container(
                height: 500,
                width: 85,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: decodedMap.length,
                  itemBuilder: (context, index) {
                    return
                      SizedBox(
                        width: 30,
                        height: 50,
                        child: ListTile(
                          title: Text(
                            decodedMap[index]['Label'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(0, 32, 128, 1),
                            ),
                          ),
                        ),
                      );
                  },

                ),
              ),
              Container(
                height: 500,
                width: 160,
                child:
                ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: decodedMap.length,
                  itemBuilder: (context, index) {
                    return
                      Container(
                        height: 50,
                        width: 160,
                        child: SizedBox(
                          height: 100,
                          child: new LinearPercentIndicator(
                            width: 160.0,
                            lineHeight: 20.0,
                            barRadius: Radius.circular(5),

                            percent: normalised_values[index],
                            backgroundColor: Color.fromRGBO(224, 235, 235, 1),
                            progressColor: (decodedMap[index]['ChangePercent'] >=
                                0) ? Colors.green : Colors.red,
                          ),
                        ),

                      );
                  },

                ),


              ),
              Container(
                height: 500,
                width: 90,
                child: ListView.builder(
                  //physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: decodedMap.length,
                  itemBuilder: (context, index) {
                    return
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: ListTile(
                          title: Text(
                            decodedMap[index]['ChangePercent'].toStringAsFixed(
                                2) + '%',
                            style: TextStyle(
                              color: (decodedMap[index]['ChangePercent'] >= 0)
                                  ? Color.fromRGBO(0, 102, 0, 1)
                                  : Color.fromRGBO(102, 0, 0, 1),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                  },

                ),
              ),


            ],
          )
      );
    }
  }
}
