//
//  FSPagingScrollView.m
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 13-6-28.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "FSPagingScrollView.h"

@implementation FSPagingScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint parentLocation = [self convertPoint:point toView:[self superview]];
    CGRect responseRect = self.frame;
    responseRect.origin.x -= self.responseInsets.left;
    responseRect.origin.y -= self.responseInsets.top;
    responseRect.size.width += (self.responseInsets.left + self.responseInsets.right);
    responseRect.size.height += (self.responseInsets.top + self.responseInsets.bottom);
    
    return CGRectContainsPoint(responseRect, parentLocation);
}

@end
