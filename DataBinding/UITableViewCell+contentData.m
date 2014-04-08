//
//  UITableViewCell+contentData.m
//  ReactiveiOSApp
//
//  Created by Can Yaman on 06/12/13.
//  Copyright (c) 2013 Valensas. All rights reserved.
//

#import "UITableViewCell+contentData.h"
#import <objc/runtime.h>

static void * const ContentDataKey = (void*)&ContentDataKey;

@implementation UITableViewCell (ContentData)

-(void)setContentData:(id)contentData{
    objc_setAssociatedObject(self, ContentDataKey, contentData, OBJC_ASSOCIATION_RETAIN);
}
-(id)contentData{
    return objc_getAssociatedObject(self, ContentDataKey);
}
@end
