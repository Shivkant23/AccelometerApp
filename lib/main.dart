import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main(){
  runApp(SensorMain());
}

class SensorMain extends StatelessWidget {
  const SensorMain({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor',
      darkTheme: ThemeData.dark(),
      home: SensorScreen(),
    );
  }
}

class SensorScreen extends StatefulWidget {
  SensorScreen({Key key}) : super(key: key);

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {

  static String _methodChannelName = 'com.example.itzmeanjan.sensorz.androidMethodChannel'; // keep it unique
  static String _eventChannelName = 'com.example.itzmeanjan.sensorz.androidEventChannel';
  static MethodChannel _methodChannel;
  static EventChannel _eventChannel;
  List<dynamic> _listAccelerometer;
  bool _loderFlag = false;
  bool _isFirstUIBuildDone = false;

  Future<void> getSensorsList()async{
    Map<String , List<dynamic>> sensorCount;
    try{
      Map<dynamic, dynamic> tmp = await _methodChannel.invokeMethod('getSensorsList');
      setState(() {
        _loderFlag = true;
      });
      sensorCount = Map<String, List<dynamic>>.from(tmp);
      sensorCount.forEach((String key, List<dynamic> value) {
        switch (key) {
          case '1':
            if (value.length > 0) {
              _listAccelerometer = value;
              print(value);
            }
            break;
          default:
          //not supported yet
        }
      });
    }catch(e){
      _isFirstUIBuildDone = true;
      print(e);
    }
  }

   @override
  void initState() {
    // stateful widget initialization done here
    super.initState();
    _methodChannel = MethodChannel(_methodChannelName);
    _eventChannel = EventChannel(_eventChannelName);
    getSensorsList();
//     _eventChannel.receiveBroadcastStream().listen(_onData, onError: _onError);
  }


  bool isAMatch(List data, Map<String, String> receivedData) {
    // Finds whether it is an instance of target class so that we can use it to update UI.
    return (data[0]['name'] == receivedData['name'] &&
        data[0]['vendorName'] == receivedData['vendorName'] &&
        data[0]['version'] == receivedData['version']);
  }

  void _onData(dynamic event) {
    // on sensor data reception, update data holders of different supported sensor types
//    if (!_isFirstUIBuildDone) return;
    Map<String, String> receivedData = Map<String, String>.from(event);
    switch (receivedData['type']) {
      case '1':
        _listAccelerometer.forEach((item) {
          if (isAMatch(_listAccelerometer, receivedData)) {
            List<String> sensorFeed = receivedData['values'].split(';');
            setState(() {
              item.x = sensorFeed[0];
              item.y = sensorFeed[1];
              item.z = sensorFeed[2];
            });
          }
        });
        break;
    }
  }

  void _onError(dynamic error) {} // not handling errors yet :)



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sensor Data',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.cyanAccent,
      ),
      body: _listAccelerometer!=null  ? ListView(
          padding: EdgeInsets.all(6.0),
          // children: buildUI()
          children: <Widget>[
            Card(
                margin: EdgeInsets.only(
                    top: 6.0, bottom: 6.0, left: 4.0, right: 4.0),
                elevation: 8.0,
                child: Container(
                  padding: EdgeInsets.all(10),
                    child: Column(
                        children: ([
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Name',
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  '${_listAccelerometer[0]['name']}',
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontStyle: FontStyle.normal),
                                ),
                              ]
                          ),
                          Divider(
                            height: 14.0,
                            color: Colors.black54,
                          ),
                          _row('Type', '${_listAccelerometer[0]['type']}'),
                          _row('Version', '${_listAccelerometer[0]['version']}'),
                          _row('Power', '${_listAccelerometer[0]['power']} mA'),
                          _row('Resolution', '${_listAccelerometer[0]['resolution']} unit'),
                          _row('Maximum Range', '${_listAccelerometer[0]['maxRange']} unit'),
                          _row('Maximum Delay', '${_listAccelerometer[0]['maxDelay']} s'),
                          _row('Reporting Mode',
                              <String, String>{
                                '0': 'Continuous',
                                '1': 'On Change',
                                '2': 'One Shot',
                                '3': 'Special Trigger',
                                'NA': 'NA',
                              }['${_listAccelerometer[0]['reportingMode']}']
                          ),

                          _row('Wake Up', '${_listAccelerometer[0]['isWakeup']}'),
                          _row('Dynamic', '${_listAccelerometer[0]['isDynamic']}'),
                          _row('Highest Direct Report Rate Value',
                              <String, String>{
                                '0': 'Unsupported',
                                '1': 'Normal',
                                '2': 'Fast',
                                '3': 'Very Fast',
                                'NA': 'NA',
                              }['${_listAccelerometer[0]['highestDirectReportRateValue']}']
                          ),

                          _row('Fifo Max Event Count', '${_listAccelerometer[0]['fifoMaxEventCount']}'),
                          _row('Fifo Reserved Event Count', '${_listAccelerometer[0]['fifoReservedEventCount']}'),
                          _row('Fifo Reserved Event Count', '${_listAccelerometer[0]['fifoReservedEventCount']}'),
                          _row('Fifo Reserved Event Count', '${_listAccelerometer[0]['fifoReservedEventCount']}'),
                          _row('Fifo Reserved Event Count', '${_listAccelerometer[0]['fifoReservedEventCount']}'),
                          _row('Along X-axis', '-- m/s^2'),
                          _row('Along Y-axis', '-- m/s^2'),
                          _row('Along Z-axis', '-- m/s^2'),
                        ]
                        )
                    )
                )
            )
          ],
        ): new Center(child: CircularProgressIndicator(),),
    );
  }

  Row _row(String labelText, String valueText) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(labelText),
      Text(valueText),
    ],
  );
}