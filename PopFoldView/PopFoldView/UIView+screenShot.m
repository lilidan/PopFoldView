//
//  UIView+screenShot.m
//  PopFoldView
//
//  Created by sgcy on 15/12/19.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import "UIView+screenShot.h"


@implementation UIView (Screenshot)

- (UIImage*)screenshot
{
    
    //UIGraphicsBeginImageContext(self.frame.size);
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    if (UIGraphicsGetCurrentContext()==nil)
    {
        NSLog(@"UIGraphicsGetCurrentContext() is nil. You may have a UIView with CGRectZero");
        return nil;
    }
    else
    {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return screenshot;
    }
    
}



@end
