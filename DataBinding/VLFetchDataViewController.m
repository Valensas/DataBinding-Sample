//
//  VLFetchDataViewController.m
//  DataBinding
//
//  Created by Can Yaman on 02/04/14.
//  Copyright (c) 2014 Valensas. All rights reserved.
//

#import "VLFetchDataViewController.h"
#import "WebService.h"

@implementation VLFetchDataViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak VLTableViewController *this=self;
    self.operation=[WebService reports:^(NSArray *result) {
        this.data=result;
    } failure:^(id error) {
        //
    }];
}
@end
