//
//  BusStop.h
//  GetOnThatBus
//
//  Created by Gabriel Borri de Azevedo on 1/20/15.
//  Copyright (c) 2015 Gabriel Enterprises. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BusStop : NSObject

@property NSString *longitude;
@property NSString *latitude;
@property NSString *name;
@property NSString *routes;
@property NSString *intermodal;
@property CLLocation *location;

@end
