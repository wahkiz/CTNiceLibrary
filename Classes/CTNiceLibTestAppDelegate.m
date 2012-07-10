//
//  CTNiceLibTestAppDelegate.m
//  CTNiceLibTest
//
//  Created by Wah Kit Tam on 3/1/11.
//  Copyright 2011 toucharts. All rights reserved.
//

#import "CTNiceLibTestAppDelegate.h"

@implementation CTNiceLibTestAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    alphaDurationVal = 0.5f;
    [self.window makeKeyAndVisible];
    
	//Testing Parse XML
	NSString *testXML = @"<html><head><title>Test XML</title></head><body><tr><td>Apple</td><td>Boy</td><td>Cat</td></tr></body></head></html>";
	//Get List of Tags In XHTML
	/* 
	 To do so, we use arrayWithStringBetweenPrefix:Suffix: to grab words between "<" and ">". This however have a problem of also grabbing text
	 within the closing </> tag. Therefore, we can use the function 'excludeItemsWithPrefix:Suffix:' to effectively eliminate entries that has
	 a '/' in front of them, leaving us with only opening tags.
	 */
	
	NSLog(@"All Tags in XHTML : %@",[[testXML arrayWithStringBetweenPrefix:@"<" suffix:@">"] excludeItemsWithPrefix:@"/" suffix:@""]);
	/* Notice that due to the document having several <td> tags, 'td' appears several times in the array returned. We can instruct the NSArray
	 to eliminate double entries, so that we get a clean view of what tags are available in the document. Just use eliminateDoubleEntries. */
	NSLog(@"Overview of Tags in XHTML : %@",[[[testXML arrayWithStringBetweenPrefix:@"<" suffix:@">"] excludeItemsWithPrefix:@"/" suffix:@""] eliminateDoubleEntries]);
	
	//Once retrieving the tags, we are interested in getting items in the '<td>' section. This is possible using arrayWithXMLTag:
	NSLog(@"Items in <td> tags : %@",[testXML arrayWithXMLTag:@"td"]);
	//It is also possible to get an NSDictionary of the contents of all the XML Tags in the NSString. Use it with NSAutoreleasePool in heavy documents.
	NSLog(@"Dictionary of XML Contents : %@",[testXML dictionaryWithContentsOfXMLTags]);
	
	//You can directly save variables into memory using saveAs:
	[[NSString stringWithFormat:@"Calvin"] saveAs:@"username"];
	[[NSArray arrayWithObjects:@"a",@"b",@"c",nil] saveAs:@"TestArray"];
	
	//Load the variables back using loadFrom:
	NSLog(@"Load from tag 'username' : %@",[NSString loadFrom:@"username"]);
	NSLog(@"Load from tag 'TestArray' : %@",[NSArray loadFrom:@"TestArray"]);
	
	//Traditional file save also works
	[[Utilities sharedUtilities] saveObject:[NSString stringWithFormat:@"Test Saving 2"] Key:@"Testing2"];
	NSLog(@"Load from tag 'Testing2' : %@",[[Utilities sharedUtilities] getObject:@"Testing2"]);
	
	//A simpler way to declare arrays
	NSLog(@"Declaring Array using String : %@",[@"A,B,C,D,E" toArray]);
	
	NSLog(@"Replacing strings with tags : %@",[@"Hello [name], from what I gather, you are a [sex], [age] years old, currently [status]." 
	 stringByReplacingItems:[@"[name],[sex],[age],[status]" toArray] withItems:[@"[tag:username],boy,22,single" toArray]]);
	
	//Tags also include System Data
	NSLog(@"System data in tags :\n %@", [@"UDID : [tag:UDID]\n Name : [tag:DEVICENAME]\n System : [tag:SYSTEMNAME] [tag:SYSTEMVERSION]\n Model : [tag:MODEL]" string]);
    
    //It is possible to add many observers at a time
    [[NSNotificationCenter defaultCenter] addObserver:self selectors:[@"toggleViewVisibility:,alphaDuration:,setViewFrame:,toggleSlideView:" toArray] names:[@"toggleViewVisibility,alphaDuration,setViewFrame,toggleSlideView" toArray]];
    return YES;
}

- (IBAction)doSetframe:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setViewFrame" object:nil]; //Send a notification
}
- (IBAction)toggleVisibility {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleViewVisibility" object:nil]; //Send a notification
}
- (IBAction)durationChanged:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"alphaDuration" object:[NSString stringWithFormat:@"%0.2f",((UISlider *)sender).value]]; //Send a notification with slider value
}
- (IBAction)toggleSlide:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleSlideView" object:nil]; //Send a notification
}
- (void)setViewFrame:(NSNotification *)note {
    if(testView.frame.size.width!=200){
        //Default size
        [[NSString stringWithFormat:@"%0.f,%0.f,%0.f,%0.f",testView.frame.origin.x,testView.frame.origin.y,testView.frame.size.width,testView.frame.size.height] saveAs:@"defaultFrame"];
        //[testView setFrame:CGRectMake(50, 50, 200, 200) withDuration:0.5f animateFinish:nil delegate:nil];
        [testView setFrame:CGRectMake(50, 50, 200, 200) withDuration:0.5f];
    } else {
        //Set to default
        NSArray *defaultFrame = [[NSString loadFrom:@"defaultFrame"] componentsSeparatedByString:@","];
        [testView setFrame:CGRectMake([defaultFrame intAtIndex:0],[defaultFrame intAtIndex:1],[defaultFrame intAtIndex:2],[defaultFrame intAtIndex:3]) withDuration:0.5f];
    }
}
- (void)toggleViewVisibility:(NSNotification *)note {
    //This is a notification
    //[testView setAlpha:testView.alpha==0 ? 1 : 0 withDuration:alphaDurationVal animateFinish:nil delegate:nil]; //Use if require to call function after animation
    [testView setAlpha:testView.alpha==0 ? 1 : 0 withDuration:alphaDurationVal];
}
- (void)alphaDuration:(NSNotification *)note {
    [alphaDurationDisplay setText:[NSString stringWithFormat:@"Duration : %0.2f",[[note object] floatValue]]];
    alphaDurationVal = [[note object] floatValue];
}
- (void)toggleSlideView:(NSNotification *)note {
    //[testSlideView setHidden:NO withDuration:0.3f];
    if(!testSlideView.hidden){
        //If slideview is not hidden, we should slide it out of the view
        //We should save it's initial position in pop out state. 
        [[NSString stringWithFormat:@"%0.f,%0.f,%0.f,%0.f",testSlideView.frame.origin.x,testSlideView.frame.origin.y,testSlideView.frame.size.width,testSlideView.frame.size.height] saveAs:@"defaultSlideFrame"];
        [testSlideView animatePopBack:CTPopOutDirectionRight withDuration:0.5f animateFinish:@selector(resetPosition) delegate:self];
    } else {
        [testSlideView setHidden:NO];
        [testSlideView animatePopOut:CTPopOutDirectionRight withDuration:0.5f];
    }
}
- (void)resetPosition {
    //TestSlideView is hidden and placed back to original position
    [testSlideView setHidden:YES];
    NSArray *defaultFrame = [[NSString loadFrom:@"defaultSlideFrame"] componentsSeparatedByString:@","];
    [testSlideView setFrame:CGRectMake([defaultFrame intAtIndex:0],[defaultFrame intAtIndex:1],[defaultFrame intAtIndex:2],[defaultFrame intAtIndex:3]) withDuration:0.5f];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
