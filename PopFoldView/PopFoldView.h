//
//  PopFoldView.h
//  PopFoldView
//
//  Created by sgcy on 15/12/19.
//  Copyright © 2015年 sgcy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopFoldView : UIView

- (void)animate;
- (void)setCoverContent:(UIView *)contentView;
- (void)setDetailContent:(UIView *)contentView;

@end
