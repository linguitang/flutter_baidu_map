package com.mld.flutter_baidu_map;

import android.app.Activity;
import android.util.Log;

import com.baidu.location.BDAbstractLocationListener;
import com.baidu.location.BDLocation;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterBaiduMapPlugin */
public class FlutterBaiduMapPlugin implements MethodCallHandler {
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_baidu_map");
    channel.setMethodCallHandler(new FlutterBaiduMapPlugin(registrar.activity(),channel));
  }
  private Activity activity;
  private MethodChannel channel;

  private LocationClient mLocationClient = null;
  private BDAbstractLocationListener mListener;

  public FlutterBaiduMapPlugin(Activity activity,MethodChannel channel) {
    this.activity = activity;
    this.channel = channel;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("setAK")){
      result.success(true);
    }else if (call.method.equals("getCurrentLocation")){
      initClient(new CurrentLocationListener(result));
    }else {
      result.notImplemented();
    }
  }

  private synchronized void initClient(BDAbstractLocationListener listener){
    if (mLocationClient == null) {
      mLocationClient = new LocationClient(activity.getApplicationContext());
      //声明LocationClient类
      mLocationClient.registerLocationListener(listener);
      //注册监听函数
    }
    this.mListener = listener;
    LocationClientOption opation = defaultLocationClientOption();
    mLocationClient.setLocOption(opation);
    mLocationClient.start();
  }

  private synchronized void destroyClient(){
    if(mLocationClient != null){
      mLocationClient.unRegisterLocationListener(mListener);
      mLocationClient.stop();
      mLocationClient = null;
    }
  }

  private static LocationClientOption  defaultLocationClientOption(){
    LocationClientOption option = new LocationClientOption();

    option.setLocationMode(LocationClientOption.LocationMode.Hight_Accuracy);
    //可选，设置定位模式，默认高精度
    //LocationMode.Hight_Accuracy：高精度；
    //LocationMode. Battery_Saving：低功耗；
    //LocationMode. Device_Sensors：仅使用设备；
      
    option.setCoorType("bd09ll");
    //可选，设置返回经纬度坐标类型，默认GCJ02
    //GCJ02：国测局坐标；
    //BD09ll：百度经纬度坐标；
    //BD09：百度墨卡托坐标；
    //海外地区定位，无需设置坐标类型，统一返回WGS84类型坐标
      
    option.setScanSpan(1000);
    //可选，设置发起定位请求的间隔，int类型，单位ms
    //如果设置为0，则代表单次定位，即仅定位一次，默认为0
    //如果设置非0，需设置1000ms以上才有效
    
    option.setIsNeedAddress(true);
    //可选，是否需要地址信息，默认为不需要，即参数为false
    //如果开发者需要获得当前点的地址信息，此处必须为true
    
    option.setOpenGps(true);
    //可选，设置是否使用gps，默认false
    //使用高精度和仅用设备两种定位模式的，参数必须设置为true
    
    option.setNeedDeviceDirect(false);
    //可选，设置是否需要设备方向结果

    option.setLocationNotify(true);
    //可选，设置是否当GPS有效时按照1S/1次频率输出GPS结果，默认false
      
    option.setIgnoreKillProcess(true);
    //可选，定位SDK内部是一个service，并放到了独立进程。
    //设置是否在stop的时候杀死这个进程，默认（建议）不杀死，即setIgnoreKillProcess(true)
      
    option.SetIgnoreCacheException(false);
    //可选，设置是否收集Crash信息，默认收集，即参数为false

    option.setIsNeedLocationDescribe(true);
    //可选，是否需要位置描述信息，默认为不需要，即参数为false
    //如果开发者需要获得当前点的位置信息，此处必须为true

    option.setIsNeedLocationPoiList(false);
    //可选，是否需要周边POI信息，默认为不需要，即参数为false
    //如果开发者需要获得周边POI信息，此处必须为true

    option.setWifiCacheTimeOut(5*60*1000);
    //可选，V7.2版本新增能力
    //如果设置了该接口，首次启动定位时，会先判断当前Wi-Fi是否超出有效期，若超出有效期，会先重新扫描Wi-Fi，然后定位
      
    option.setEnableSimulateGps(false);
    //可选，设置是否需要过滤GPS仿真结果，默认需要，即参数为false
    
    return option;
  }

  Map<String,Object> location2map(BDLocation location){
    Map<String,Object> json = new HashMap<>();
    json.put("latitude",location.getLatitude());    //获取纬度信息
    json.put("longitude",location.getLongitude());    //获取经度信息

    json.put("country",location.getCountry());    //获取国家
    json.put("countryCode", location.getCountryCode());
    json.put("province",location.getProvince());    //获取省份
    json.put("city",location.getCity());    //获取城市
    json.put("cityCode", location.getCityCode());
    json.put("district",location.getDistrict());    //获取区县
    json.put("street",location.getStreet());    //获取街道信息

    json.put("locationDescribe",location.getLocationDescribe());    //获取位置描述信息
    json.put("adCode",location.getAdCode());    //获取城市adcode

    json.put("isInChina",location.getLocationWhere() == BDLocation.LOCATION_WHERE_IN_CN);
  
    json.put("errorCode",location.getLocType());
    //获取定位类型、定位错误返回码，具体信息可参照类参考中BDLocation类中的说明
    

    
    return json;
  }

  /**
   * 实现定位回调
   */
  class CurrentLocationListener extends BDAbstractLocationListener {
    Result result;

    CurrentLocationListener(Result result) {
      this.result = result;
    }

    @Override
    public synchronized void onReceiveLocation(BDLocation location) {
      if (location == null) {
        return;
      }
      try {
        if(result!=null){
          result.success(location2map(location));
        }
      } finally {
        destroyClient();
        result = null;
      }
    }
  }
}
