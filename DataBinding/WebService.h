//
//  WebService.h
//  DataBinding
//
//  Created by Can Yaman on 02/04/14.
//  Copyright (c) 2014 Valensas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Report.h"
#import "Reporter.h"

static NSString *sharedURL=@"http://localhost:54321";

@interface WebService : NSObject
@property(nonatomic,strong)AFHTTPClient *client;

+(instancetype)sharedInstance;

+(AFHTTPRequestOperation *)reports:(void (^)(NSArray *result))success
                           failure:(void (^)(id error))failure;
@end
