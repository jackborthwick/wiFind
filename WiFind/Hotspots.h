//
//  Hotspots.h
//  WiFind
//
//  Created by Jack Borthwick on 6/17/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Hotspots : NSManagedObject

@property (nonatomic, retain) NSString * hotspotLongitude;
@property (nonatomic, retain) NSString * hotspotLatitude;
@property (nonatomic, retain) NSString * hotspotName;
@property (nonatomic, retain) NSString * hotspotType;
@property (nonatomic, retain) NSString * hotspotAddress;

@end
