//
//  CTNiceLib.m
//  Supercharge your NSString and NSArray!
//  Copyright Reserved 2011 Calvin Tam
//  Revised from CTNiceArray 2010 Calvin Tam.


#import "CTNiceLib.h"
#define filepath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]
#define TAGS [@"UDID,DEVICENAME,SYSTEMNAME,SYSTEMVERSION,MODEL" toArray]
static File *sharedFile = nil;
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
	NSRange endPoint = [source rangeOfString:f options:(NSCaseInsensitiveSearch,NSBackwardsSearch) range:NSMakeRange(newRange.location+1, [source length]-newRange.location-1)];
	if(endPoint.location==NSNotFound)
		NSLog(@"String not found, source : %@",source);
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
	[[File sharedFile] saveObject:self Key:tag];
}
- (void)loadFrom:(NSString *)tag {
	self = [[File sharedFile] getObject:tag];
}
+ (NSString *)loadFrom:(NSString *)tag {
	return [[File sharedFile] getObject:tag];
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
			[[File sharedFile] getObject:[[replaceItems objectAtIndex:x] stringInBetweenPrefix:@"[tag:" suffix:@"]"]] :
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
		[newDict setObject:contents forKey:tags];
	}
	return newDict;
	
}
- (NSString *)string {
	//Detect if there are tags
	NSArray *tags = [self arrayWithStringBetweenPrefix:@"[tag:" suffix:@"]"];
	for(int x=0;x<[tags count];x++){
		NSString *val = [[File sharedFile] getObject:[tags objectAtIndex:x]];
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
	[[File sharedFile] saveObject:self Key:tag];
}
- (void)loadFrom:(NSString *)tag {
	self = [[File sharedFile] getObject:tag];
}
+ (NSString *)loadFrom:(NSString *)tag {
	return [[File sharedFile] getObject:tag];
}
@end
@implementation File

+ (File *)sharedFile
{
	@synchronized(self)
	{
		if (sharedFile == nil)
			sharedFile = [[File alloc] init];
	}
	// to avoid compiler warning
	return sharedFile;
}
+(id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if(sharedFile == nil){
			sharedFile = [super allocWithZone:zone];
			return sharedFile;
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
		
		if (![manager fileExistsAtPath:[filepath stringByAppendingString:@"/data.txt"]]){ // data not exist
			dict = [[NSMutableDictionary alloc] init];
			
			[dict writeToFile:[filepath stringByAppendingString:@"/data.txt"] atomically:YES];
		} else {
			dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[filepath stringByAppendingString:@"/data.txt"]];
		}
	}
    return self;
}
-(void) saveObject:(id)object Key:(NSString*)key{
	[dict setObject:object forKey:key];
	[dict writeToFile:[filepath stringByAppendingString:@"/data.txt"] atomically:YES];
	//NSLog(@"Saving %@ = %@",key,object);
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
	//NSLog(@"Retrieving %@ = %@",key,[NSString stringWithFormat:@"%@",[dict objectForKey:key]]);
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
	[[NSMutableDictionary dictionaryWithCapacity:10] writeToFile:[filepath stringByAppendingString:@"/data.txt"] atomically:YES];	
}
-(NSArray*) allValues:(NSUInteger*)i{
	return [dict allValues];
} 
-(void) dealloc{
	
	[dict release];
	dict = nil;	
	
	[super dealloc];
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
