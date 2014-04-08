//
//  VLViewController.h
//  DataBinding
//
//  Created by Can Yaman on 02/04/14.
//  Copyright (c) 2014 Valensas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLViewController : UIViewController
@property(nonatomic)NSOperation *operation;
-(void)removeActivityViewWithAnimation:(BOOL)animation;
-(void)pushStoryboard:(NSString *)storyboardName;
-(void)transitionToStoryBoard:(NSString *)storyboardName transitionStyle:(UIModalTransitionStyle)modelStyle;
-(void)transitionToStoryBoard:(NSString *)storyboardName transitionStyle:(UIModalTransitionStyle)transitionStyle presentationStyle:(UIModalPresentationStyle)presentationStyle;

@end
