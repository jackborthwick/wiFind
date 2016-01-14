//
//  ViewController.h
//  WiFind
//
//  Created by Jack Borthwick on 6/17/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray    *hotspotArray;

@end

