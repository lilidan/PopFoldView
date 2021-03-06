//
//  PopFoldSlideView.h
//  PopFoldView
//
//  Created by sgcy on 15/12/22.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PopFoldView;


typedef NS_ENUM(NSUInteger, PopFoldPanStatus)
{
    PopFoldPanStatusDefault = 0,
    PopFoldPanStatusVetical = 1,
    PopFoldPanStatusHorizonal = 2
};


@protocol PopFoldSlideViewDelegate <NSObject>

- (void)popFoldSlideView:(NSInteger)index willChange:(BOOL)show;
- (void)popFoldSlideView:(NSInteger)index didChange:(BOOL)show;

@end

extern NSString *const PopFoldSlideViewWillSlideNotification;
extern NSString *const PopFoldSlideViewDidSlideNotification;

@interface PopFoldSlideView : UIView

@property (nonatomic,assign) NSInteger numberOfCells;  // n >= 3
@property (nonatomic,strong) NSArray<__kindof UIView *> *coverContentViews;
@property (nonatomic,strong) NSArray<__kindof UIView *> *detailContentViews;

@property (nonatomic,assign) PopFoldPanStatus panStatus;

@property (nonatomic,weak) id<PopFoldSlideViewDelegate> delegate;

@end
