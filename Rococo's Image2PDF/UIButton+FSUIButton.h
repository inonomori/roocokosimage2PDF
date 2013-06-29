//
//  UIButton+FSUIButton.h
//  Photo2GO
//
//  Created by Zhefu Wang on 13-6-28.
//  Copyright (c) 2013年 Finder Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (FSUIButton)

- (void)touched:(void (^)(void))event;
@property (nonatomic) CGRect originalFrame;

@end
