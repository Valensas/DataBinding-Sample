//
//  VLMultiButtonViewController.m
//  DataBinding
//
//  Created by Can Yaman on 02/04/14.
//  Copyright (c) 2014 Valensas. All rights reserved.
//

#import "VLMultiButtonViewController.h"
#import "WaitOperation.h"

@interface VLMultiButtonViewController ()

@end

@implementation VLMultiButtonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
 -(void)willPerformWithOpertionSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    VLViewController *destination=(VLViewController *)segue.destinationViewController;
    destination.operation=[WaitOperation operaitonWithInterval:2];
}
 */
-(void)didPerformWithOpertionSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    VLViewController *destination=(VLViewController *)segue.destinationViewController;
    NSOperation *waitOp=[WaitOperation operaitonWithInterval:2];
    destination.operation=waitOp;
}

-(void)willPerformAfterOperationSegue:(id)sender{
    NSOperation *waitOp=[WaitOperation operaitonWithInterval:2];
    self.operation=waitOp;
    __weak VLViewController *this=self;
    [self.operation setCompletionBlock:^{
        [this removeActivityViewWithAnimation:YES];
        this.operation=nil;
        [this performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"AfterOperationSegue" withObject:sender];
    }];
}
@end
