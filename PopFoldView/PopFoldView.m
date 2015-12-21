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

@property (nonatomic,strong) UIPanGestureRecognizer *panGr;

@property (nonatomic,assign) CGFloat currentProgress;
@property (nonatomic,assign) CGRect originFrame;

@end

@implementation PopFoldView

- (void)initialize
{
    _detailContentView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.frame.size.height, self.frame.size.width, self.frame.size.height * 2)];
    _coverContentView = [[UIView alloc] initWithFrame:self.bounds];
    _topView = [[UIView alloc] initWithFrame:self.bounds];
    _bottomView = [[UIView alloc] initWithFrame:self.bounds];
    
    [self addSubview:self.coverContentView];
    
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
    rotationAndPerspectiveTransform.m34 = 1.0 / -600;
    self.layer.sublayerTransform = rotationAndPerspectiveTransform;
    
    _panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:self.panGr];
    
    [self setAnchorPoint:CGPointMake(0.5, 0) forView:self.topView];

}

- (void)pan:(UIPanGestureRecognizer *)panGr
{
    if (panGr.state == UIGestureRecognizerStateBegan)
    {
        [self toggleFoldIsStart:YES isReverse:self.isDetailMode];
        _originFrame = self.frame;
    }
    else if (panGr.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGr translationInView:self];
        CGFloat change = translation.y/self.frame.size.height;
        [self animateProgress:(self.isDetailMode ? 1 - change: - change)];
    }
    else
    {
        CGPoint translation = [panGr translationInView:self];
        CGFloat change = translation.y/self.frame.size.height;
        CGFloat progress = (self.isDetailMode ? 1 - change: - change);
        if (progress < 0.001)
        {
            [self bounceToEnd:NO];
            if (self.isDetailMode)
            {
                [self animateToEnd:NO];
            }
        }
        else if (progress > 1.001)
        {
            [self bounceToEnd:YES];
            if (!self.isDetailMode)
            {
                [self animateToEnd:YES];
            }
        }
        else
        {
            [self animateToEnd:(translation.y < 0)];
        }
    }
}


- (void)animateProgress:(CGFloat)progress
{
    if (progress < 0)
    {
        CGRect frame = self.originFrame;
        frame.origin.y += fabs(progress * self.frame.size.height/3);
        self.frame = frame;
    }
    else if (progress > 1)
    {
        CGRect frame = self.originFrame;
        frame.origin.y -= fabs((progress - 1) * self.frame.size.height/3);
        self.frame = frame;
    }
    else
    {
        self.topView.layer.transform = CATransform3DMakeRotation(M_PI * progress, 1.0, 0, 0);
        UIImage *topViewImage = (progress > (0.5 - 0.055) ? self.detailTopImage : self.coverImage);
        [self.topView.layer setContents:(__bridge id)topViewImage.CGImage];
    }
    _currentProgress = progress;
}


- (void)bounceToEnd:(BOOL)toDetailMode
{
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = self.originFrame;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)animateToEnd:(BOOL)toDetailMode
{
    BOOL directToDetail = (toDetailMode && _currentProgress > 0.445);
    BOOL directToCover = (!toDetailMode && _currentProgress <= 0.445);
    CGFloat duration = 0.3;
    if (directToCover || directToDetail)
    {
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self animateProgress:(toDetailMode ? 1.0 : 0)];
                         } completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self toggleFoldIsStart:NO isReverse:!toDetailMode];
                             }
                         }];
    }
    else
    {
        CGFloat beforeDuration = duration * (fabs(self.currentProgress - 0.445)/1.0);
        CGFloat afterDuration  = duration - beforeDuration;
        [UIView animateWithDuration:beforeDuration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self animateProgress:(toDetailMode ? 0.444 : 0.446)];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 UIImage *topViewImage = (toDetailMode ? self.detailTopImage : self.coverImage);
                                 [self.topView.layer setContents:(__bridge id)topViewImage.CGImage];
                                 [UIView animateWithDuration:afterDuration
                                                       delay:0
                                                     options:UIViewAnimationOptionCurveLinear
                                                  animations:^{
                                                      [self animateProgress:(toDetailMode ? 1.0 : 0)];
                                                  } completion:^(BOOL finished) {
                                                      if (finished)
                                                      {
                                                          [self toggleFoldIsStart:NO isReverse:!toDetailMode];
                                                      }
                                                  }];
                             }
                         }];
    }
}

- (void)animate
{
    [self.coverContentView removeFromSuperview];
    [self addSubview:self.bottomView];
    [self addSubview:self.topView];
    [self.topView.layer setContents:(__bridge id)self.coverImage.CGImage];
    [self.bottomView.layer setContents:(__bridge id)self.detailBottomImage.CGImage];
    
    self.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [UIView animateWithDuration:3.0 animations:^{
        self.transform = CGAffineTransformMakeScale(0.9, 0.9);
        self.topView.layer.transform = CATransform3DMakeRotation(M_PI/2 - M_PI/19, 1.0, 0, 0);
    } completion:^(BOOL finished) {
           [self.topView.layer setContents:(__bridge id)self.detailBottomImage.CGImage];
        [UIView animateWithDuration:3.0 animations:^{
            self.topView.layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0, 0);
        } completion:^(BOOL finished) {
            [self.topView removeFromSuperview];
            [self.bottomView removeFromSuperview];
            [self addSubview:self.detailContentView];
        }];
    }];
}

- (void)toggleFoldIsStart:(BOOL)isStart isReverse:(BOOL)isReverse
{
    if (isStart)
    {
        UIView *originView = (!isReverse ? self.coverContentView : self.detailContentView);
        [originView removeFromSuperview];
        [self addSubview:self.bottomView];
        [self addSubview:self.topView];
        UIImage *topViewImage = (isReverse ? self.detailTopImage : self.coverImage);
        [self.topView.layer setContents:(__bridge id)topViewImage.CGImage];
        [self.bottomView.layer setContents:(__bridge id)self.detailBottomImage.CGImage];
    }
    else
    {
        UIView *destinateView = (isReverse ? self.coverContentView : self.detailContentView);
        [self addSubview:destinateView];
        [self.bottomView removeFromSuperview];
        [self.topView removeFromSuperview];
        _detailMode = !isReverse;
        [self bounceToEnd:!isReverse];
    }
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

#pragma mark - setter

- (void)setCoverContent:(UIView *)contentView
{
    contentView.frame = self.coverContentView.bounds;
    [self.coverContentView addSubview:contentView];
    self.coverImage = [self.coverContentView screenshot];
}

- (void)setDetailContent:(UIView *)contentView
{
    // add the actual visible view, as a subview of _contentView
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
    self.bottomView.frame = self.bounds;
}

- (void)seperateImage:(UIImage*)image
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, image.size.height*image.scale/2, image.size.width*image.scale, image.size.height*image.scale/2));
    self.detailTopImage = [[UIImage alloc] initWithCGImage:imageRef];
    CFRelease(imageRef);
    
    CGImageRef imageRef2 = CGImageCreateWithImageInRect([image CGImage], CGRectMake(0, 0, image.size.width*image.scale, image.size.height*image.scale/2));
    self.detailBottomImage = [[UIImage alloc] initWithCGImage:imageRef];
    CFRelease(imageRef2);
}
//[self.topView.layer setContents:(__bridge id)imageRef2];

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
