//
//  DetailViewController.m
//  GetOnThatBus
//
//  Created by Gabriel Borri de Azevedo on 1/20/15.
//  Copyright (c) 2015 Gabriel Enterprises. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *routesLabel;
@property (weak, nonatomic) IBOutlet UILabel *intermodal;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.busStop.name;

    [self reverseGeocode:self.busStop.location];

    self.addressLabel.text = [NSString stringWithFormat:@"Address: "];
    self.routesLabel.text = [NSString stringWithFormat:@"Routes: %@",self.busStop.routes];
    if (self.busStop.intermodal == nil)
    {
        self.intermodal.text = @"No Intermodal Found";
    }
    else
    {
        self.intermodal.text = [NSString stringWithFormat:@"Intermodal: %@",self.busStop.intermodal];
    }
}

-(void)reverseGeocode:(CLLocation *)location
{
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@\n%@",
                             placemark.subThoroughfare,
                             placemark.thoroughfare,
                             placemark.locality
                             ];
        self.addressLabel.text = [NSString stringWithFormat:@"Address: %@", address];
    }];
}

@end
