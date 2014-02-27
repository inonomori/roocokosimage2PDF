//
//  ViewController.m
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 3/6/13.
//  Copyright (c) 2013 Nonomori. All rights reserved.
//

#import "ViewController.h"
#import "UIButton+FSUIButton.h"
#import "FSPdfPreviewViewController.h"
#import "FSimageOrderChangingViewController.h"
#import "BackgroundCoverView.h"

@interface ViewController ()

@property (strong, nonatomic) NSString* fileName;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *picSelectionButton;
@property (strong, nonatomic) BackgroundCoverView *coverView;
@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (nonatomic, strong) QBImagePickerController *imagePickerController;

@end


@implementation ViewController

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
    if (self.picSelectionButton.frame.size.width == 1)
        [FSUIViewAnimation viewAnimationBubblePop:self.picSelectionButton toFrame:CGRectMake([FSToolBox getApplicationFrameSize].width/2-100, [FSToolBox getApplicationFrameSize].height/2-100, 200, 200) delayed:0.3 completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectPics:(UIButton *)sender
{
    __weak __block ViewController *weakSelf = self;
    [UIView animateWithDuration:0.05
                     animations:^{
                         sender.frame = sender.originalFrame;
                     }
                     completion:^(BOOL finished){
                         if (finished)
                             [sender touched:^{
                                 
                                  self.imagePickerController = [[QBImagePickerController alloc] init];
                                 self.imagePickerController.delegate = weakSelf;
                                 self.imagePickerController.allowsMultipleSelection = YES;
                                 self.imagePickerController.groupTypes = @[@(ALAssetsGroupSavedPhotos),
                                                                      @(ALAssetsGroupPhotoStream),
                                                                      @(ALAssetsGroupAlbum)];
                                 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.imagePickerController];
                                 [weakSelf presentViewController:navigationController animated:YES completion:NULL];
                             }];
                     }];
}

- (IBAction)bubbleButtonTouchDown:(UIButton *)sender
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

- (IBAction)bubbleButtonTouchCancel:(UIButton *)sender
{
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        sender.frame = sender.originalFrame;
    } completion:nil];
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

//- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
//{
//    self.mediaInfoArray = (NSArray *)info;
//    [self dismissViewControllerAnimated:YES completion:^{
//        [self reorderingImages];
//    }];
//    
//    
//}

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
    [WQPDFManager WQCreatePDFFileWithSrc2:self.mediaInfoArray toDestFile:self.fileName withPassword:nil];
    
    NSLog(@"Selected %d photos", self.mediaInfoArray.count);
    
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
    [FSUIViewAnimation AnimatedCenteringView:self.dialogView
                                    Duration:0.65
                            AddtionAnimation:^{
                                self.coverView.alpha = 0.8;
                            }
                                  Completion:nil];
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
//-(void)actionSheet:(UIActionSheet *)actionSheet
//didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 0) //yes button
//    {
//        if ([MFMailComposeViewController canSendMail])
//        {
//            MFMailComposeViewController* mcvc = [[MFMailComposeViewController alloc] init];
//            mcvc.mailComposeDelegate = self;
//            
//            [mcvc setSubject:NSLocalizedString(@"mailComponentViewSubject", nil)];
//            
//            //add attachment
//            [mcvc addAttachmentData:[NSData dataWithContentsOfFile:[WQPDFManager pdfDestPathTmp:self.fileName]] mimeType:@"application/pdf" fileName:@"attachment.pdf"];
//            
//            //正文
//            NSString *emailBody = NSLocalizedString(@"productName",nil);
//            [mcvc setMessageBody:emailBody isHTML:YES];
//            
//            mcvc.modalPresentationStyle = UIModalPresentationFormSheet;
//            [self presentViewController:mcvc animated:YES completion:nil];
//        }
//        else
//        {
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
//                                                           message:NSLocalizedString(@"cannotUseEmail",nil)
//                                                          delegate:self
//                                                 cancelButtonTitle:@"OK"
//                                                 otherButtonTitles:nil];
//            [alert show];
//        }
//    }
//    else
//    {
//    }
//}

- (IBAction)sendEmailCancelButtonTouched:(UIButton *)sender
{
    //TODO:in next version, save pdf to document folder
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.dialogView.frame = CGRectMake(self.dialogView.frame.origin.x, [FSToolBox getApplicationFrameSize].height, self.dialogView.frame.size.width, self.dialogView.frame.size.height);
                         self.coverView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.coverView removeFromSuperview];
                     }
     ];
}

- (IBAction)sendEmailOKButtonTouched:(UIButton *)sender
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.dialogView.frame = CGRectMake(self.dialogView.frame.origin.x, [FSToolBox getApplicationFrameSize].height, self.dialogView.frame.size.width, self.dialogView.frame.size.height);
                         self.coverView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.coverView removeFromSuperview];
                         [self sendFileViaEmail];
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
@end
