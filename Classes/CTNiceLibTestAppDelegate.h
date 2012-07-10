//
//  CTNiceLibTestAppDelegate.h
//  CTNiceLibTest
//
//  Created by Wah Kit Tam on 3/1/11.
//  Copyright 2011 toucharts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTNiceLib.h"
@interface CTNiceLibTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    IBOutlet UIView *testView, *testSlideView;
    IBOutlet UILabel *alphaDurationDisplay;
    float alphaDurationVal;
}
- (IBAction)toggleSlide:(id)sender;
- (IBAction)toggleVisibility;
- (IBAction)durationChanged:(id)sender;
- (IBAction)doSetframe:(id)sender;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

