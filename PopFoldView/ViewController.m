//
//  ViewController.m
//  PopFoldView
//
//  Created by sgcy on 15/12/19.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import "ViewController.h"
#import "PopFoldView.h"
@interface ViewController ()

@end

@implementation ViewController
{
    PopFoldView *hostView;
    CALayer *transformationLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    hostView = [[PopFoldView alloc] init];
    hostView.frame = CGRectMake(60, 250 , 200, 200);
    [self.view addSubview:hostView];
    
    UIView *cover = [[UIView alloc] init];
    cover.backgroundColor = [UIColor yellowColor];
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    view1.backgroundColor = [UIColor redColor];
    [cover addSubview:view1];
    UIView *detail = [[UIView alloc] init];
    detail.backgroundColor = [UIColor blueColor];
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(50, 150, 100, 100)];
    view2.backgroundColor = [UIColor greenColor];
    [detail addSubview:view2];
    [hostView setCoverContent:cover];
    [hostView setDetailContent:detail];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (UIImage *)screenShot: (UIView *) aView
{
    // Arbitrarily masks to 40%. Use whatever level you like
    UIGraphicsBeginImageContext(hostView.frame.size);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextSetRGBFillColor (UIGraphicsGetCurrentContext(), 0, 0, 0, 0.4f);
    CGContextFillRect (UIGraphicsGetCurrentContext(), hostView.frame);
    UIGraphicsEndImageContext();
    return image;
}


- (CALayer *) createLayerFromView: (UIView *) aView transform: (CATransform3D) transform
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.anchorPoint = CGPointMake(1.0f, 1.0f);
    imageLayer.frame = (CGRect){.size = hostView.frame.size};
    imageLayer.transform = transform;
    UIImage *shot = [self screenShot:aView.subviews[1]];
    imageLayer.contents = (__bridge id) shot.CGImage;
    return imageLayer;
}

//- (void)animationDidStart:(CAAnimation *)animation
//{
//    //    UIView *source = (UIView *) super.sourceViewController;
//    [source removeFromSuperview];
//}
//
//- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished
//{
//    //    UIView *dest = (UIView *) super.destinationViewController;
//    if (hostView !=nil) {
//        NSLog(@"hostView %@",hostView);
//        if (dest) {
//            [hostView addSubview:dest];
//        }
//    }
//    
//    [transformationLayer removeFromSuperlayer];
//    if (delegate)
//        SAFE_PERFORM_WITH_ARG(delegate, @selector(segueDidComplete), nil);
//    
//}

-(void)animateWithDuration: (CGFloat) aDuration
{
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.delegate = self;
    group.duration = aDuration;
    
    CGFloat halfWidth = hostView.frame.size.width / 2.0f;
    float multiplier =  -1.0f;
    
    CABasicAnimation *translationX = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.x"];
    translationX.toValue = [NSNumber numberWithFloat:multiplier * halfWidth];
    
    CABasicAnimation *translationZ = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.z"];
    translationZ.toValue = [NSNumber numberWithFloat:-halfWidth];
    
    CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.y"];
    rotationY.toValue = [NSNumber numberWithFloat: multiplier * M_PI_2];
    
    group.animations = [NSArray arrayWithObjects: rotationY, translationX, translationZ, nil];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    [CATransaction flush];
    [transformationLayer addAnimation:group forKey:@"animate"];
    
}

- (void) constructRotationLayer
{
    //    UIView *source = (UIView *) super.sourceViewController;
    //    UIView *dest = (UIView *) super.destinationViewController;
//    hostView = source.superview;
    
    transformationLayer = [CALayer layer];
    transformationLayer.frame = hostView.bounds;
    transformationLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    CATransform3D sublayerTransform = CATransform3DIdentity;
    sublayerTransform.m34 = 1.0 / -1000;
    [transformationLayer setSublayerTransform:sublayerTransform];
    [hostView.layer addSublayer:transformationLayer];
    
    CATransform3D transform = CATransform3DMakeTranslation(0, 0, 0);
    [transformationLayer addSublayer:[self createLayerFromView:hostView transform:transform]];
    
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    transform = CATransform3DTranslate(transform, hostView.frame.size.width, 0, 0);
//    if (!goesForward)
//    {
//        transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
//        transform = CATransform3DTranslate(transform, hostView.frame.size.width, 0, 0);
//        transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
//        transform = CATransform3DTranslate(transform, hostView.frame.size.width, 0, 0);
//    }
    
 //   [transformationLayer addSublayer:[self createLayerFromView:dest transform:transform]];
}

- (void)perform
{
    [self constructRotationLayer];
    [self animateWithDuration:0.4f];
}


@end
