//
//  WQPDFManager.m
//  wqphototopdf
//
//  Created by Wu Qian on 12-10-22.
//
//

#import "WQPDFManager.h"

#define PAGE_WIDTH 612
#define PAGE_HEIGHT 792

@implementation WQPDFManager

void WQDrawContent(CGContextRef myContext,
                   CFDataRef data,
                   CGRect rect)
{
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(data);
    CGImageRef image = CGImageCreateWithJPEGDataProvider(dataProvider,
                                                         NULL,
                                                         NO,
                                                         kCGRenderingIntentDefault);
    CGContextDrawImage(myContext, rect, image);
    
    CGDataProviderRelease(dataProvider);
    CGImageRelease(image);
}

+ (NSString *)pdfDestPathDocuments:(NSString *)filename
{
    return [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],filename];    
}

+ (NSString *)pdfDestPathTmp:(NSString *)filename
{
    return [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),filename];
}


void MyCreatePDFFile2 (NSArray* mediaInfoArray,
                      /*CGRect pageRect,*/
                      const char *filepath,
                      CFStringRef password)
{
    CGContextRef pdfContext;
    CFStringRef path;
    CFURLRef url;
    CFDataRef boxData = NULL;
    CFMutableDictionaryRef myDictionary = NULL;
    CFMutableDictionaryRef pageDictionary = NULL;
    
    path = CFStringCreateWithCString (NULL, filepath,
                                      kCFStringEncodingUTF8);
    url = CFURLCreateWithFileSystemPath (NULL, path,
                                         kCFURLPOSIXPathStyle, 0);
    CFRelease (path);
    myDictionary = CFDictionaryCreateMutable(NULL,
                                             0,
                                             &kCFTypeDictionaryKeyCallBacks,
                                             &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(myDictionary,
                         kCGPDFContextTitle,
                         CFSTR("Photo from iPrivate Album"));
    CFDictionarySetValue(myDictionary,
                         kCGPDFContextCreator,
                         CFSTR("iPrivate Album"));
    if (password) {
        CFDictionarySetValue(myDictionary, kCGPDFContextUserPassword, password);
        CFDictionarySetValue(myDictionary, kCGPDFContextOwnerPassword, password);
    }
   
    CGRect pageRect = CGRectMake(0, 0, PAGE_WIDTH, PAGE_HEIGHT);
    pdfContext = CGPDFContextCreateWithURL (url, &pageRect, myDictionary);
    CFRelease(myDictionary);
    CFRelease(url);
    pageDictionary = CFDictionaryCreateMutable(NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    boxData = CFDataCreate(NULL,(const UInt8 *)&pageRect, sizeof (CGRect));
    CFDictionarySetValue(pageDictionary, kCGPDFContextMediaBox, boxData);
    
    for (NSDictionary* iter in mediaInfoArray){
        UIImage *chosenImage = [iter objectForKey:UIImagePickerControllerOriginalImage];
        
        //resize image heret
        CGFloat imageScale=1;
        if (chosenImage.size.width > PAGE_WIDTH)
        {
            imageScale = PAGE_WIDTH/chosenImage.size.width;
        }
        if (chosenImage.size.height*imageScale > PAGE_HEIGHT)
        {
            imageScale = PAGE_HEIGHT/chosenImage.size.height;
        }
        UIGraphicsBeginImageContext(CGSizeMake(chosenImage.size.width * imageScale, chosenImage.size.height * imageScale));
        [chosenImage drawInRect:CGRectMake(0, 0, chosenImage.size.width * imageScale, chosenImage.size.height * imageScale)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //resize done
        
        NSData *data = UIImageJPEGRepresentation(scaledImage,0.8);
        CGRect rect = CGRectMake((pageRect.size.width - scaledImage.size.width)/2, (pageRect.size.height - scaledImage.size.height)/2, scaledImage.size.width, scaledImage.size.height);
        
        
        CFDataRef refData = (__bridge CFDataRef)data;
        
        CGPDFContextBeginPage (pdfContext, pageDictionary);
        WQDrawContent(pdfContext,refData,rect);
        CGPDFContextEndPage (pdfContext);
    }
    
    
    CGContextRelease (pdfContext);
    CFRelease(pageDictionary);
    CFRelease(boxData);
}

+ (void)WQCreatePDFFileWithSrc2:(NSArray *)mediaInfoArray
                     toDestFile:(NSString *)destFileName
                   withPassword:(NSString *)pw
{
    NSString *fileFullPath = [self pdfDestPathTmp:destFileName];
    const char *path = [fileFullPath UTF8String];
    CFStringRef password = (__bridge CFStringRef)pw;
    
    MyCreatePDFFile2(mediaInfoArray,/*rect,*/ path, password);
}
@end
