//
//  VLViewController.m
//  DataBinding
//
//  Created by Can Yaman on 02/04/14.
//  Copyright (c) 2014 Valensas. All rights reserved.
//

#import "VLViewController.h"
#import "DejalActivityView.h"
#import "UIView+VLPropertyBinding.h"

#define INDICATOR_TIMEOUT_INTERVAL 30.0

static void *operationIsFinished = &operationIsFinished;


@interface VLViewController ()
@property (nonatomic) BOOL coverNavBar;
@property (nonatomic) NSUInteger labelWidth;
@property (nonatomic) NSTimer *timeoutTimer;

- (IBAction)displayActivityView:(NSString *)label;
- (void)changeActivityView:(NSString *)label;

@end


@implementation VLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)setOperation:(NSOperation *)operation{
    if (_operation) {
        [_operation removeObserver:self forKeyPath:@"state"];
    }
    _operation=operation;
    if (operation) {
        [self displayActivityView:nil];
        [operation addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:operationIsFinished];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.coverNavBar=TRUE;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.operation!=nil) {
            if (![[self.operation valueForKey:@"state"] isEqualToValue:@3]) {
                    [self displayActivityView:nil];
            }
        }
    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [self removeActivityViewWithAnimation:NO];
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated;
{
	[super viewDidDisappear:animated];
}

- (IBAction)displayActivityView:(NSString *)label;
{
    UIView *viewToUse = self.view;
    
    // Perhaps not the best way to find a suitable view to cover the navigation bar as well as the content?
    if (self.coverNavBar)
        viewToUse = self.navigationController.navigationBar.superview;
    
    if (!label)
    {
        // Display the appropriate activity style, with custom label text.  The width can be omitted or zero to use the text's width:
        [DejalBezelActivityView activityViewForView:viewToUse withLabel:label width:self.labelWidth];
    }
    else
    {
        // Display the appropriate activity style, with the default "Loading..." text:
        [DejalBezelActivityView activityViewForView:viewToUse];
    }
    
    // If this is YES, the network activity indicator in the status bar is shown, and automatically hidden when the activity view is removed.  This property can be toggled on and off as needed:
    [DejalActivityView currentActivityView].showNetworkActivityIndicator = YES;
    self.timeoutTimer=[NSTimer timerWithTimeInterval:INDICATOR_TIMEOUT_INTERVAL target:self selector:@selector(activityViewTimeout:) userInfo:nil repeats:FALSE];
    [[NSRunLoop mainRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
}

- (void)changeActivityView:(NSString *)label;
{
    // Change the label text for the currently displayed activity view:
    [DejalActivityView currentActivityView].activityLabel.text = label;
    
    // Disable the network activity indicator in the status bar, e.g. after downloading data and starting parsing it (don't have to disable it if simply removing the view):
    [DejalActivityView currentActivityView].showNetworkActivityIndicator = NO;
    
}
-(void)textFieldBecomeFirstReponder:(UIView *)parentView{
    for (UIView *view in [parentView subviews]) {
        if ([view isKindOfClass:[UITextField class]]) {
            if (![view isHidden]) {
                [view becomeFirstResponder];
                return;
            }
        }else{
            [self textFieldBecomeFirstReponder:view];
        }
    }
}

- (void)activityViewTimeout:(NSTimer *)timer{
    [self removeActivityViewWithAnimation:FALSE];
}

- (void)removeActivityViewWithAnimation:(BOOL)animation;
{
    // Remove the activity view, with animation for the two styles that support it:
    [DejalActivityView currentActivityView].showNetworkActivityIndicator = NO;
    [DejalBezelActivityView removeViewAnimated:animation];
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context == operationIsFinished) {
        NSOperation *op=object;
        if(op.isFinished){
            [self removeActivityViewWithAnimation:YES];
        }
        //        if ([[change valueForKey:@"new"] isEqualToValue:@3]) {
        //            [self removeActivityView];
        //        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
-(void)dealloc{
    self.operation=nil;
}
-(void)transitionToStoryBoard:(NSString *)storyboardName transitionStyle:(UIModalTransitionStyle)modelStyle{
    UIStoryboard *nextStoryboard=[UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *destinationViewController=[nextStoryboard instantiateInitialViewController];
    destinationViewController.modalTransitionStyle=modelStyle;
    [self presentViewController:destinationViewController animated:YES completion:nil];
}
-(void)transitionToStoryBoard:(NSString *)storyboardName transitionStyle:(UIModalTransitionStyle)transitionStyle presentationStyle:(UIModalPresentationStyle)presentationStyle{
    UIStoryboard *nextStoryboard=[UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *destinationViewController=[nextStoryboard instantiateInitialViewController];
    destinationViewController.modalTransitionStyle=transitionStyle;
    destinationViewController.modalPresentationStyle=presentationStyle;
    [self presentViewController:destinationViewController animated:YES completion:nil];
}
-(void)pushStoryboard:(NSString *)storyboardName{
    UIStoryboard *nextStoryboard=[UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *destinationViewController=[nextStoryboard instantiateInitialViewController];
    [self.navigationController pushViewController:destinationViewController animated:YES];
}
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    static NSString *jumpSuffix=@"Jump";
    if ([identifier hasSuffix:jumpSuffix]) {
        //perform storyboard load and init
        NSString *storyboardNameAndMethod=[identifier substringToIndex:identifier.length-jumpSuffix.length];
        //PushJump,CurlModelJump
        if ([storyboardNameAndMethod hasSuffix:@"Push"]) {
            NSString *storyboardName=[storyboardNameAndMethod substringToIndex:storyboardNameAndMethod.length-@"Push".length];
            [self pushStoryboard:storyboardName];
        }else {
            NSString *storyboardName=storyboardNameAndMethod;
            UIModalTransitionStyle modelStyle=UIModalTransitionStyleCoverVertical;
            if ([storyboardName hasSuffix:@"Cover"]) {
                storyboardName=[storyboardNameAndMethod substringToIndex:storyboardNameAndMethod.length-@"Cover".length];
                modelStyle=UIModalTransitionStyleCoverVertical;
            }else if ([storyboardName hasSuffix:@"Flip"]) {
                storyboardName=[storyboardNameAndMethod substringToIndex:storyboardNameAndMethod.length-@"Flip".length];
                modelStyle=UIModalTransitionStyleFlipHorizontal;
            }else if ([storyboardName hasSuffix:@"Cross"]) {
                storyboardName=[storyboardNameAndMethod substringToIndex:storyboardNameAndMethod.length-@"Cross".length];
                modelStyle=UIModalTransitionStyleCrossDissolve;
            }else if ([storyboardName hasSuffix:@"Curl"]) {
                storyboardName=[storyboardNameAndMethod substringToIndex:storyboardNameAndMethod.length-@"Curl".length];
                modelStyle=UIModalTransitionStylePartialCurl;
            }
            [self transitionToStoryBoard:storyboardName transitionStyle:modelStyle];
        }
        return NO;
    }else{
        NSString *selectorName=[NSString stringWithFormat:@"willPerform%@:",identifier];
        SEL segueSelector=NSSelectorFromString(selectorName);
        if ([self respondsToSelector:segueSelector]) {
            //sysnchronious operation action
            [self performSelector:segueSelector withObject:sender];
            return NO;
        }else{
            return YES;
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *selectorName=[NSString stringWithFormat:@"didPerform%@:sender:",segue.identifier];
    SEL prepareSegueSelector=NSSelectorFromString(selectorName);
    if ([self respondsToSelector:prepareSegueSelector]) {
        [self performSelector:prepareSegueSelector withObject:segue withObject:sender];
    }else{
        [super prepareForSegue:segue sender:sender];
    }
}
- (IBAction)dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end