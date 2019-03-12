import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class BaiduLocation{
  final double latitude;
  final double longitude;
  final String country;
  final String countryCode;
  final String province;
  final String cityCode;
  final String city;
  final String district;
  final String street;
  final String locationDescribe;
  final int errorCode;
  final bool isInChina;


  BaiduLocation({this.latitude, this.longitude,
      this.country, this.countryCode, this.province,
      this.cityCode, this.city, this.district, this.street,
      this.locationDescribe,this.errorCode,this.isInChina});

  factory BaiduLocation.fromMap(dynamic value){
    return new BaiduLocation(
      latitude: value['latitude'],
      longitude:value['longitude'],

      country:value['country'],
      countryCode:value['countryCode'],
      province: value['province'],
      cityCode: value['cityCode'],
      city: value['city'],
      district : value['district'],
      street:value['street'],
      locationDescribe:value['locationDescribe'],
      errorCode:value['errorCode'],
      isInChina:value['isInChina']
    );
  }

  bool isSuccess() {
    return errorCode == 161;
  }
}

class FlutterBaiduMap {
  static const MethodChannel _channel =
      const MethodChannel('flutter_baidu_map');

  static Future<bool>  setAK(String ak) async {
    final bool result = await _channel.invokeMethod('setAK',ak);
    return result;
  }
  static Future<BaiduLocation>  getCurrentLocation() async {
    final Map result = await _channel.invokeMethod('getCurrentLocation');
    print(result);
    return new BaiduLocation.fromMap(result);
  }
}
