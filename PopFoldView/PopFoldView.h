//
//  PopFoldView.h
//  PopFoldView
//
//  Created by sgcy on 15/12/19.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PopFoldViewStatus)
{
    PopFoldViewStatusCover= 0,
    PopFoldViewStatusDetail = 1,
    PopFoldViewStatusGoCover = 2,
    PopFoldViewStatusGoDetail = 3
};

@interface PopFoldView : UIView

@property (nonatomic,assign) PopFoldViewStatus status;

- (void)pan:(UIPanGestureRecognizer *)panGr

- (void)setCoverContent:(UIView *)contentView;
- (void)setDetailContent:(UIView *)contentView;

- (void)toggle:(BOOL)toCover;

@end
