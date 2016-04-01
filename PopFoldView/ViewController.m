//
//  FellowshipViewController.m
//  Stockcraft
//
//  Created by sgcy on 16/1/11.
//  Copyright © 2016年 Guosen. All rights reserved.
//

#import "ViewController.h"

#import "PopFoldSlideView.h"

#define TEXT_ATTRIBUTE(COLOR,SIZE) @{NSFontAttributeName:[UIFont systemFontOfSize:SIZE],NSForegroundColorAttributeName : COLOR}
#define NAVIGATION_BAR_HEIGHT 64
#define TAB_BAR_HEIGHT 80
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ViewController () <PopFoldSlideViewDelegate>

@property (nonatomic,strong) PopFoldSlideView *slideView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationController.navigationBar.titleTextAttributes = TEXT_ATTRIBUTE([UIColor whiteColor], 18);
    [self.navigationController.navigationBar setBarTintColor:[UIColor lightGrayColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self setUpViews];
    [self setUpSlideView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setUpViews
{
    
    _slideView = [[PopFoldSlideView alloc] init];
    self.slideView.delegate = self;
    self.slideView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH,SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - 50);
    [self.view addSubview:self.slideView];
}

- (void)setUpSlideView
{
    NSMutableArray *coverViews = [[NSMutableArray alloc] init];
    NSMutableArray *detailViews = [[NSMutableArray alloc] init];
    NSArray *coverColors = @[[UIColor redColor],[UIColor blueColor],[UIColor yellowColor]];
    NSArray *detailColors = @[[UIColor purpleColor],[UIColor greenColor],[UIColor orangeColor]];
    
    for (int i = 0 ; i < 3; i++)
    {
        UIView *coverView = [[UIView alloc] init];
        coverView.backgroundColor = coverColors[i];
        [coverViews addObject:coverView];
        UIView *detailView = [[UIView alloc] init];
        detailView.backgroundColor = detailColors[i];
        [detailViews addObject:detailView];
    }
    
    [self.slideView setCoverContentViews:[coverViews copy]];
    [self.slideView setDetailContentViews:[detailViews copy]];

}

#pragma mark - delegate


- (void)popFoldSlideView:(NSInteger)index willChange:(BOOL)show
{

}

- (void)popFoldSlideView:(NSInteger)index didChange:(BOOL)show
{
    
}

@end
