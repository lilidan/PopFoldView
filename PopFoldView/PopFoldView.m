//
//  PopFoldView.m
//  PopFoldView
//
//  Created by sgcy on 15/12/19.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import "PopFoldView.h"
#import "UIView+screenShot.h"
#import <QuartzCore/QuartzCore.h>

@interface PopFoldView()

@property (nonatomic,strong) UIView *topView, *bottomView;

@property (nonatomic,strong) UIView *detailContentView;
@property (nonatomic,strong) UIView *coverContentView;

@property (nonatomic,strong) UIImage* detailTopImage;
@property (nonatomic,strong) UIImage* detailBottomImage;
@property (nonatomic,strong) UIImage* coverImage;

@property (nonatomic,strong) CALayer* detailTopLayer;

@end

@implementation PopFoldView

const CGFloat kScaleRatio = 0.2;
const CGFloat kVerticalDelta = -50;
const CGFloat kTriggerDelta = 70;
const CGFloat kDetailCoverSeperatorConstant = 0.43;

- (void)initialize
{
    _detailContentView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height * 2)];
    _coverContentView = [[UIView alloc] initWithFrame:self.bounds];
    _topView = [[UIView alloc] initWithFrame:self.bounds];
    _bottomView = [[UIView alloc] initWithFrame:self.bounds];
    
    _detailTopLayer = [CALayer layer];
    self.detailTopLayer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    self.detailTopLayer.hidden = YES;
    [self.topView.layer addSublayer:self.detailTopLayer];
    
    [self addSubview:self.coverContentView];
    
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -600;
    self.layer.sublayerTransform = rotationAndPerspectiveTransform;
    
    [self setAnchorPoint:CGPointMake(0.5, 0) forView:self.topView];
}

- (void)pan:(UIPanGestureRecognizer *)panGr
{
    if (panGr.state == UIGestureRecognizerStateBegan)
    {
        [self toggleFoldIsStart:YES];
    }
    else if (panGr.state == UIGestureRecognizerStateChanged)
    {
        BOOL goCover = (self.status == PopFoldViewStatusGoCover);
        CGPoint translation = [panGr translationInView:self];
        CGFloat change = translation.y/self.frame.size.height;
        [self refreshProgress:(goCover ? 1 - change: - change) animated:NO];
    }
    else
    {
        BOOL goCover = (self.status == PopFoldViewStatusGoCover); //是否为detail开始
        CGPoint translation = [panGr translationInView:self];
        CGFloat change = translation.y/self.frame.size.height;
        CGFloat progress = (goCover ? 1 - change: - change);
        if (progress < -0.001)
        {
            if (goCover)
            {
                [self forward:YES];
                
                if ([self.delegate respondsToSelector:@selector(popFoldView:WillChange:)])
                {
                    [self.delegate popFoldView:self WillChange:NO];
                }
            }
            else
            {
                [self back:YES];
            }
        }
        else if (progress > 1.001)
        {
            if (!goCover)
            {
                [self forward:NO];
                
                if ([self.delegate respondsToSelector:@selector(popFoldView:WillChange:)])
                {
                    [self.delegate popFoldView:self WillChange:NO];
                }
            }
            else
            {
                [self back:NO];
            }
        }
        else
        {
            if (fabs(translation.y) < kTriggerDelta)
            {
                [self back:translation.y < 0];
            }
            else
            {
                [self forward:translation.y > 0];
                
                if ([self.delegate respondsToSelector:@selector(popFoldView:WillChange:)])
                {
                    [self.delegate popFoldView:self WillChange:(translation.y <= 0)];
                }
            }
        }
    }
}

- (void)refreshProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (progress < 0)
    {
        self.layer.transform = CATransform3DMakeTranslation(0, fabs(progress * self.frame.size.height/3), 0);
    }
    else if (progress > 1)
    {
        CGFloat scale = (1.0 + kScaleRatio);
        CATransform3D scaleTransform = CATransform3DMakeScale(scale,scale, 1.0);
        self.layer.transform = CATransform3DTranslate(scaleTransform, 0, kVerticalDelta-fabs((progress - 1) * self.frame.size.height/3), 0);
    }
    else
    {
        if (!animated)
        {
            CGFloat scale = 1.0 + kScaleRatio * progress;
            CATransform3D scaleTransform = CATransform3DMakeScale(scale,scale,1.0);
            self.layer.transform = CATransform3DTranslate(scaleTransform, 0, kVerticalDelta * progress, 0);
        }
        CATransform3D transform = CATransform3DMakeRotation(M_PI * progress, 1.0, 0, 0);
        self.topView.layer.transform = transform;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.detailTopLayer.hidden = (progress < kDetailCoverSeperatorConstant);
        [CATransaction commit];

    }
    _currentProgress = progress;
}

#pragma mark - helper

- (void)bounce:(BOOL)toCover
{
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.3
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGFloat scale = (toCover ? 1.0 : 1.0 + kScaleRatio);
                         CGFloat move = (toCover ? 0 : kVerticalDelta);
                         CATransform3D scaleTransform = CATransform3DMakeScale(scale,scale, 1.0);
                         self.layer.transform = CATransform3DTranslate(scaleTransform, 0, move, 0);
                     }
                     completion:^(BOOL finished) {

                     }];
}

- (void)back:(BOOL)toCover
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self refreshProgress:(!toCover ? 1.0 : 0) animated:YES];
                     } completion:^(BOOL finished) {
                         if (finished)
                         {
                             UIView *destinateView = (toCover ? self.coverContentView : self.detailContentView);
                             [self addSubview:destinateView];
                             [self.bottomView removeFromSuperview];
                             [self.topView removeFromSuperview];
                             _status = (toCover ? PopFoldViewStatusCover : PopFoldViewStatusDetail);
                             
                             if ([self.delegate respondsToSelector:@selector(popFoldView:DidChange:)])
                             {
                                 [self.delegate popFoldView:self DidChange:!toCover];
                             }
                          }
                     }];
    [self bounce:toCover];
}

- (void)forward:(BOOL)toCover
{
    BOOL directToDetail = (!toCover && _currentProgress > kDetailCoverSeperatorConstant);
    BOOL directToCover = (toCover && _currentProgress <= kDetailCoverSeperatorConstant);
    CGFloat duration = 0.3;
    if (directToCover || directToDetail)
    {
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self refreshProgress:(!toCover ? 1.0 : 0) animated:YES];
                         } completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self toggleFoldIsStart:NO];
                             }
                         }];
        [self bounce:toCover];
    }
    else
    {
        CGFloat beforeDuration = duration * (fabs(self.currentProgress - kDetailCoverSeperatorConstant)/1.0);
        CGFloat afterDuration  = duration - beforeDuration;
        [UIView animateWithDuration:beforeDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self refreshProgress:(!toCover ? kDetailCoverSeperatorConstant - 0.001 : kDetailCoverSeperatorConstant + 0.001) animated:NO];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [CATransaction begin];
                                 [CATransaction setDisableActions:YES];
                                 self.detailTopLayer.hidden = toCover;
                                 [CATransaction commit];
                                 [UIView animateWithDuration:afterDuration
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveLinear
                                                  animations:^{
                                                      [self refreshProgress:(!toCover ? 1.0 : 0) animated:YES];
                                                  } completion:^(BOOL finished) {
                                                      if (finished)
                                                      {
                                                          [self toggleFoldIsStart:NO];
                                                      }
                                                  }];
                                 [self bounce:toCover];
                             }
                         }];
    }
}

- (void)toggleFoldIsStart:(BOOL)isStart
{
    if (isStart)
    {
        BOOL goCover = (self.status == PopFoldViewStatusDetail);
        BOOL goDetail = (self.status == PopFoldViewStatusCover);
        if (goCover || goDetail)
        {
            UIView *originView = (!goCover ? self.coverContentView : self.detailContentView);
            [originView removeFromSuperview];
            [self addSubview:self.bottomView];
            [self addSubview:self.topView];
            [self.detailTopLayer setContents:(__bridge id)self.detailTopImage.CGImage];
            [self.topView.layer setContents:(__bridge id)self.coverImage.CGImage];
            [self.bottomView.layer setContents:(__bridge id)self.detailBottomImage.CGImage];
            _status = (goCover ? PopFoldViewStatusGoCover : PopFoldViewStatusGoDetail);
        }
    }
    else
    {
        BOOL goCover = (self.status == PopFoldViewStatusGoCover);
        UIView *destinateView = (goCover ? self.coverContentView : self.detailContentView);
        [self addSubview:destinateView];
        [self.bottomView removeFromSuperview];
        [self.topView removeFromSuperview];
        
        _status = (goCover ? PopFoldViewStatusCover : PopFoldViewStatusDetail);
        
        if ([self.delegate respondsToSelector:@selector(popFoldView:DidChange:)])
        {
            [self.delegate popFoldView:self DidChange:!goCover];
        }
    }
}

- (void)toggle:(BOOL)toCover
{
    if (self.status == PopFoldViewStatusCover && !toCover)
    {
        [self forward:NO];
    }
    else if (self.status == PopFoldViewStatusDetail && toCover)
    {
        [self forward:YES];
    }
}

#pragma mark - setter

- (void)setCoverContent:(UIView *)contentView
{
    for (UIView *view in self.coverContentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    contentView.frame = self.coverContentView.bounds;
    [self.coverContentView addSubview:contentView];
    self.coverImage = [self.coverContentView screenshot];
}

- (void)setDetailContent:(UIView *)contentView
{
    for (UIView *view in self.detailContentView.subviews)
    {
        [view removeFromSuperview];
    }

    contentView.frame = self.detailContentView.bounds;
    [self.detailContentView addSubview:contentView];
    UIImage *image = [self.detailContentView screenshot];
    [self seperateImage:image];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.detailContentView.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height * 2);
    self.coverContentView.frame = self.bounds;
    self.topView.frame = self.bounds;
    self.detailTopLayer.frame = self.topView.bounds;
    self.bottomView.frame = self.bounds;
}


#pragma mark - helper
- (void)seperateImage:(UIImage*)image
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, image.size.height*image.scale/2, image.size.width*image.scale, image.size.height*image.scale/2));
    self.detailBottomImage = [[UIImage alloc] initWithCGImage:imageRef];
    CFRelease(imageRef);
    
    CGImageRef imageRef2 = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, image.size.width*image.scale, image.size.height*image.scale/2));
    self.detailTopImage = [[UIImage alloc] initWithCGImage:imageRef2];
    CFRelease(imageRef2);
}


-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
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
