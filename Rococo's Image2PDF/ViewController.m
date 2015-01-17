//
//  ViewController.m
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 3/6/13.
//  Copyright (c) 2013 Nonomori. All rights reserved.
//

#import "ViewController.h"
#import "FSPdfPreviewViewController.h"
#import "FSimageOrderChangingViewController.h"
#import "BackgroundCoverView.h"
#import <POP.h>

@interface ViewController ()

@property (strong, nonatomic) NSString* fileName;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *picSelectionButton;
@property (strong, nonatomic) BackgroundCoverView *coverView;
@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (nonatomic, strong) QBImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDialogViewTop;

@end


@implementation ViewController

- (void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
}

- (BackgroundCoverView*)coverView
{    
    if (!_coverView)
    {
        _coverView = [[BackgroundCoverView alloc] initWithFrame:CGRectMake(0, 0, [FSToolBox getApplicationFrameSize].width, [FSToolBox getApplicationFrameSize].height)];
        _coverView.alpha = 0.0;
    }
    return _coverView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fileName = @"roocoko.pdf";
    self.dialogView.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.dialogView.layer.shadowOpacity = 0.5f;
    self.dialogView.layer.shadowOffset = CGSizeMake(0, 0);
    self.dialogView.layer.shadowRadius = 4.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    POPSpringAnimation *anim = [self.picSelectionButton pop_animationForKey:@"duang"];
    
    if (anim){
        anim.springBounciness = 20;    // value between 0-20 default at 4
        anim.springSpeed = 2;     // value between 0-20 default at 4
        anim.toValue = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
    } else{
        anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
        anim.springBounciness = 20;    // value between 0-20 default at 4
        anim.springSpeed = 2;     // value between 0-20 default at 4
        anim.toValue = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
    }
    
    [self.picSelectionButton pop_addAnimation:anim forKey:@"duang"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectPics:(UIButton *)sender
{
    POPSpringAnimation *anim = [sender pop_animationForKey:@"duang"];

    NSValue *toValue = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
    if (anim) {
        anim.springBounciness = 20;    // value between 0-20 default at 4
        anim.springSpeed = 20;     // value between 0-20 default at 4
        anim.toValue = toValue;
        anim.delegate = self;
    } else {
        anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
        anim.delegate = self;
        anim.springBounciness = 20;    // value between 0-20 default at 4
        anim.springSpeed = 20;     // value between 0-20 default at 4
        anim.toValue = toValue;
        [self.picSelectionButton pop_addAnimation:anim forKey:@"duang"];
    }
}

- (IBAction)bubbleButtonTouchDown:(UIButton *)sender
{
    POPSpringAnimation *anim = [sender pop_animationForKey:@"duang"];
    NSValue *toValue = [NSValue valueWithCGSize:CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds))];
    if (anim) {
        anim.toValue = toValue;
    } else {
        anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
        anim.springBounciness = 20;    // value between 0-20 default at 4
        anim.springSpeed = 2;     // value between 0-20 default at 4
        anim.toValue = toValue;
        [self.picSelectionButton pop_addAnimation:anim forKey:@"duang"];
    }
}

- (IBAction)bubbleButtonTouchCancel:(UIButton *)sender
{
    POPSpringAnimation *anim = [sender pop_animationForKey:@"duang"];
    NSValue *toValue = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
    if (anim) {
        anim.toValue = toValue;
    } else {
        anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
        anim.springBounciness = 20;    // value between 0-20 default at 4
        anim.springSpeed = 2;     // value between 0-20 default at 4
        anim.toValue = toValue;
        [self.picSelectionButton pop_addAnimation:anim forKey:@"duang"];
    }
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"previewSegue"])
    {
        FSPdfPreviewViewController *cv = segue.destinationViewController;
        cv.filePath = [WQPDFManager pdfDestPathTmp:self.fileName];
    }
    else if ([segue.identifier isEqualToString:@"changeOrderSegue"])
    {
        FSimageOrderChangingViewController *cv = segue.destinationViewController;
        cv.delegate = self;
        cv.medianArray = [self.mediaInfoArray mutableCopy];
    }
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    self.mediaInfoArray = assets;
    [self dismissViewControllerAnimated:YES completion:^{
        [self reorderingImages];
    }];
}

- (void)reorderingImages
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    FSimageOrderChangingViewController *cv = [sb instantiateViewControllerWithIdentifier:@"SBimageOrderChangingViewController"];
    cv.medianArray = [self.mediaInfoArray mutableCopy];
    cv.testArray = self.mediaInfoArray;
    cv.delegate = self;
    
    [self presentViewController:cv animated:YES completion:nil];
}

- (void)makePDF
{
    [WQPDFManager WQCreatePDFFileWithSrc:self.mediaInfoArray toDestFile:self.fileName withPassword:nil];
    
    NSLog(@"Selected %lu photos", (unsigned long)self.mediaInfoArray.count);
    
    NSString *fileFullPath = [WQPDFManager pdfDestPathTmp:self.fileName];
    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileFullPath error:nil][NSFileSize] longLongValue];
    CGFloat formatedFileSize;
    NSString *fileSizeUnit;
    if (fileSize < 1024)
    {
        formatedFileSize = fileSize;
        fileSizeUnit = @"Bytes";
    }
    else if (fileSize >= 1024 && fileSize < 1048576)
    {
        formatedFileSize = (CGFloat)fileSize/1024;
        fileSizeUnit = @"KB";
    }
    else if (fileSize >= 1048576 && fileSize < 1073741824)
    {
        formatedFileSize = (CGFloat)fileSize/1048576;
        fileSizeUnit = @"MB";
    }
    else //if (fileSize >= 1073741824)
    {
        formatedFileSize = (CGFloat)fileSize/1073741824;
        fileSizeUnit = @"GB";
    }
    
    self.fileSizeLabel.text = [NSString stringWithFormat:@"File Size: %.1f %@",formatedFileSize,fileSizeUnit];
    
    [self.view insertSubview:self.coverView belowSubview:self.dialogView];
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayoutConstraintConstant];
    anim.springBounciness = 10;    // value between 0-20 default at 4
    anim.springSpeed = 7;     // value between 0-20 default at 4
    anim.toValue = @(-(CGRectGetMidY(self.view.bounds) + CGRectGetMidY(self.dialogView.bounds)));
    [self.constraintDialogViewTop pop_addAnimation:anim forKey:@"duang"];
    
    POPBasicAnimation *basicAnimation = [POPBasicAnimation animation];
    basicAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
    basicAnimation.toValue= @(0.8); // scale from 0 to 1
    basicAnimation.duration = 0.3f;
    [self.coverView pop_addAnimation:basicAnimation forKey:@"backgroundAlpha"];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)sendFileViaEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController* mcvc = [[MFMailComposeViewController alloc] init];
        mcvc.mailComposeDelegate = self;
        
        [mcvc setSubject:NSLocalizedString(@"mailComponentViewSubject", nil)];
        
        //add attachment
        [mcvc addAttachmentData:[NSData dataWithContentsOfFile:[WQPDFManager pdfDestPathTmp:self.fileName]] mimeType:@"application/pdf" fileName:@"attachment.pdf"];
        
        //正文
        NSString *emailBody = NSLocalizedString(@"productName",nil);
        [mcvc setMessageBody:emailBody isHTML:YES];
        
        mcvc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:mcvc animated:YES completion:nil];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:NSLocalizedString(@"cannotUseEmail",nil)
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark actionSheetDelegate
- (IBAction)sendEmailCancelButtonTouched:(UIButton *)sender
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.constraintDialogViewTop.constant = 0;
                         [self.view layoutIfNeeded];
                         self.coverView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.coverView removeFromSuperview];
                         POPSpringAnimation *anim = [self.picSelectionButton pop_animationForKey:@"duang"];
                         
                         if (anim){
                             anim.springBounciness = 20;    // value between 0-20 default at 4
                             anim.springSpeed = 2;     // value between 0-20 default at 4
                             anim.toValue = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
                         } else{
                             anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
                             anim.springBounciness = 20;    // value between 0-20 default at 4
                             anim.springSpeed = 2;     // value between 0-20 default at 4
                             anim.toValue = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
                         }
                         
                         [self.picSelectionButton pop_addAnimation:anim forKey:@"duang"];
                     }
     ];
}

- (IBAction)sendEmailOKButtonTouched:(UIButton *)sender
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.constraintDialogViewTop.constant = 0;
                         [self.view layoutIfNeeded];
                         self.coverView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.coverView removeFromSuperview];
                         [self sendFileViaEmail];
                         
                         POPSpringAnimation *anim = [self.picSelectionButton pop_animationForKey:@"duang"];
                         
                         if (anim){
                             anim.springBounciness = 20;    // value between 0-20 default at 4
                             anim.springSpeed = 2;     // value between 0-20 default at 4
                             anim.toValue = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
                         } else{
                             anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerSize];
                             anim.springBounciness = 20;    // value between 0-20 default at 4
                             anim.springSpeed = 2;     // value between 0-20 default at 4
                             anim.toValue = [NSValue valueWithCGSize:CGSizeMake(200, 200)];
                         }
                         
                         [self.picSelectionButton pop_addAnimation:anim forKey:@"duang"];
                     }
     ];
}

#pragma mark MailComposeDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //NSString *msg = @"";
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
           // msg = @"邮件发送取消";
            break;
        case MFMailComposeResultSaved:
            //msg = @"邮件保存成功";
            break;
        case MFMailComposeResultSent:
           // msg = @"邮件发送成功";
            break;
        case MFMailComposeResultFailed:
          //  msg = @"邮件发送失败";
            break;
        default:
            break;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[WQPDFManager pdfDestPathTmp:self.fileName] error:NULL];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - POPDelegate
- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished{
    anim.delegate = nil;
    if (finished){
        self.imagePickerController = [[QBImagePickerController alloc] init];
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsMultipleSelection = YES;
        self.imagePickerController.groupTypes = @[@(ALAssetsGroupSavedPhotos),
                                                  @(ALAssetsGroupPhotoStream),
                                                  @(ALAssetsGroupAlbum)];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.imagePickerController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

@end
