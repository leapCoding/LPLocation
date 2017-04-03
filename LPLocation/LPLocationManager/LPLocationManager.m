//
//  LPLocationManager.m
//  LPLocation
//
//  Created by Leap on 2017/4/2.
//  Copyright © 2017年 LPDev. All rights reserved.
//

#import "LPLocationManager.h"
#import "Realm.h"
#import "LPLoc.h"

@interface LPLocationManager ()<CLLocationManagerDelegate>

@property (nonatomic, assign) UIBackgroundTaskIdentifier taskIdentifier;

@end

@implementation LPLocationManager

+ (instancetype)sharedManager
{
    static LPLocationManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LPLocationManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if ( self )
    {
        self.minSpeed = 3;
        self.minFilter = 50;
        self.minInteval = 10;
        
        self.delegate = self;
        self.distanceFilter  = self.minFilter;
        self.desiredAccuracy = kCLLocationAccuracyBest;
        self.pausesLocationUpdatesAutomatically = NO;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            [self requestAlwaysAuthorization];//在后台也可定位
        }
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            self.allowsBackgroundLocationUpdates = YES;
        }
    }
    return self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations[0];
    NSLog(@"%@",location);
    [self adjustDistanceFilter:location];
    [self uploadLocation:location];

}

/**
 *  规则: 如果速度小于minSpeed m/s 则把触发范围设定为50m
 *  否则将触发范围设定为minSpeed*minInteval
 *  此时若速度变化超过10% 则更新当前的触发范围(这里限制是因为不能不停的设置distanceFilter,
 *  否则uploadLocation会不停被触发)
 */
- (void)adjustDistanceFilter:(CLLocation*)location {
    
    if ( location.speed < self.minSpeed )
    {
        if ( fabs(self.distanceFilter-self.minFilter) > 0.1f )
        {
            self.distanceFilter = self.minFilter;
        }
    }
    else
    {
        CGFloat lastSpeed = self.distanceFilter/self.minInteval;
        
        if ( (fabs(lastSpeed-location.speed)/lastSpeed > 0.1f) || (lastSpeed < 0) )
        {
            CGFloat newSpeed  = (int)(location.speed+0.5f);
            CGFloat newFilter = newSpeed*self.minInteval;
            
            self.distanceFilter = newFilter;
        }
    }

}

//位置上传
- (void)uploadLocation:(CLLocation*)location {
    
    LPLoc *loc = [LPLoc new];
    loc.date       = [NSDate date];
    loc.background = ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground);
    loc.loc        = [NSString stringWithFormat:@"speed:%.0f filter:%.0f",location.speed,self.distanceFilter];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:loc];
    }];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        //TODO HTTP upload
        
        [self endBackgroundUpdateTask];
    }else {
        //后台定位
        //假如上一次的上传操作尚未结束 则直接return
        if ( self.taskIdentifier != UIBackgroundTaskInvalid )
        {
            return;
        }

        [self beingBackgroundUpdateTask];

        //TODO HTTP upload
        //上传完成记得调用
//        [self endBackgroundUpdateTask];
    }
}

- (void)beingBackgroundUpdateTask
{
    self.taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    if ( self.taskIdentifier != UIBackgroundTaskInvalid )
    {
        [[UIApplication sharedApplication] endBackgroundTask: self.taskIdentifier];
        self.taskIdentifier = UIBackgroundTaskInvalid;
    }
}

@end
