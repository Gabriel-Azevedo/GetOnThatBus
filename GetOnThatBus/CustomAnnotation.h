//
//  CustomAnnotation.h
//  GetOnThatBus
//
//  Created by Gabriel Borri de Azevedo on 1/20/15.
//  Copyright (c) 2015 Gabriel Enterprises. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BusStop.h"

@interface CustomAnnotation : MKPointAnnotation

@property BusStop *busStop;

@end
