//
//  VLCreateUserViewController.h
//  DataBinding
//
//  Created by Can Yaman on 03/04/14.
//  Copyright (c) 2014 Valensas. All rights reserved.
//

#import "VLTableViewController.h"

@interface VLCreateUserViewController : VLTableViewController
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *avatarTextField;
@end
