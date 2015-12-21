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
    PopFoldViewStatusGoDetail = 3,
    PopFoldViewStatusBounceCover = 4,
    PopFoldViewStatusBounceDetail = 5,
};


@interface PopFoldView : UIView

@property (nonatomic,assign,getter=isDetailMode) BOOL detailMode;

- (void)animate;
- (void)setCoverContent:(UIView *)contentView;
- (void)setDetailContent:(UIView *)contentView;

@end
