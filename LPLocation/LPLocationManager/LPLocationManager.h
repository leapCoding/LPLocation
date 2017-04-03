//
//  LPLocationManager.h
//  LPLocation
//
//  Created by Leap on 2017/4/2.
//  Copyright © 2017年 LPDev. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface LPLocationManager : CLLocationManager

+ (instancetype)sharedManager;

@property (nonatomic, assign) CGFloat minSpeed;
@property (nonatomic, assign) CGFloat minFilter;
@property (nonatomic, assign) CGFloat minInteval;


@end
