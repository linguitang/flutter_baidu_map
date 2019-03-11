import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class BaiduLocation{
  final double latitude;
  final double longitude;
  final double radius;
  final String address;
  final String country;
  final String countryCode;
  final String province;
  final String cityCode;
  final String city;
  final String district;
  final String street;
  final String streetNumber;
  final String time;
  final double direction;
  final String locationDescribe;
  final String coorType;
  final int errorCode;


  BaiduLocation({this.latitude, this.longitude, this.radius,
      this.address, this.country, this.countryCode, this.province,
      this.cityCode, this.city, this.district, this.street, this.streetNumber,
      this.time, this.direction, this.locationDescribe,this.coorType,this.errorCode});

  factory BaiduLocation.fromMap(dynamic value){
    return new BaiduLocation(
      latitude: value['latitude'],
      longitude:value['longitude'],
      address:value['addr'],

      country:value['country'],
      countryCode:value['countryCode'],
      province: value['province'],
      cityCode: value['cityCode'],
      city: value['city'],
      district : value['district'],
      street:value['street'],
      streetNumber:value['streetNumber'],
      time:value['time'],
      direction:value['direction'],
      locationDescribe:value['locationDescribe'],
      coorType:value['coorType'],
      errorCode:value['errorCode'],
    );
  }

  bool isSuccess() {
    if(Platform.isIOS){
      return errorCode==null;
    }else{
      return errorCode == 161;
    }
  }
}

class FlutterBaiduMap {
  static const MethodChannel _channel =
      const MethodChannel('flutter_baidu_map');

  static Future<BaiduLocation>  getCurrentLocation() async {
    final Map result = await _channel.invokeMethod('getCurrentLocation');
    return new BaiduLocation.fromMap(result);
  }
}
