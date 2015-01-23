//
//  MapViewController.m
//  GetOnThatBus
//
//  Created by Gabriel Borri de Azevedo on 1/20/15.
//  Copyright (c) 2015 Gabriel Enterprises. All rights reserved.
//

#import "MapViewController.h"
#import "DetailViewController.h"
#import "CustomAnnotation.h"
#import <MapKit/MapKit.h>
#import "BusStop.h"

@interface MapViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSArray *rowArray;
@property NSMutableArray *busStopArray;
@property MKPointAnnotation *reusablePoint;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property NSMutableArray *annotationsArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.hidden = TRUE;

    self.busStopArray = [NSMutableArray new];
    self.annotationsArray = [NSMutableArray new];
    self.tableView.delegate = self;

    [self parsingBusStops];
}

#pragma mark - Data Managing
-(void)pinEachBusStop
{
    for (BusStop *busStop in self.busStopArray)
    {
        CLLocationDegrees longitude;

        if ([busStop.longitude doubleValue] < 0)
        {
            longitude = [busStop.longitude doubleValue];
        }
        else
        {
            longitude = -[busStop.longitude doubleValue];
        }

        CLLocationDegrees latitude = [busStop.latitude doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);

        CustomAnnotation *annotation = [CustomAnnotation new];
        annotation.busStop = busStop;
        annotation.title = busStop.name;
        annotation.subtitle = busStop.routes;
        annotation.coordinate = coordinate;

        [self.annotationsArray addObject:annotation];
        [self.mapView addAnnotation:annotation];
    }
    [self.tableView reloadData];
    [self.mapView showAnnotations:self.annotationsArray animated:YES];
}

-(void)parsingBusStops
{
    NSURL *url = [NSURL URLWithString:@"https://s3.amazonaws.com/mobile-makers-lib/bus.json"];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary *busStopDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
         self.rowArray = [busStopDictionary objectForKey:@"row"];

         for (NSDictionary *busStopDict in self.rowArray)
         {
             BusStop *currentBusStop = [BusStop new];

             currentBusStop.longitude  = [busStopDict objectForKey:@"longitude"];

             currentBusStop.latitude  = [busStopDict objectForKey:@"latitude"];

             CLLocationDegrees longitude;

             if ([currentBusStop.longitude doubleValue] < 0)
             {
                 longitude = [currentBusStop.longitude doubleValue];
             }
             else
             {
                 longitude = -[currentBusStop.longitude doubleValue];
             }

             CLLocationDegrees latitude = [currentBusStop.latitude doubleValue];
             CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

             currentBusStop.location = location;

             currentBusStop.name  = [busStopDict objectForKey:@"cta_stop_name"];

             currentBusStop.routes = [busStopDict objectForKey:@"routes"];

             currentBusStop.intermodal = [busStopDict objectForKey:@"inter_modal"];
             NSLog(@"%@",currentBusStop.intermodal);

             [self.busStopArray addObject:currentBusStop];
         }
         [self pinEachBusStop];
     }];
}

#pragma mark - SegmentedControl
- (IBAction)onSegmentedControlTapped:(UISegmentedControl *)sender
{
    if ([self.segmentedControl selectedSegmentIndex] == 0)
    {
        self.tableView.hidden = TRUE;
    }
    else
    {
        self.tableView.hidden = FALSE;
    }
}

#pragma mark - MapKit Methods
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

    CustomAnnotation *customAnnontation = annotation;
    if ([customAnnontation.busStop.intermodal isEqualToString:@"Metra"])
    {
        pin.pinColor = MKPinAnnotationColorPurple;
    }
    else if ([customAnnontation.busStop.intermodal isEqualToString:@"Pace"])
    {
        pin.pinColor = MKPinAnnotationColorGreen;
    }

    pin.canShowCallout = YES;
    //pin.animatesDrop = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CustomAnnotation *customAnnotation = view.annotation;
    [self performSegueWithIdentifier:@"DetailSegue" sender:customAnnotation.busStop];
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *detailVC = [segue destinationViewController];
    detailVC.busStop = sender;
}

#pragma mark - TableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    CustomAnnotation *annontation = [self.annotationsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = annontation.busStop.name;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.annotationsArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomAnnotation *annontation = [self.annotationsArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"DetailSegue" sender:annontation.busStop];
}

@end
