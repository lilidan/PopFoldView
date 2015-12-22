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

@protocol PopFoldViewDelegate <NSObject>

@optional
- (void)popFoldView:(UIView *)view WillChange:(BOOL)show;
- (void)popFoldView:(UIView *)view DidChange:(BOOL)show;

@end


@interface PopFoldView : UIView

@property (nonatomic,assign) PopFoldViewStatus status;
@property (nonatomic,strong) id<PopFoldViewDelegate> delegate;

@property (nonatomic,assign) CGFloat currentProgress;

- (void)pan:(UIPanGestureRecognizer *)panGr;

- (void)setCoverContent:(UIView *)contentView;
- (void)setDetailContent:(UIView *)contentView;

- (void)toggle:(BOOL)toCover;
- (void)back:(BOOL)toCover;

@end
