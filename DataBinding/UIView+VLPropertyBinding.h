#import <UIKit/UIKit.h>

@interface UIView (VLPropertyBinding)

@property(nonatomic)NSString *segueIdentifier;

#pragma mark - Public methods
-(void)bindWithObject:(id)obj;
-(instancetype)cloneView;
-(void)setObject:(id)object forProperty:(NSString *)propretyName;
-(void)setShown:(BOOL)show;
-(BOOL)isShown;
@end

@interface UITableView (DataBinding)
-(NSMutableDictionary *)sectionData;
@property(nonatomic)BOOL headerShown;
@end