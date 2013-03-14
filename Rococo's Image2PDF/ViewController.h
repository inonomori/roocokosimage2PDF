//
//  ViewController.h
//  Rococo's Image2PDF
//
//  Created by Zhefu Wang on 3/6/13.
//  Copyright (c) 2013 Nonomori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"
#import "WQPDFManager.h"




@interface ViewController : UIViewController <QBImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *selectPicButton;

@end
