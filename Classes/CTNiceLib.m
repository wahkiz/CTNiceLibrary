//
//  CTNiceLib.m
//  Supercharge your NSString and NSArray!
//  Copyright Reserved 2011 Calvin Tam
//  Revised from CTNiceArray 2010 Calvin Tam.


#import "CTNiceLib.h"
#define FILEPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]
#define TAGS [@"UDID,DEVICENAME,SYSTEMNAME,SYSTEMVERSION,MODEL" toArray]
static CGFloat bounceDuration = 0.3;
static Utilities *sharedUtilities = nil;
@implementation NSNotificationCenter (Extensions)
- (void)addObserver:(id)observer selectors:(NSArray *)mSelector names:(NSArray *)mName {
    for(int x=0;x<[mSelector count];x++){
        SEL currentSelector = NSSelectorFromString([mSelector objectAtIndex:x]);
        NSString *currentName = [mName objectAtIndex:x];
        [self addObserver:observer selector:currentSelector name:currentName object:nil];
    }
}
- (void)removeObserver:(id)observer names:(NSArray *)mName {
    for(NSString *aName in mName)
        [self removeObserver:observer name:aName object:nil];
}
@end
@implementation UIView(CTShortcuts)
- (UILabel *)asLabel {
    return (UILabel *)self;
}
- (UIImageView *)asImageView {
    return (UIImageView *)self;
}
- (UITextField *)asTextField {
    return (UITextField *)self;
}
- (UIButton *)asButton {
    return (UIButton *)self;
}
- (void)setAlpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration {
    [self setAlpha:alpha withDuration:duration animateFinish:nil delegate:nil];
}
- (void)setAlpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration animateFinish:(SEL)selector delegate:(id)del {
    [UIView beginAnimations:@"Frame Animation" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:del];
    [UIView setAnimationDidStopSelector:selector];
    [self setAlpha:alpha];
    [UIView commitAnimations];
}
- (void)setFrame:(CGRect)frame withDuration:(NSTimeInterval)duration {
    [self setFrame:frame withDuration:duration animateFinish:nil delegate:nil];
}
- (void)setFrame:(CGRect)frame withDuration:(NSTimeInterval)duration animateFinish:(SEL)selector delegate:(id)del {
    [UIView beginAnimations:@"Frame Animation" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:del];
    [UIView setAnimationDidStopSelector:selector];
    [self setFrame:frame];
    [UIView commitAnimations];
}
- (void)setHidden:(BOOL)hidden withDuration:(NSTimeInterval)duration {
    [UIView beginAnimations:@"Frame Animation" context:nil];
    [UIView setAnimationDuration:duration];
    [self setAlpha:hidden ? 0 : 1];
    [UIView commitAnimations];
}
- (void)animatePopOut:(CTPopOutDirection)direction withDuration:(NSTimeInterval)duration {
    [self animatePopOut:direction withDuration:duration animateFinish:nil delegate:nil];
}
- (void)animatePopOut:(CTPopOutDirection)direction withDuration:(NSTimeInterval)duration animateFinish:(SEL)selector delegate:(id)del {
    CGRect prevPos = self.frame;
    [self setFrame:CGRectMake(prevPos.origin.x + (direction==CTPopOutDirectionLeft ? - prevPos.size.width  : direction==CTPopOutDirectionRight ? prevPos.size.width : 0 ), prevPos.origin.y + (direction==CTPopOutDirectionTop ? - prevPos.size.height  : direction==CTPopOutDirectionBottom ? prevPos.size.height : 0 ), prevPos.size.width, prevPos.size.height)];
    [self setFrame:prevPos withDuration:duration animateFinish:selector delegate:del];
}
- (void)animatePopBack:(CTPopOutDirection)direction withDuration:(NSTimeInterval)duration {
    [self animatePopBack:direction withDuration:duration animateFinish:nil delegate:nil];
}
- (void)animatePopBack:(CTPopOutDirection)direction withDuration:(NSTimeInterval)duration animateFinish:(SEL)selector delegate:(id)del {
    CGRect prevPos = self.frame;
    [self setFrame:CGRectMake((direction==CTPopOutDirectionLeft ? - prevPos.size.width  : direction==CTPopOutDirectionRight ? self.superview.frame.size.width+prevPos.size.width : 0 ), prevPos.origin.y + (direction==CTPopOutDirectionTop ? - prevPos.size.height  : direction==CTPopOutDirectionBottom ? self.superview.frame.size.height+prevPos.size.height : 0 ), prevPos.size.width, prevPos.size.height) withDuration:duration animateFinish:selector delegate:del]; 
}
@end
@implementation NSMutableArray(CTNiceArray)
- (int)intAtIndex:(int)index {
    return [[self objectAtIndex:index] intValue];
}
@end
@implementation NSArray(CTNiceArray)
- (int)intAtIndex:(int)index {
    return [[self objectAtIndex:index] intValue];
}
+(NSArray *)arrayWithXMLFrom:(NSString *)source tag:(NSString *)t {
	return [self arrayWithStringsFrom:source prefix:[NSString stringWithFormat:@"<%@>",t] suffix:[NSString stringWithFormat:@"</%@>",t]];
}
+(NSArray *)arrayWithStringsFrom:(NSString *)source prefix:(NSString *)f suffix:(NSString *)t {
	NSMutableArray *temp = [NSMutableArray arrayWithCapacity:10];
	NSRange newRange = NSMakeRange(-1, 0);
	NSRange endPoint = [source rangeOfString:f options:(NSBackwardsSearch) range:NSMakeRange(newRange.location+1, [source length]-newRange.location-1)];
	if(endPoint.location==NSNotFound)
		NSLog(@"[CTNiceLib] (%@,%@) not found in %@",f,t,source);
	else
		for(;;) {
			newRange = [source rangeOfString:f options:(NSCaseInsensitiveSearch) range:NSMakeRange(newRange.location+1, [source length]-newRange.location-1)];
			NSRange backside = [source rangeOfString:t options:(NSCaseInsensitiveSearch) range:NSMakeRange(newRange.location+1, [source length]-newRange.location-1)];
			if(newRange.location==NSNotFound || backside.location==NSNotFound) break;
			[temp addObject:[source substringWithRange:NSMakeRange(newRange.location+newRange.length, backside.location-(newRange.location+newRange.length))]];
			if(newRange.location==endPoint.location) break;
		}
	return (NSArray *)temp;
}
- (NSArray *)excludeItemsWithPrefix:(NSString *)prefix suffix:(NSString *)suffix {
	NSMutableArray *temp = [NSMutableArray array];
	for(NSString *item in self)
		if(![item hasPrefix:prefix] && ![item hasSuffix:suffix])
			[temp addObject:item];
	self = temp;
	return self;
}
- (NSArray *)eliminateDoubleEntries {	
	self = [[NSSet setWithArray:self] allObjects];
	return self;	
}
- (void)saveAs:(NSString *)tag {
	[[Utilities sharedUtilities] saveObject:self Key:tag];
}
- (void)loadFrom:(NSString *)tag {
	self = [[Utilities sharedUtilities] getObject:tag];
}
+ (NSString *)loadFrom:(NSString *)tag {
	return [[Utilities sharedUtilities] getObject:tag];
}
@end
@implementation NSDictionary(CTNiceDictionary)
- (int)intForKey:(id)key {
    return [[self objectForKey:key] intValue];
}
@end
@implementation NSMutableDictionary(CTNiceDictionary)
- (int)intForKey:(id)key {
    return [[self objectForKey:key] intValue];
}
@end
@implementation NSString(CTNiceString)
- (void)delegate:(id)delegate delay:(NSTimeInterval)duration {
    SEL currentSelector = NSSelectorFromString(self);
    [delegate performSelector:currentSelector withObject:nil afterDelay:duration];
}
+(NSString *)stringBetweenXMLFrom:(NSString *)source tag:(NSString *)t {
	return [self stringBetweenStringFrom:source prefix:[NSString stringWithFormat:@"<%@>",t] suffix:[NSString stringWithFormat:@"</%@>",t]];
}
- (NSString *)stringInBetweenPrefix:(NSString *)prefix suffix:(NSString *)suffix {
	return [NSString stringBetweenStringFrom:self prefix:prefix suffix:suffix];
}
+(NSString *)stringBetweenStringFrom:(NSString *)source prefix:(NSString *)f suffix:(NSString *)t {
	NSRange newRange = [source rangeOfString:f options:(NSCaseInsensitiveSearch) range:NSMakeRange(0, [source length])];
	NSRange backside = [source rangeOfString:t options:(NSCaseInsensitiveSearch) range:NSMakeRange(newRange.location+1, [source length]-newRange.location-1)];
    if(backside.location==NSNotFound)
		return @"";
	else
        return [source substringWithRange:NSMakeRange(newRange.location+newRange.length, backside.location-(newRange.location+newRange.length))];
    return @"";
}
- (NSArray *)toArray {
	return [self componentsSeparatedByString:@","];
}
- (NSString *)stringByReplacingItems:(NSArray *)items withItems:(NSArray *)replaceItems {
	NSString *rep;
	if([items count]==[replaceItems count]){
		//Only Do Operation if both replace and to be replaced is same.
		for(int x=0;x<[items count];x++){
			rep = ([[replaceItems objectAtIndex:x] hasPrefix:@"[tag:"]) ? 
			[[Utilities sharedUtilities] getObject:[[replaceItems objectAtIndex:x] stringInBetweenPrefix:@"[tag:" suffix:@"]"]] :
			[replaceItems objectAtIndex:x];
			if(rep!=nil)
				self = [self stringByReplacingOccurrencesOfString:[items objectAtIndex:x] withString:rep];	
		}
		
	}
	return self;
}
- (NSArray *)arrayWithXMLTag:(NSString *)tag {
	return [NSArray arrayWithXMLFrom:self tag:tag];
}
- (NSString *)stringWithXMLTag:(NSString *)tag {
	return [self stringInBetweenPrefix:[NSString stringWithFormat:@"<%@>",tag] suffix:[NSString stringWithFormat:@"</%@>",tag]];
}
- (NSArray *)arrayWithStringBetweenPrefix:(NSString *)prefix suffix:(NSString *)suffix {
	return [NSArray arrayWithStringsFrom:self prefix:prefix suffix:suffix];
}
- (NSDictionary *)dictionaryWithContentsOfXMLTags {
	NSArray *cleanTags = [[[self arrayWithStringBetweenPrefix:@"<" suffix:@">"] excludeItemsWithPrefix:@"/" suffix:@""] eliminateDoubleEntries];
	NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
	for(NSString *tags in cleanTags){
		NSArray *contents = [self arrayWithXMLTag:tags];
		[newDict setObject:([contents count]==1) ? [contents objectAtIndex:0] : contents forKey:tags];
	}
	return newDict;
	
}
- (NSString *)string {
	//Detect if there are tags
	NSArray *tags = [self arrayWithStringBetweenPrefix:@"[tag:" suffix:@"]"];
	for(int x=0;x<[tags count];x++){
		NSString *val = [[Utilities sharedUtilities] getObject:[tags objectAtIndex:x]];
		if(val!=nil){
			self = [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[tag:%@]",[tags objectAtIndex:x]]
												   withString:val];	
		} else {
            [self stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"[tag:%@]",[tags objectAtIndex:x]]
                                            withString:@""]; //Replaces the tag as an empty string, denotes empty storage
        }
		
	}
	
	return self;
}
- (void)saveAs:(NSString *)tag {
	[[Utilities sharedUtilities] saveObject:self Key:tag];
}
- (void)loadFrom:(NSString *)tag {
	self = [[Utilities sharedUtilities] getObject:tag];
}
+ (NSString *)loadFrom:(NSString *)tag {
	return [[Utilities sharedUtilities] getObject:tag];
}
@end
@implementation Utilities

+ (Utilities *)sharedUtilities
{
	@synchronized(self)
	{
		if (sharedUtilities == nil)
			sharedUtilities = [[Utilities alloc] init];
	}
	// to avoid compiler warning
	return sharedUtilities;
}
+(id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if(sharedUtilities == nil){
			sharedUtilities = [super allocWithZone:zone];
			return sharedUtilities;
		}
	}
	// to avoid compiler warning
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


- (id)init {
	self = [super init];
    if (self) {
		NSFileManager *manager = [NSFileManager defaultManager];
		
		if (![manager fileExistsAtPath:[FILEPATH stringByAppendingString:@"/data.txt"]]){ // data not exist
			dict = [[NSMutableDictionary alloc] init];
			
			[dict writeToFile:[FILEPATH stringByAppendingString:@"/data.txt"] atomically:YES];
		} else {
			dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[FILEPATH stringByAppendingString:@"/data.txt"]];
		}
	}
    return self;
}
-(void) saveObject:(id)object Key:(NSString*)key{
	[dict setObject:object forKey:key];
	[dict writeToFile:[FILEPATH stringByAppendingString:@"/data.txt"] atomically:YES];
}
-(NSString *)param:(int)i {
	switch (i) {
		case 0:
			return [[UIDevice currentDevice] uniqueIdentifier];
			break;
		case 1:
			return [[UIDevice currentDevice] name];
			break;
		case 2:
			return [[UIDevice currentDevice] systemName];
			break;
		case 3:
			return [[UIDevice currentDevice] systemVersion];
			break;
		case 4:
			return [[UIDevice currentDevice] model];
			break;
		default:
			return @"";
			break;
	}
}
-(id) getObject:(NSString*)key{
	if([TAGS containsObject:key]){
		int idx = -1;
		for(int x=0;x<[TAGS count];x++)
			if([[TAGS objectAtIndex:x] isEqual:key]){
				idx=x;
				break;
			}
		return [self param:idx];
	}
	else
		return [dict objectForKey:key];
}
-(void) removeAllData{
	[[NSMutableDictionary dictionaryWithCapacity:10] writeToFile:[FILEPATH stringByAppendingString:@"/data.txt"] atomically:YES];	
}
-(NSArray*) allValues:(NSUInteger*)i{
	return [dict allValues];
} 
-(void) dealloc{
	
	[dict release];
	dict = nil;	
	
	[super dealloc];
}
#pragma mark Animation/Graphic Methods
- (UIImage *)imageForView:(UIView *)thisView {
    UIGraphicsBeginImageContext(thisView.frame.size);
    [thisView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(void)animateBounce:(UIView *)thisView {
    thisView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView beginAnimations:@"bounce" context:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1],thisView,nil]];
    [UIView setAnimationDuration:bounceDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
    thisView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    [UIView commitAnimations];
}
- (void)animationFinished:(NSString *)animationID finished:(BOOL)finish context:(NSArray *)context
{
    if ([animationID isEqualToString:@"bounce"])
    {
        switch ([[context objectAtIndex:0] intValue]) {
            case 1:
            {
                [UIView beginAnimations:@"bounce" context:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:2],[context objectAtIndex:1],nil]];
                [UIView setAnimationDuration:bounceDuration/2];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
                ((UIView *)[context objectAtIndex:1]).transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
                [context release];
                [UIView commitAnimations];
            }
                break;
                
            case 2:
            {
                [UIView beginAnimations:@"bounce" context:nil];
                [UIView setAnimationDuration:bounceDuration/2];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
                ((UIView *)[context objectAtIndex:1]).transform = CGAffineTransformIdentity;
                [context release];
                [UIView commitAnimations];
            }
                break;
        }
    }
}
- (UIView *)loadNibView:(NSString *)nibNamed {
    return [self loadNibView:nibNamed viewIndex:0];
}
- (UIView *)loadNibView:(NSString *)nibNamed viewIndex:(int)index {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:nibNamed
                                                      owner:self
                                                    options:nil];
    
    return [nibViews objectAtIndex:index];
}
@end

@implementation UILabel (VerticalAlign)
- (void)alignTop {
    CGSize fontSize = [self.text sizeWithFont:self.font];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [self.text stringByAppendingString:@"\n "];
}

- (void)alignBottom {
    CGSize fontSize = [self.text sizeWithFont:self.font];
    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label
    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        self.text = [NSString stringWithFormat:@" \n%@",self.text];
}
@end
