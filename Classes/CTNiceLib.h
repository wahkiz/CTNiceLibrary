//
//  CTNiceLib.h
//  Supercharge your NSString and NSArray!
//  Copyright Reserved 2011 Calvin Tam
//  Revised from CTNiceArray 2010 Calvin Tam.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
typedef enum {
	CTPopOutDirectionLeft,
	CTPopOutDirectionRight,
	CTPopOutDirectionTop,
	CTPopOutDirectionBottom
} CTPopOutDirection;
@interface NSNotificationCenter (Extensions)
- (void)addObserver:(id)observer selectors:(NSArray *)mSelector names:(NSArray *)mName;
- (void)removeObserver:(id)observer names:(NSArray *)mName;
@end
@interface UIButton (WarningClear)
- (void)setFont:(UIFont *)font;
@end
@interface UIDevice (PrivateMethods)
- (void) setOrientation:(UIInterfaceOrientation)orientation;
@end
@interface UIView(CTShortcuts)
- (UILabel *)asLabel;
- (UITextField *)asTextField;
- (UIButton *)asButton;
- (void)setFrame:(CGRect)frame withDuration:(NSTimeInterval)duration;
- (void)setFrame:(CGRect)frame withDuration:(NSTimeInterval)duration animateFinish:(SEL)selector delegate:(id)del;
- (void)setHidden:(BOOL)hidden withDuration:(NSTimeInterval)duration;
- (void)setAlpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration;
- (void)setAlpha:(CGFloat)alpha withDuration:(NSTimeInterval)duration animateFinish:(SEL)selector delegate:(id)del;
- (void)animatePopOut:(CTPopOutDirection)direction withDuration:(NSTimeInterval)duration animateFinish:(SEL)selector delegate:(id)del;
- (void)animatePopOut:(CTPopOutDirection)direction withDuration:(NSTimeInterval)duration;
- (void)animatePopBack:(CTPopOutDirection)direction withDuration:(NSTimeInterval)duration animateFinish:(SEL)selector delegate:(id)del ;
- (void)animatePopBack:(CTPopOutDirection)direction withDuration:(NSTimeInterval)duration;
@end
@interface NSMutableArray(CTNiceArray)
- (int)intAtIndex:(int)index;
@end
@interface NSArray(CTNiceArray)
- (int)intAtIndex:(int)index;
+(NSArray *)arrayWithXMLFrom:(NSString *)source tag:(NSString *)t;
+(NSArray *)arrayWithStringsFrom:(NSString *)source prefix:(NSString *)f suffix:(NSString *)t;
- (void)saveAs:(NSString *)tag;
- (void)loadFrom:(NSString *)tag;
+ (NSString *)loadFrom:(NSString *)tag;
- (NSArray *)eliminateDoubleEntries;
- (NSArray *)excludeItemsWithPrefix:(NSString *)prefix suffix:(NSString *)suffix;
@end
@interface NSString(CTNiceString)
- (void)delegate:(id)delegate delay:(NSTimeInterval)duration;
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
@interface NSDictionary (CTNiceDictionary)
- (int)intForKey:(id)key;
@end
@interface NSMutableDictionary (CTNiceDictionary)
- (int)intForKey:(id)key;
@end
@interface Utilities : NSObject {
	NSMutableDictionary *dict;
}
+ (Utilities *)sharedUtilities;
- (UIImage *)imageForView:(UIView *)thisView;
-(void) saveObject:(id)object Key:(NSString *)key;
-(id) getObject:(NSString *)key;
-(void) removeAllData;
-(void)animateBounce:(UIView *)thisView;
- (UIView *)loadNibView:(NSString *)nibNamed viewIndex:(int)index;
- (UIView *)loadNibView:(NSString *)nibNamed;
-(NSArray*) allValues:(NSUInteger*)i;
@end
@interface UILabel (VerticalAlign)
- (void)alignTop;
- (void)alignBottom;
@end