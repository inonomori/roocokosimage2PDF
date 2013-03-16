//
//  ViewController.m
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 3/6/13.
//  Copyright (c) 2013 Nonomori. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize selectPicButton = _selectPicButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)selectPics:(UIButton *)sender
{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    NSArray *mediaInfoArray = (NSArray *)info;
        
    [WQPDFManager WQCreatePDFFileWithSrc2:mediaInfoArray toDestFile:@"roocoko.pdf" withPassword:nil];
    
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
    NSLog(@"Cancelled");
    
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
            [mcvc addAttachmentData:[NSData dataWithContentsOfFile:[WQPDFManager pdfDestPathTmp:@"roocoko.pdf"]] mimeType:@"application/pdf" fileName:@"attachment.pdf"];
            
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
