//
//  ViewController.m
//  PopFoldView
//
//  Created by sgcy on 15/12/19.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import "ViewController.h"
#import "PopFoldSlideView.h"
@interface ViewController ()

@end

@implementation ViewController
{
    PopFoldSlideView *hostView;
    CALayer *transformationLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    hostView = [[PopFoldSlideView alloc] init];
    hostView.frame = self.view.bounds;
    [self.view addSubview:hostView];
    
    NSMutableArray *array1 = [NSMutableArray new];
    NSMutableArray *array2 = [NSMutableArray new];

    for (int i = 0; i < 3; i++)
    {
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
        [array1 addObject:cover];
        [array2 addObject:detail];
    }
    [hostView setCoverContentViews:array1];
    [hostView setDetailContentViews:array2];
    
}

@end
