//
//  SXTitleLable.m
//  85 - 网易滑动分页
//
//  Created by 董 尚先 on 15-1-31.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXTitleLable.h"

@implementation SXTitleLable

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont systemFontOfSize:21];
        
        self.scale = 0.0;
        
    }
    return self;
}

/** 通过scale的改变改变多种参数 */
- (void)setScale:(CGFloat)scale
{
    _scale = scale;
//    self.textColor = [UIColor colorWithRed:scale green:0.0 blue:0.0 alpha:1];
    if (1.0 == scale) {
        self.textColor = [UIColor colorWithRed:30/255.0 green:77/255.0 blue:143/255.0 alpha:1];
    } else {
        self.textColor = [UIColor darkGrayColor];
    }
    CGFloat minScale = 0.8;
    CGFloat trueScale = minScale + (1-minScale)*scale;
    self.transform = CGAffineTransformMakeScale(trueScale, trueScale);
}

@end
