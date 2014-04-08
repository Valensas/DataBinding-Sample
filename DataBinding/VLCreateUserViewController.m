//
//  VLCreateUserViewController.m
//  DataBinding
//
//  Created by Can Yaman on 03/04/14.
//  Copyright (c) 2014 Valensas. All rights reserved.
//

#import "VLCreateUserViewController.h"
#import "WaitOperation.h"

@interface VLCreateUserViewController ()

@end

@implementation VLCreateUserViewController

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

- (void) willPerformConfirmSegue:(id)sender{
    self.operation=[WaitOperation operaitonWithInterval:3];
    __weak VLTableViewController *this=self;
    [self.operation setCompletionBlock:^{
        [this removeActivityViewWithAnimation:YES];
        this.operation=nil;
        [this performSelector:@selector(performSegueWithIdentifier:sender:) withObject:@"ConfirmSegue" withObject:sender];
    }];
}

@end
