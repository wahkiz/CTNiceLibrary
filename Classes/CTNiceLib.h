//
//  CTNiceLib.h
//  Supercharge your NSString and NSArray!
//  Copyright Reserved 2011 Calvin Tam
//  Revised from CTNiceArray 2010 Calvin Tam.

#import <UIKit/UIKit.h>

@interface NSArray(CTNiceArray)
+(NSArray *)arrayWithXMLFrom:(NSString *)source tag:(NSString *)t;
+(NSArray *)arrayWithStringsFrom:(NSString *)source prefix:(NSString *)f suffix:(NSString *)t;
- (void)saveAs:(NSString *)tag;
- (void)loadFrom:(NSString *)tag;
+ (NSString *)loadFrom:(NSString *)tag;
- (NSArray *)eliminateDoubleEntries;
- (NSArray *)excludeItemsWithPrefix:(NSString *)prefix suffix:(NSString *)suffix;
@end
@interface NSString(CTNiceString)
- (NSString *)stringInBetweenPrefix:(NSString *)prefix suffix:(NSString *)suffix;
- (NSArray *)arrayWithXMLTag:(NSString *)tag;
- (NSString *)stringWithXMLTag:(NSString *)tag;
- (NSArray *)arrayWithStringBetweenPrefix:(NSString *)prefix suffix:(NSString *)suffix;
+(NSString *)stringBetweenXMLFrom:(NSString *)source tag:(NSString *)t;
+(NSString *)stringBetweenStringFrom:(NSString *)source prefix:(NSString *)f suffix:(NSString *)t;
- (void)saveAs:(NSString *)tag;
- (NSString *)string;
- (void)loadFrom:(NSString *)tag;
- (NSString *)stringByReplacingItems:(NSArray *)items withItems:(NSArray *)replaceItems;
- (NSArray *)toArray;
- (NSDictionary *)dictionaryWithContentsOfXMLTags;
+ (NSString *)loadFrom:(NSString *)tag;
@end
@interface File : NSObject {
	NSMutableDictionary *dict;
}
+ (File *)sharedFile;
-(void) saveObject:(id)object Key:(NSString *)key;
-(id) getObject:(NSString *)key;
-(void) removeAllData;
-(NSArray*) allValues:(NSUInteger*)i;
@end
