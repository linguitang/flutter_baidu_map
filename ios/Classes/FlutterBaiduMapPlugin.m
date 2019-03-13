#import "FlutterBaiduMapPlugin.h"
#import <BMKLocationkit/BMKLocationComponent.h>
@interface FlutterBaiduMapPlugin()<BMKLocationManagerDelegate>
@property BMKLocationManager *locationManager;
@property(nonatomic, copy) BMKLocatingCompletionBlock completionBlock;
@end

@implementation FlutterBaiduMapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_baidu_map"
            binaryMessenger:[registrar messenger]];
  FlutterBaiduMapPlugin* instance = [[FlutterBaiduMapPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"setAK" isEqualToString:call.method]) {
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:call.arguments authDelegate:self];
    result(@YES);
  } else if ([@"getCurrentLocation" isEqualToString:call.method]) {
    [self initLocation];
    [self getCurrentLocation:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)initLocation
{
    _locationManager = [[BMKLocationManager alloc] init];
    
    _locationManager.delegate = self;
    
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    _locationManager.locationTimeout = 10;
    _locationManager.reGeocodeTimeout = 10;
}

-(NSDictionary*)location2map:(BMKLocation*)location{
    
    BMKLocationReGeocode* rgcData = location.rgcData;
    BOOL isInChina = [BMKLocationManager BMKLocationDataAvailableForCoordinate:location.location.coordinate withCoorType:BMKLocationCoordinateTypeBMK09LL];
    
    return @{
         @"latitude":@(location.location.coordinate.latitude),
         @"longitude":@(location.location.coordinate.longitude),
         
         @"country":rgcData.country,
         @"countryCode":rgcData.countryCode,
         
         @"province":rgcData.province,
         
         @"city":rgcData.city,
         @"cityCode":rgcData.cityCode,
         
         @"district":rgcData.district,
         
         
         
         @"street":rgcData.street,
         
         @"locationDescribe":rgcData.locationDescribe,
         @"adCode":rgcData.adCode,
         @"isInChina":@(isInChina),
         @"errorCode":@(161),
    };
}

-(void)getCurrentLocation: (FlutterResult)result{
    self.completionBlock = ^(BMKLocation *location, BMKLocationNetworkState state, NSError *error)
    {
        if (error)
        {
            result(@{
                     @"errorCode" : @(error.code)
                     });
        }else {
            if (location) {//得到定位信息，添加annotation
                result([self location2map:location]);
            } else {
                result(@{
                         @"errorCode" : @(123456)
                         });
            }
        }
    };
    [_locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:self.completionBlock];
}

@end
