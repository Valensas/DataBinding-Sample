//
//  OperationViewController.h
//  KKB
//
//  Created by Can Yaman on 9/11/13.
//  Copyright (c) 2013 Valensas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLTableViewController : UITableViewController<UITextFieldDelegate>
@property (nonatomic) NSOperation *operation;
@property (nonatomic) UITableViewCell *selectedCell;
@property (nonatomic) NSIndexPath *selectedIndex;
@property (nonatomic) id data;
@property (nonatomic) NSMutableDictionary *sectionsKeyPath;//section number, section data array key path
- (void)removeActivityViewWithAnimation:(BOOL)animation;
- (void)displayActivityView:(NSString *)label;
- (void)changeActivityView:(NSString *)label;
- (UITableViewCell *)parentCell:(UIView *)view;
@end
