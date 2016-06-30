//
//  FZLocationService.m
//  5dsyClient
//
//  Created by Frank on 15/12/2.
//  Copyright © 2015年 Kakao China. All rights reserved.
//

#import "FZLocationService.h"
#import "JZLocationConverter.h"
#import <UIKit/UIKit.h>

#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface FZLocationService()<CLLocationManagerDelegate>

@property (copy, nonatomic) FZLocationUpdateBlock locationUpdateBlock;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation FZLocationService

+ (FZLocationService *)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if (IOS8) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    return self;
}

+ (void)locationWithCompleteBlock:(FZLocationUpdateBlock)block
{
    if ([self isLocationServiceAvailable]) {
        FZLocationService *instance = [self sharedInstance];
        instance.locationUpdateBlock = block;
        if (instance.locationManager) {
            [instance.locationManager startUpdatingLocation];
        }
    }
    else {
        block(nil, [NSError errorWithDomain:@"Location service not available" code:0 userInfo:nil]);
    }
    
}

+ (BOOL)isLocationServiceAvailable
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable" alwaysDescription
#pragma clang diagnostic ignored "-Wunused-variable" whenInUseDescription
#pragma clang diagnostic pop
        NSString *alwaysDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"];
        NSString *whenInUseDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"];
        NSAssert([alwaysDescription length] || [whenInUseDescription length], @"NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription key not present in the info.plist. Please add it in order to recieve location updates");
    }
    
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusNotDetermined:
            return YES;
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        default:
            return NO;
            break;
    }
#else
    switch (status) {
        case FZLAuthorizationStatusAuthorized:
        case FZLAuthorizationStatusNotDetermined:
            return YES;
            break;
        case FZLAuthorizationStatusDenied:
        case FZLAuthorizationStatusRestricted:
        default:
            return NO;
            break;
    }
#endif
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (self.locationUpdateBlock) {
        CLLocation *location = locations.lastObject;
        //转换为火星坐标
        CLLocationCoordinate2D convertedCoordinate = [JZLocationConverter wgs84ToGcj02:location.coordinate];
        CLLocation *convertedLocatioin = [[CLLocation alloc] initWithLatitude:convertedCoordinate.latitude longitude:convertedCoordinate.longitude];
        self.locationUpdateBlock(convertedLocatioin, nil);
        self.locationUpdateBlock = nil;
        [manager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    if (self.locationUpdateBlock) {
        self.locationUpdateBlock(nil, error);
        self.locationUpdateBlock = nil;
    }
}

@end
