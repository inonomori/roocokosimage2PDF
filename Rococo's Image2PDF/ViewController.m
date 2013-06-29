//
//  ViewController.m
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 3/6/13.
//  Copyright (c) 2013 Nonomori. All rights reserved.
//

#import "ViewController.h"
#import "UIButton+FSUIButton.h"

@interface ViewController ()

@property (strong, nonatomic) NSString* fileName;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *picSelectionButton;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.fileName = @"roocoko.pdf";
//    [self.picSelectionButton setImage:[UIImage imageNamed:@"ButtonSelectPic_en_actived.png"] forState:UIControlStateHighlighted];
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
                                 
                                 QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
                                 imagePickerController.delegate = weakSelf;
                                 imagePickerController.allowsMultipleSelection = YES;
                                 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
                                 [weakSelf presentViewController:navigationController animated:YES completion:NULL];

                             }];
                     }];

    
//    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
//    imagePickerController.delegate = self;
//    imagePickerController.allowsMultipleSelection = YES;
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
//    [self presentViewController:navigationController animated:YES completion:NULL];
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

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    NSArray *mediaInfoArray = (NSArray *)info;
    
    [WQPDFManager WQCreatePDFFileWithSrc2:mediaInfoArray toDestFile:self.fileName withPassword:nil];

    NSLog(@"Selected %d photos", mediaInfoArray.count);
    
    [self dismissViewControllerAnimated:YES completion:NULL];
        
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"emailActionSheetTitle", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    
    [actionSheet showInView:self.view];  
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark actionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) //yes button
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
    else
    {
    }
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
