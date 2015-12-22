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

@interface PopFoldSlideView : UIView

@property (nonatomic,assign) NSInteger numberOfCells;  // n >= 3
@property (nonatomic,strong) NSArray<__kindof UIView *> *coverContentViews;
@property (nonatomic,strong) NSArray<__kindof UIView *> *detailContentViews;

@property (nonatomic,assign) PopFoldPanStatus panStatus;

@end
