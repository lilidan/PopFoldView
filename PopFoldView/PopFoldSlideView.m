//
//  PopFoldSlideView.m
//  PopFoldView
//
//  Created by sgcy on 15/12/22.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import "PopFoldSlideView.h"
#import "PopFoldView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PopFoldSlideView()

@property (nonatomic,strong) NSArray<__kindof UIView *> *cells;
@property (nonatomic,assign) NSInteger currentIndex;

@property (nonatomic,strong) UIPanGestureRecognizer *panGr;

@property (nonatomic,assign) CGPoint originalPoint;

@end

@implementation PopFoldSlideView

const CGFloat kCellSizeRatio = 0.8;
const CGFloat kCellPaddingRatio = 0.05;
const CGFloat kTriggerChangeRatio = 0.15;

- (void)initialize
{
    self.panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    
    self.numberOfCells = 3;
    [self addCells];
    
}

- (void)pan:(UIPanGestureRecognizer *)panGr
{
    PopFoldView *popFoldView = self.subviews[1];
    
    if (panGr.state == UIGestureRecognizerStateBegan)
    {
        _originalPoint = popFoldView.frame.origin;
    }
    else if (panGr.state == UIGestureRecognizerStateChanged)
    {
        CGFloat translationX = [panGr translationInView:self].x;
        for (int i = -1; i < 2; i++)
        {
            CGRect frame = self.subviews[i+1].frame;
            frame.origin.x = _originalPoint.x + translationX + i * SCREEN_WIDTH * (kCellSizeRatio + kCellPaddingRatio);
            self.subviews[i+1].frame = frame;
        }
    }
    else
    {
        CGFloat translationX = [panGr translationInView:self].x;
        if (translationX > SCREEN_WIDTH * kTriggerChangeRatio)
        {
            [self goToIndex:self.currentIndex - 1];
        }
        else if(translationX < - SCREEN_WIDTH * kTriggerChangeRatio)
        {
            [self goToIndex:self.currentIndex + 1];
        }
        else
        {
            [self goToIndex:self.currentIndex];
        }
    }
}

- (void)goToIndex:(NSInteger)index
{
    if (index == self.currentIndex - 1)
    {
        index = (index < 0 ? self.cells.count - 1 : index);
        [self.subviews[2] removeFromSuperview];
        NSInteger addIndex = (index - 1 < 0 ? self.cells.count - 1 : index - 1);
        UIView *view = self.cells[addIndex];
        CGRect frame = view.frame;
        frame.origin.x = SCREEN_WIDTH/2 - SCREEN_WIDTH * kCellSizeRatio/2 - SCREEN_WIDTH * (kCellPaddingRatio + kCellSizeRatio);
        view.frame = frame;
        [self insertSubview:view atIndex:0];
        _currentIndex = index;
    }
    else if (index == self.currentIndex + 1)
    {
        index = (index > self.cells.count - 1 ? 0 : index);
        [self.subviews[0] removeFromSuperview];
        NSInteger addIndex = (index + 1 > self.cells.count - 1 ? 0 : index + 1);
        UIView *view = self.cells[addIndex];
        CGRect frame = view.frame;
        frame.origin.x = SCREEN_WIDTH/2 - SCREEN_WIDTH * kCellSizeRatio/2 + SCREEN_WIDTH * (kCellPaddingRatio + kCellSizeRatio);
        view.frame = frame;
        [self addSubview:view];
        _currentIndex = index;
    }
    [self layoutCellsAnimated:YES];
}

- (void)layoutCellsAnimated:(BOOL)animated
{
    for (int i = 0 ; i < 3; i++)
    {
        PopFoldView *cell = self.subviews[i];
        CGFloat originX = SCREEN_WIDTH/2 - SCREEN_WIDTH * kCellSizeRatio/2 + (i - 1) * SCREEN_WIDTH * (kCellPaddingRatio + kCellSizeRatio);
        CGRect frame = cell.frame;
        frame.origin.x = originX;
        CGFloat duration = (animated ? 0.3 : 0);
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cell.frame = frame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - setter

- (void)addCells
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    CGSize size = CGSizeMake(SCREEN_WIDTH * kCellSizeRatio,SCREEN_HEIGHT * kCellSizeRatio / 2);
    CGFloat bottomPadding = SCREEN_HEIGHT * kCellPaddingRatio * 2;
    
    NSMutableArray *cells = [NSMutableArray new];
    for (int i = 0 ; i < self.numberOfCells; i++)
    {
        PopFoldView *cell = [[PopFoldView alloc] init];
        cell.frame = CGRectMake(0, SCREEN_HEIGHT - size.height - bottomPadding, size.width, size.height);
        if (self.coverContentViews.count > i)
        {
            [cell setCoverContent:self.coverContentViews[i]];
        }
        if (self.detailContentViews.count > i)
        {
            [cell setDetailContent:self.detailContentViews[i]];
        }
        [cell.panGr requireGestureRecognizerToFail:self.panGr];
        [cells addObject:cell];
    }
    self.cells = [cells copy];
    
    for (int i = 0 ; i < 3; i++)
    {
        PopFoldView *cell = cells[i];
        [self addSubview:cell];
    }
    self.currentIndex = 1;
    
    [self layoutCellsAnimated:NO];
}

- (void)setNumberOfCells:(NSInteger)numberOfCells
{
    _numberOfCells = numberOfCells;
    [self addCells];
}

- (void)setCoverContentViews:(NSArray<__kindof UIView *> *)coverContentViews
{
    _coverContentViews = coverContentViews;
    [self addCells];
}

- (void)setDetailContentViews:(NSArray<__kindof UIView *> *)detailContentViews
{
    _detailContentViews = detailContentViews;
    [self addCells];
}

#pragma mark - init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

@end
