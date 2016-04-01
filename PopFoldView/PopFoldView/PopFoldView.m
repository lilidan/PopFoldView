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

@property (nonatomic,strong) UIView* reverseTopView;

@property (nonatomic,assign) CGFloat changingProgress;
@property (nonatomic,assign) NSInteger isAnimatingCount;

@end

@implementation PopFoldView

const CGFloat kScaleRatio = 0.1;
const CGFloat kVerticalDelta = -20;
const CGFloat kTriggerDelta = 70;
const CGFloat kDetailCoverSeperatorConstant = 0.43;
const CGFloat kCornerRadius = 4;

- (void)initialize
{
    _detailContentView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height * 2)];
    _coverContentView = [[UIView alloc] initWithFrame:self.bounds];
    _topView = [[UIView alloc] initWithFrame:self.bounds];
    _bottomView = [[UIView alloc] initWithFrame:self.bounds];
    
    self.coverContentView.layer.cornerRadius = kCornerRadius;
    self.coverContentView.layer.masksToBounds = YES;
    self.detailContentView.layer.cornerRadius = kCornerRadius;
    self.detailContentView.layer.masksToBounds = YES;
    
    _goTo = PopFoldViewStatusGoCover;
    _status = PopFoldViewStatusCover;
    
    _reverseTopView = [UIView new];
    self.reverseTopView.hidden = YES;
    self.reverseTopView.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(-1, 1), M_PI);
    [self.topView addSubview:self.reverseTopView];
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
        [self start];
        _changingProgress = self.currentProgress;
    }
    else if (panGr.state == UIGestureRecognizerStateChanged)
    {
        CGFloat transY = [panGr translationInView:self].y;
        CGFloat change = transY/self.frame.size.height;
        CGFloat progress = self.changingProgress - change;
        
        [self refreshProgress:progress scaled:YES];
    }
    else
    {
        CGFloat transY = [panGr translationInView:self].y;
        if (fabs(transY) < kTriggerDelta)
        {
            [self back];
        }
        else
        {
            if (self.goTo == PopFoldViewStatusGoCover && transY < 0)
            {
                self.goTo = PopFoldViewStatusGoDetail;
            }
            if (self.goTo == PopFoldViewStatusGoDetail && transY > 0)
            {
                self.goTo = PopFoldViewStatusGoCover;
            }
            
            [self forward];
        }
    }
}

- (void)refreshProgress:(CGFloat)progress scaled:(BOOL)scaled
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
        if (scaled)
        {
            CGFloat scale = 1.0 + kScaleRatio * progress;
            CATransform3D scaleTransform = CATransform3DMakeScale(scale,scale,1.0);
            self.layer.transform = CATransform3DTranslate(scaleTransform, 0, kVerticalDelta * progress, 0);
        }
        CATransform3D transform = CATransform3DMakeRotation(M_PI * progress, 1.0, 0, 0);
        self.topView.layer.transform = transform;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.reverseTopView.hidden = (progress < kDetailCoverSeperatorConstant);
        [CATransaction commit];
    }
    _currentProgress = progress;
}

#pragma mark - actions

- (void)bounce
{
    BOOL toCover = (self.goTo == PopFoldViewStatusGoCover);
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

- (void)back:(BOOL)shouldBounce
{
    BOOL toCover = (self.goTo == PopFoldViewStatusGoCover);
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                             [self refreshProgress:(!toCover ? 1.0 : 0) scaled:shouldBounce];
                     } completion:^(BOOL finished) {
                             [self end];
                     }];
    if (shouldBounce)
    {
        [self bounce];
    }
}

- (void)back
{
    [self back:YES];
}

- (void)forward
{
    BOOL toCover = (self.goTo == PopFoldViewStatusGoCover);
    BOOL directToDetail = (!toCover && _currentProgress > kDetailCoverSeperatorConstant);
    BOOL directToCover = (toCover && _currentProgress <= kDetailCoverSeperatorConstant);
    CGFloat duration = 0.2;
    if (directToCover || directToDetail)
    {
        [self back];
    }
    else
    {
        CGFloat beforeDuration = duration * (fabs(self.currentProgress - kDetailCoverSeperatorConstant)/1.0);
        CGFloat afterDuration  = duration - beforeDuration;
        [UIView animateWithDuration:beforeDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self refreshProgress:(!toCover ? kDetailCoverSeperatorConstant - 0.001 : kDetailCoverSeperatorConstant + 0.001) scaled:YES];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [CATransaction begin];
                                 [CATransaction setDisableActions:YES];
                                 self.reverseTopView.hidden = toCover;
                                 [CATransaction commit];
                                 [UIView animateWithDuration:afterDuration
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveLinear
                                                  animations:^{
                                                      [self refreshProgress:(!toCover ? 1.0 : 0) scaled:YES];
                                                  } completion:^(BOOL finished) {
                                                      [self end];
                                                  }];
                                 [self bounce];
                             }
                         }];
    }
}

- (void)start
{
    self.coverImage = [self.coverContentView screenshot];
    UIImage *image = [self.detailContentView screenshot];
    [self seperateImage:image];
    
    BOOL isDetail = (self.status == PopFoldViewStatusDetail);
    BOOL isCover = (self.status == PopFoldViewStatusCover);
    if (isCover || isDetail)
    {
        UIView *originView = (isCover ? self.coverContentView : self.detailContentView);
        [originView removeFromSuperview];
        [self addSubview:self.bottomView];
        [self addSubview:self.topView];
        [self.reverseTopView.layer setContents:(__bridge id)self.detailTopImage.CGImage];
        [self.topView.layer setContents:(__bridge id)self.coverImage.CGImage];
        [self.bottomView.layer setContents:(__bridge id)self.detailBottomImage.CGImage];
        _status = ( isCover ? PopFoldViewStatusMovingFromCover : PopFoldViewStatusMovingFromDetail );
    }
    self.isAnimatingCount ++;
    if ([self.delegate respondsToSelector:@selector(popFoldView:willChange:)])
    {
        [self.delegate popFoldView:self willChange:isCover];
    }
}

- (void)end
{
    self.isAnimatingCount --;
    if (self.isAnimatingCount > 0)
    {
        return;
    }

    BOOL toCover = (self.goTo == PopFoldViewStatusGoCover);
    UIView *destinateView = (toCover ? self.coverContentView : self.detailContentView);
    [self addSubview:destinateView];
    [self.bottomView removeFromSuperview];
    [self.topView removeFromSuperview];
    _status = (toCover ? PopFoldViewStatusCover : PopFoldViewStatusDetail);
    if ([self.delegate respondsToSelector:@selector(popFoldView:didChange:)])
    {
        [self.delegate popFoldView:self didChange:!toCover];
    }
}

- (void)toggle:(BOOL)toCover
{
    [self start];
    self.goTo = (toCover ? PopFoldViewStatusGoCover : PopFoldViewStatusGoDetail);
    [self forward];
}


#pragma mark - setter

- (void)setCoverContent:(UIView *)contentView
{
    for (UIView *view in self.coverContentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    contentView.frame = self.coverContentView.bounds;
    [contentView layoutIfNeeded];
    [self.coverContentView addSubview:contentView];
    [self.coverContentView layoutIfNeeded];
}

- (void)setDetailContent:(UIView *)contentView
{
    for (UIView *view in self.detailContentView.subviews)
    {
        [view removeFromSuperview];
    }

    contentView.frame = self.detailContentView.bounds;
    [self.detailContentView addSubview:contentView];
    [self.detailContentView layoutIfNeeded];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.detailContentView.frame = CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height * 2);
    self.coverContentView.frame = self.bounds;
    self.topView.frame = self.bounds;
    self.reverseTopView.frame = self.topView.bounds;
    self.bottomView.frame = self.bounds;
}

- (UIView *)hitTest:(CGPoint)point withViewTag:(NSInteger)tag
{
    UIView *view = [self viewWithTag:tag];
    if (view && view.userInteractionEnabled)
    {
        CGRect frame = [view.superview convertRect:view.frame toView:self];
        if (CGRectContainsPoint(frame, point))
        {
            return view;
        }
    }
    return nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (NSNumber *tag in @[@(201),@(202),@(203),@(200)])
    {
        UIView *view = [self hitTest:point withViewTag:tag.integerValue];
        if (view)
        {
            return view;
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - helper
- (void)seperateImage:(UIImage*)image
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, image.size.height*image.scale/2, image.size.width*image.scale, image.size.height*image.scale/2));
    CGImageRef imageRef2 = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, image.size.width*image.scale, image.size.height*image.scale/2));
    
    self.detailTopImage = [[UIImage alloc] initWithCGImage:imageRef2];
    self.detailBottomImage = [[UIImage alloc] initWithCGImage:imageRef];
    
    CFRelease(imageRef);
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
