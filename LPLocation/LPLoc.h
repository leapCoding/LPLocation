//
//  LPLoc.h
//  LPLocation
//
//  Created by Leap on 2017/4/2.
//  Copyright © 2017年 LPDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
@interface LPLoc : RLMObject

@property (strong, nonatomic) NSDate        *date;
@property (copy, nonatomic) NSString      *loc;
@property (assign, nonatomic) BOOL          background;

@end

RLM_ARRAY_TYPE(LPLoc)
