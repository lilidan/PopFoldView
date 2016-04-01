//
//  PopFoldSlideView.m
//  PopFoldView
//
//  Created by sgcy on 15/12/22.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import "PopFoldSlideView.h"
#import "PopFoldView.h"

@interface PopFoldSlideView()<PopFoldViewDelegate>

@property (nonatomic,strong) NSArray<__kindof UIView *> *cells;
@property (nonatomic,assign) NSInteger currentIndex;

@property (nonatomic,strong) UIPanGestureRecognizer *panGr;

@property (nonatomic,assign) CGPoint originalPoint;

@end

@implementation PopFoldSlideView

const CGFloat kCellWidthRatio = 0.827;
const CGFloat kCellHeightRatio = 0.41;
const CGFloat kCellHorizonalPaddingRatio = 0.03;
const CGFloat kCellVerticalPaddingRatio = 0.03;
const CGFloat kTriggerChangeRatio = 0.15;
const CGFloat kCellScaleRatio = 0.9;

NSString *const PopFoldSlideViewWillSlideNotification = @"PopFoldSlideViewWillSlideNotification";
NSString *const PopFoldSlideViewDidSlideNotification = @"PopFoldSlideViewDidSlideNotification";

- (void)initialize
{
    self.panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:self.panGr];
    
    self.numberOfCells = 3;
    [self addCells];
}

- (void)pan:(UIPanGestureRecognizer *)panGr
{
    PopFoldView *popFoldView = self.subviews[1];
    
    CGFloat translationX = [panGr translationInView:self].x;
    CGFloat translationY = [panGr translationInView:self].y;
    
    if (panGr.state == UIGestureRecognizerStateBegan)
    {
        BOOL coverMode = (popFoldView.currentProgress == 0);
        BOOL horizonalMove = fabs(translationX) > fabs(translationY);
        _panStatus = (horizonalMove && coverMode ? PopFoldPanStatusHorizonal : PopFoldPanStatusVetical);
        
        if (!(horizonalMove && coverMode))
        {
            [popFoldView pan:panGr];
        }
        _originalPoint = popFoldView.center;
    }
    else if (panGr.state == UIGestureRecognizerStateChanged)
    {

        if (self.panStatus == PopFoldPanStatusHorizonal)
        {
            for (int i = -1; i < 2; i++)
            {
                CGPoint center = self.subviews[i+1].center;
                center.x = _originalPoint.x + translationX + i * CGRectGetWidth(self.frame) * (kCellWidthRatio + kCellHorizonalPaddingRatio);
                self.subviews[i+1].center = center;
                CGFloat delta = fabs(center.x - CGRectGetWidth(self.frame)/2) / (CGRectGetWidth(self.frame) * (kCellWidthRatio + kCellHorizonalPaddingRatio));
                CGFloat transform = 1 - (1 - kCellScaleRatio) * delta;
                self.subviews[i+1].transform = CGAffineTransformMakeScale(transform, transform);
            }
        }
        else
        {
            [popFoldView pan:panGr];
        }
    }
    else
    {
        if (self.panStatus == PopFoldPanStatusHorizonal)
        {
            CGFloat translationX = [panGr translationInView:self].x;
            if (translationX > CGRectGetWidth(self.frame) * kTriggerChangeRatio)
            {
                [self goToIndex:self.currentIndex - 1];
            }
            else if(translationX < - CGRectGetWidth(self.frame) * kTriggerChangeRatio)
            {
                [self goToIndex:self.currentIndex + 1];
            }
            else
            {
                [self goToIndex:self.currentIndex];
            }
            
            [popFoldView back:NO];
        }
        else
        {
            [popFoldView pan:panGr];
        }
        _panStatus = PopFoldPanStatusDefault;
    }
}

- (void)toggleOtherViewsHide:(BOOL)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.subviews[0].alpha = ( hide ? 0 : 1.0);
        self.subviews[2].alpha = ( hide ? 0 : 1.0);
    }];
}

- (void)goToIndex:(NSInteger)index
{
    if (index == self.currentIndex - 1)
    {
        index = (index < 0 ? self.cells.count - 1 : index);
        [self.subviews[2] removeFromSuperview];
        NSInteger addIndex = (index - 1 < 0 ? self.cells.count - 1 : index - 1);
        UIView *view = self.cells[addIndex];
        CGPoint center = view.center;
        center.x = self.subviews.firstObject.center.x - CGRectGetWidth(self.frame) * (kCellHorizonalPaddingRatio + kCellWidthRatio);
        view.center = center;
        view.transform = CGAffineTransformMakeScale(kCellScaleRatio, kCellScaleRatio);
        [self insertSubview:view atIndex:0];
        _currentIndex = index;
    }
    else if (index == self.currentIndex + 1)
    {
        index = (index > self.cells.count - 1 ? 0 : index);
        [self.subviews[0] removeFromSuperview];
        NSInteger addIndex = (index + 1 > self.cells.count - 1 ? 0 : index + 1);
        UIView *view = self.cells[addIndex];
        CGPoint center = view.center;
        center.x = self.subviews.lastObject.center.x + CGRectGetWidth(self.frame) * (kCellHorizonalPaddingRatio + kCellWidthRatio);
        view.center = center;
        view.transform = CGAffineTransformMakeScale(kCellScaleRatio, kCellScaleRatio);
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
        CGFloat centerX = CGRectGetWidth(self.frame)/2 + (i - 1) * CGRectGetWidth(self.frame) * (kCellHorizonalPaddingRatio + kCellWidthRatio);
        CGPoint center = cell.center;
        center.x = centerX;
        CGFloat duration = (animated ? 0.2 : 0);
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             cell.center = center;
                             cell.transform = (i == 1 ? CGAffineTransformIdentity : CGAffineTransformMakeScale(kCellScaleRatio, kCellScaleRatio));
                         }
                         completion:^(BOOL finished) {
                             if (self.currentIndex == i)
                             {
                                 [[NSNotificationCenter defaultCenter] postNotificationName:PopFoldSlideViewDidSlideNotification
                                                                                     object:nil
                                                                                   userInfo:@{@"index":@(self.currentIndex)}];
                             }
                         }];
    }
}

#pragma mark - delegate

- (void)popFoldView:(UIView *)view didChange:(BOOL)show
{
    if (!show)
    {
        [self toggleOtherViewsHide:NO];
    }
    
    for (int i = 0; i < self.cells.count; i++)
    {
        if (self.cells[i] == view)
        {
            if ([self.delegate respondsToSelector:@selector(popFoldSlideView:willChange:)])
            {
                [self.delegate popFoldSlideView:i willChange:show];
            }
        }
    }
}

- (void)popFoldView:(UIView *)view willChange:(BOOL)show
{
    if (show)
    {
        [self toggleOtherViewsHide:YES];
    }
    
    for (int i = 0; i < self.cells.count; i++)
    {
        if (self.cells[i] == view)
        {
            if ([self.delegate respondsToSelector:@selector(popFoldSlideView:didChange:)])
            {
                [self.delegate popFoldSlideView:i didChange:show];
            }
        }
    }
}

#pragma mark - setter

- (void)addCells
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    CGSize size = CGSizeMake(CGRectGetWidth(self.frame) * kCellWidthRatio,CGRectGetHeight(self.frame) * kCellHeightRatio);
    CGFloat bottomPadding = CGRectGetHeight(self.frame) * kCellVerticalPaddingRatio;
    
    NSMutableArray *cells = [NSMutableArray new];
    for (int i = 0 ; i < self.numberOfCells; i++)
    {
        PopFoldView *cell = [[PopFoldView alloc] init];
        cell.layer.cornerRadius = 4;
        cell.delegate = self;
        cell.frame = CGRectMake(0, CGRectGetHeight(self.frame) - size.height - bottomPadding, size.width, size.height);
        if (self.coverContentViews.count > i)
        {
            [cell setCoverContent:self.coverContentViews[i]];
        }
        if (self.detailContentViews.count > i)
        {
            [cell setDetailContent:self.detailContentViews[i]];
        }
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
