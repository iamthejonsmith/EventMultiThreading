//
//  EventDetailViewController.h
//  EventMultiThreading
//
//  Created by Jon Smith on 8/13/15.
//  Copyright (c) 2015 Jon Smith. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventDetailViewController : UIViewController

@property (strong, nonatomic) Event *passedEvent;

@property (strong, nonatomic) NSString *passedString;

@end
