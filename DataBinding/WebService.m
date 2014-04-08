//
//  WebService.m
//  DataBinding
//
//  Created by Can Yaman on 02/04/14.
//  Copyright (c) 2014 Valensas. All rights reserved.
//

#import "WebService.h"
#import "AFJSONRequestOperation.h"

static WebService *sharedInstance=nil;

@implementation WebService
+(void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[self alloc] init];
        sharedInstance.client=[AFHTTPClient clientWithBaseURL:[NSURL URLWithString:sharedURL]];
        [sharedInstance.client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        [sharedInstance.client setDefaultHeader:@"Accept" value:@"application/json"];
        
    });
}
+(instancetype)sharedInstance{
    return sharedInstance;
}

+(AFHTTPRequestOperation *)reports:(void (^)(NSArray *result))success
                           failure:(void (^)(id error))failure{
    return [sharedInstance.client getPath:@"reports.json"
                               parameters:nil
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSMutableArray *reports=[NSMutableArray array];
                                      for (NSDictionary *reportDict in responseObject) {
                                          [reports addObject:[Report objectFromDictionary:reportDict]];
                                      }
                                      success(reports);
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      failure(error);
                                  }
            ];
}

@end
