//
//  PopFoldView.h
//  PopFoldView
//
//  Created by sgcy on 15/12/19.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PopFoldViewStatus)   //只在开始和结束时改变，只在中途判断
{
    PopFoldViewStatusCover = 0,
    PopFoldViewStatusDetail = 1,
    PopFoldViewStatusMovingFromCover = 2,
    PopFoldViewStatusMovingFromDetail = 3,
};

typedef NS_ENUM(NSUInteger, PopFoldViewGo)  //只在中途改变，只在开始和结束时判断
{
    PopFoldViewStatusGoCover = 0,
    PopFoldViewStatusGoDetail = 1
};

@protocol PopFoldViewDelegate <NSObject>

@optional
- (void)popFoldView:(UIView *)view willChange:(BOOL)show;
- (void)popFoldView:(UIView *)view didChange:(BOOL)show;

@end


@interface PopFoldView : UIView

@property (nonatomic,assign) PopFoldViewStatus status;
@property (nonatomic,assign) PopFoldViewGo goTo;
@property (nonatomic,strong) id<PopFoldViewDelegate> delegate;

@property (nonatomic,assign) CGFloat currentProgress;

- (void)pan:(UIPanGestureRecognizer *)panGr;

- (void)setCoverContent:(UIView *)contentView;
- (void)setDetailContent:(UIView *)contentView;

- (void)toggle:(BOOL)toCover;
- (void)back;
- (void)back:(BOOL)shouldBounce;

@end
