//
//  UIImageView+ByName.m
//  KKB
//
//  Created by Can Yaman on 20/11/13.
//  Copyright (c) 2013 Valensas. All rights reserved.
//

#import "UIImageView+ByName.h"
#import "UIImageView+AFNetworking.h"

@implementation UIImageView (UIImageView_ByName)


-(void)fileName:(NSString *)fileName{
    self.image=[UIImage imageNamed:fileName];
}
-(void)URL:(NSString *)url{
    [self setImageWithURL:[NSURL URLWithString:url]];
}

@end
