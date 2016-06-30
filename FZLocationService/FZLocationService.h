//
//  KCLocationService.h
//  5dsyClient
//
//  Created by Frank on 15/12/2.
//  Copyright © 2015年 Kakao China. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^FZLocationUpdateBlock)(CLLocation *location, NSError *error);

@interface FZLocationService : NSObject

+ (void)locationWithCompleteBlock:(FZLocationUpdateBlock)block;

@end
