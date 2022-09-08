import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paprclip/performance.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaprClip',
      home: const MyHomePage(title: 'PaprClip'),
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

  String clicker="";
  List<String> bank_label=["Sector","Industry","Market Cap.","Enterprise Value(EV)","Book Value/Share","Price-Earning Ratio(PE)","PEG Ratio","Divident Yield","Trailing 12 months (TTM)","Enterprise Value(EV) Date End","Year End","Industry ID","Sector ID","Security"];
  List<String> bank_keys=["Sector","Industry","MCAP","EV", "BookNavPerShare","TTMPE","PEGRatio","Yield", "TTMYearEnd","EVDateEnd","YearEnd", "IndustryID", "SectorID","Security"];
  bool requested=false;
  List<String> bank_data=[];
  Map decodedMap={};

  //function to send GET request to API
  void overview_api() async{
    var request = http.Request('GET', Uri.parse('https://api.stockedge.com/Api/SecurityDashboardApi/GetCompanyEquityInfoForSecurity/5051?l'));


    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      clicker=await response.stream.bytesToString();

      setState(() {
        //converting raw values and formating them to display(rounding off the numbers)
        requested=true;
        decodedMap = json.decode(clicker) as Map;
        decodedMap["PEGRatio"]=decodedMap["PEGRatio"].toStringAsFixed(2);
        decodedMap["BookNavPerShare"]=decodedMap["BookNavPerShare"].toStringAsFixed(2);
        decodedMap["TTMPE"]=decodedMap["TTMPE"].toStringAsFixed(2);
        decodedMap["Yield"]=decodedMap["Yield"].toStringAsFixed(2);
        decodedMap["MCAP"]= (decodedMap["MCAP"]/10000000).toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')+"Cr";

      });

      List<String> bank_data_temp=[];
      decodedMap.values.forEach((value) {
        bank_data_temp.add(value.toString());
      });

      setState(() {
        bank_data= bank_data_temp;
      });


    }
    else {
      print(response.reasonPhrase);
    }

  }
  @override
  Widget build(BuildContext context) {

    if(requested==false){overview_api();}

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 0, 77,1),
        centerTitle: true,
        //
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),


              child: Text(
                "Overview",
                style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.8,
            ),
            Container(
              height: 600,
              width: 500,
              child:
                  Row(
                    children: [
                      Container(
                        height: 700,
                        width:220,
                        child: ListView.builder(

                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: bank_label.length,
                          itemBuilder: (context, index) {
                            return
                              SizedBox(
                                width: 250,
                                height: 40,
                                child: ListTile(
                                title: Text(
                                    bank_label[index],
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 32, 128,1),
                                    fontSize: 14,
                                  ),
                                ),
                            ),
                              );
                          },

                        ),
                      ),
                      Container(
                        height: 700,
                        width:120,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: bank_keys.length,
                          itemBuilder: (context, index) {
                            return
                              SizedBox(
                                width: 30,
                                height: 40,
                                child: ListTile(
                                title: Text(decodedMap[bank_keys[index]].toString().replaceAll("null", "-"),
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                                ),
                            ),
                              );
                          },

                        ),
                      ),
                    ],
                  ),


                ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),


              child: Text(
                "Performance",
                style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 0.8,
            ),
            Container(
              child: Performance(),
            ),

          ],
        ),
        ),


    );
  }
}
