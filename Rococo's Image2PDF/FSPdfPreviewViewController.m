//
//  FSPdfPreviewViewController.m
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 13-7-19.
//  Copyright (c) 2013年 Nonomori. All rights reserved.
//

#import "FSPdfPreviewViewController.h"
#import "UIViewController+FSViewController.h"
#import "FSNavigationController.h"

@interface FSPdfPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *navigationView;

@end

@implementation FSPdfPreviewViewController

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
	// Do any additional setup after loading the view.
    
    NSURL *targetURL = [NSURL fileURLWithPath:self.filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [[self.webView scrollView] setContentOffset:CGPointMake(0,500) animated:YES];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0.0, 50.0)"]];
    [self.webView loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(hideNavigationView) withObject:self afterDelay:0.4];
}

- (void)hideNavigationView
{
    [FSUIViewAnimation viewAnimationForView:self.navigationView WithDuration:0.3 isHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isAllowedSwipeBack
{
    return NO;
}

- (IBAction)backButtonTouched:(UIButton *)sender
{
    FSNavigationController *navCV = (FSNavigationController*)self.navigationController;
    [navCV popViewControllerWithSlideAnimation];

}

- (IBAction)touchedOnWebView:(UITapGestureRecognizer *)sender
{
    [FSUIViewAnimation viewAnimationForView:self.navigationView WithDuration:0.3 isHidden:!self.navigationView.hidden];
}

@end
