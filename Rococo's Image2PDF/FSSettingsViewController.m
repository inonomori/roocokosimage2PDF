//
//  FSSettingsViewController.m
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 13-6-24.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "FSSettingsViewController.h"
#import "FSNavigationController.h"
#import "UIViewController+FSViewController.h"
#import "FSPagingScrollView.h"
#import "FSPageValueDefinition.h"
#import "JSONKit.h"
#import "UIButton+FSUIButton.h"

@interface FSSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet FSPagingScrollView *scrollView;
@property (nonatomic, strong) NSArray *pageArray;
@property (nonatomic) NSInteger pageIndex;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSDictionary *allPageDictionary;

@end

@implementation FSSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageArray = @[@"LETTER",@"A3",@"A4",@"A5",@"B4",@"B5"];
    self.scrollView.contentSize = self.contentView.frame.size;
    [self addObserver:self forKeyPath:@"pageIndex" options:NSKeyValueObservingOptionOld context:nil];
    NSData *json = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pageSize" ofType:@"json"]];
    self.allPageDictionary = [[[JSONDecoder alloc] init] objectWithData:json];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (int i = 0; i < [self.pageArray count]; ++i)
    {
        NSDictionary *pageDic = self.allPageDictionary[[NSString stringWithFormat:@"PAGESIZE_%@",self.pageArray[i]]];
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i + 20;
        frame.origin.y = 12;
        frame.size = CGSizeMake(160, 200);
        UIImageView *subview = [[UIImageView alloc] initWithFrame:frame];
        subview.image = [UIImage imageNamed:pageDic[@"image"]];
        [self.scrollView addSubview:subview];
    }
    self.scrollView.contentSize = CGSizeMake(200 * [self.pageArray count], self.scrollView.frame.size.height);
    self.scrollView.responseInsets = UIEdgeInsetsMake(0, 60, 0, 60);
    NSDictionary *pageSizeDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"pageSize"];
    CGRect rect = CGRectMake(200*([self.pageArray indexOfObject:pageSizeDictionary[@"name"]]+1), 0, 1, 1);
    [self.scrollView scrollRectToVisible:rect animated:YES];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"pageIndex"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonTouched:(UIButton *)sender
{
    FSNavigationController *navCV = (FSNavigationController*)self.navigationController;
    [navCV popViewControllerWithSlideAnimation];
}

- (BOOL)isAllowedSwipeBack
{
    return NO;
}

- (IBAction)commitButtonTouched:(UIButton *)sender
{
    __weak __block FSSettingsViewController *weakSelf = self;
    [UIView animateWithDuration:0.05
                     animations:^{
                         sender.frame = sender.originalFrame;
                     }
                     completion:^(BOOL finished){
                         if (finished)
                             [sender touched:^{
                                 
                                 NSDictionary *pageSizeDic = self.allPageDictionary[[NSString stringWithFormat:@"PAGESIZE_%@",weakSelf.pageArray[weakSelf.pageIndex]]];
                                 NSLog(@"%@",pageSizeDic);
                                 [[NSUserDefaults standardUserDefaults] setObject:pageSizeDic forKey:@"pageSize"];
                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                 FSNavigationController *navCV = (FSNavigationController*)self.navigationController;
                                 [navCV popViewControllerWithSlideAnimation];
                             }];
                     }];    
}

- (IBAction)okButtonTouchCancel:(UIButton *)sender
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        sender.frame = sender.originalFrame;
    } completion:nil];
}

- (IBAction)okButtonTouchDown:(UIButton *)sender
{
    sender.originalFrame = sender.frame;
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         CGRect frame = sender.frame;
         CGFloat increasedWidth = frame.size.width*0.3;
         CGFloat increasedHeight = frame.size.height*0.3;
         frame.origin.x -= increasedWidth;
         frame.origin.y -= increasedHeight;
         frame.size.width += increasedWidth*2;
         frame.size.height += increasedHeight*2;
         sender.frame = frame;
     }
                     completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"pageIndex"])
    {        
        NSDictionary *pageSizeDic = self.allPageDictionary[[NSString stringWithFormat:@"PAGESIZE_%@",self.pageArray[self.pageIndex]]];

        self.descriptionLabel.text = [NSString stringWithFormat:@"%.2fx%.2f inch",[pageSizeDic[@"width_inch"] floatValue],[pageSizeDic[@"height_inch"] floatValue]];
    }
}

#pragma mark - UIScrollViewDelegation
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    self.pageIndex = floor((self.scrollView.contentOffset.x-pageWidth/2)/pageWidth) + 1;
}

@end
