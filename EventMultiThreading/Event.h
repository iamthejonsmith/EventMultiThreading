//
//  Event.h
//  EventMultiThreading
//
//  Created by Jon Smith on 8/13/15.
//  Copyright (c) 2015 Jon Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property(strong, nonatomic) NSString *venueName;
@property(strong, nonatomic) NSString *title;
@property(strong, nonatomic) NSDate *startTime;
@property(strong, nonatomic) NSString *venueURL;

@end
