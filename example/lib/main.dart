import 'package:flutter/material.dart';
import 'package:flutter_baidu_map/flutter_baidu_map.dart';
//import 'package:permission_handler/permission_handler.dart';

void main() {
  FlutterBaiduMap.setAK("zXd9nxXOYlz6iUbK7o7iHM5nKdKgGDw8");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String  _locationResult = '';
  Map location;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                child: Text("点击获取当前定位"),
                onPressed: () async{
                  /*PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
                  bool hasPermission = permission == PermissionStatus.granted;
                  if(!hasPermission){
                    Map<PermissionGroup, PermissionStatus> map = await PermissionHandler().requestPermissions([
                      PermissionGroup.location
                    ]);
                    if(map.values.toList()[0] != PermissionStatus.granted){
                      setState(() {
                        _locationResult = "申请定位权限失败";
                      });
                      return;
                    }
                  }*/
                  setState(() {
                    _locationResult = "正在定位中...";
                  });
                  BaiduLocation location = await FlutterBaiduMap.getCurrentLocation();
                  setState(() {
                    if (location.isSuccess()) {
                      _locationResult = location.locationDescribe;
                    } else {
                      
                      _locationResult = "定位失败";
                    }
                  });
                },
              ),
              Text((_locationResult == null || _locationResult == '')?'':"定位结果:" + _locationResult)
            ],
          ),
        ),
      ),
    );
  }
}
