//
//  ViewController.m
//  WiFind
//
//  Created by Jack Borthwick on 6/17/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import "ViewController.h"
#import "Hotspots.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
@interface ViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AppDelegate               *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic, weak) IBOutlet MKMapView          *hotspotMapView;
@property (nonatomic, strong) CLLocation                *lastLocation;


@end

@implementation ViewController

#pragma mark - Location Methods

-(void)annotateMapLocations {
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    for (id <MKAnnotation> annot in [_hotspotMapView annotations]) {
        [locs addObject:annot];
    }
    [_hotspotMapView removeAnnotations:locs];
    NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    for (Hotspots *hotspot in _hotspotArray) {
        MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
        pa.coordinate = CLLocationCoordinate2DMake([hotspot.hotspotLongitude floatValue],[hotspot.hotspotLatitude floatValue]);
//        NSLog(@"longitudeis %@ latitude is %@",hotspot.hotspotLongitude,hotspot.hotspotLatitude);
        pa.title = hotspot.hotspotName;
        [annotationArray addObject:pa];
    }
    [_hotspotMapView addAnnotations:annotationArray];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    _lastLocation = locations.lastObject;
    NSLog(@"locationx: %f,%f",_lastLocation.coordinate.latitude,_lastLocation.coordinate.longitude);
//    MKCoordinateRegion startupRegion;
//    startupRegion.center = CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude);
//    startupRegion.span = MKCoordinateSpanMake(0.5, 0.597129);
//    [_hotspotMapView setRegion:startupRegion animated:YES];
//    [_hotspotMapView regionThatFits:startupRegion];
}

- (void)turnOnLocationMonitoring {
    [_locationManager startUpdatingLocation];
    _hotspotMapView.showsUserLocation = true;
    
}

- (void) setupLocationMonitoring {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    NSLog(@"SLM");
    if([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusAuthorizedAlways: //is location services authorized always
                NSLog(@"SLM AA");
                [self turnOnLocationMonitoring];
                break;
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                NSLog(@"SLM WIU");
                [self turnOnLocationMonitoring];
                break;
            case kCLAuthorizationStatusDenied:{
                NSLog(@"SLM Den");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AHHHH" message:@"SO TURN IT ON LIKE DIDDY KONG" delegate:self cancelButtonTitle:@"AY" otherButtonTitles: nil];
                [alert show];
                break;
            }
            case kCLAuthorizationStatusNotDetermined:
                NSLog(@"SLM ND");
                if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [_locationManager requestWhenInUseAuthorization];
                    NSLog(@"Request");
                }
                break;
            default:
                NSLog(@"SLM def");
                break;
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"locationservices off" message:@"SO TURN IT ON LIKE DIDDY KONG" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (void) zoomToCenter {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = _lastLocation.coordinate.latitude; // your latitude value
    zoomLocation.longitude= _lastLocation.coordinate.longitude; // your longitude value
    NSLog(@"ZOOMTO CENTER location: %f,%f",_lastLocation.coordinate.latitude,_lastLocation.coordinate.longitude);
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.5; // change as per your zoom level
    span.longitudeDelta=0.5;
    region.span=span;
    region.center= zoomLocation;
    [_hotspotMapView setRegion:region animated:true];
    [_hotspotMapView regionThatFits:region];
}

#pragma mark - Database Methods

- (void) tempAddRecords {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Wireless_Hotspots_-_DC_Government" ofType:@"csv"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *tempHotSpotArray = [content componentsSeparatedByString:@"\n"];
    for (NSString *hotspot in tempHotSpotArray) {
        Hotspots *currHotspot = (Hotspots *)[NSEntityDescription insertNewObjectForEntityForName:@"Hotspots" inManagedObjectContext:_managedObjectContext];
        NSArray *hotspotInfoArray = [hotspot componentsSeparatedByString:@","];
        [currHotspot setHotspotLatitude: [hotspotInfoArray objectAtIndex:0]];
        [currHotspot setHotspotLongitude: [hotspotInfoArray objectAtIndex:1]];
        [currHotspot setHotspotName: [hotspotInfoArray objectAtIndex:3]];
        [currHotspot setHotspotAddress: [hotspotInfoArray objectAtIndex:4]];
        //[currHotspot setHotspotType: [hotspotInfoArray objectAtIndex:10]];
        NSLog(@"%@",currHotspot.hotspotName);
        

    }
    [_appDelegate saveContext];
    
}

-(NSArray *)fetchRestaurants {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Hotspots" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    return  [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = _appDelegate.managedObjectContext;
    [self setupLocationMonitoring];
    //[self tempAddRecords];
    _hotspotArray = [self fetchRestaurants];
    [self annotateMapLocations];
    NSLog(@"VDL");

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"VWA");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"VDA");
    if (_lastLocation) {
        [self zoomToCenter];
    }
    else {
        NSLog(@"last location still nil");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
