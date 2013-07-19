//
//  FSimageOrderChangingViewController.h
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 13-7-19.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "ViewController.h"

@interface FSimageOrderChangingViewController : UIViewController<GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate>

@property (nonatomic, strong) NSMutableArray *medianArray;
@property (nonatomic, weak) ViewController *delegate; //TODO: use protocol(later, im lazy)

@end
