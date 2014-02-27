//
//  UIButton+FSUIButton.m
//  Photo2GO
//
//  Created by Zhefu Wang on 13-6-28.
//  Copyright (c) 2013年 Finder Studio. All rights reserved.
//

#import "UIButton+FSUIButton.h"

static CGRect _originalFrame;

@implementation UIButton (FSUIButton)

- (void)touched:(void (^)(void))event
{
    [FSUIViewAnimation viewAnimationBubblePop:self toFrame:self.frame delayed:0 completion:^{
        if (event)
            event();
    }];
}

- (void)setOriginalFrame:(CGRect)originalFrame
{
    _originalFrame = originalFrame;
}

- (CGRect)originalFrame
{
    return _originalFrame;
}

@end
