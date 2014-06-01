//
//  WQPDFManager.h
//  wqphototopdf
//
//  Created by Wu Qian on 12-10-22.
//
//  How to use
//  NSData *data = [NSData dataWithContentsOfFile:your_image_path];
//  NSString *pdfname = @"photoToPDF.pdf";
//  [WQPDFManager WQCreatePDFFileWithSrc:data toDestFile:pdfname withPassword:nil];

#import <Foundation/Foundation.h>

@interface WQPDFManager : NSObject

/**
 *	@brief	创建PDF文件
 *
 *	@param 	imgData         NSData型   照片数据
 *	@param 	destFileName 	NSString型 生成的PDF文件名
 *	@param 	pw              NSString型 要设定的密码
 */

+ (void)WQCreatePDFFileWithSrc:(NSArray *)mediaInfoArray
                     toDestFile:(NSString *)destFileName
                   withPassword:(NSString *)pw;

/**
 *	@brief	抛出pdf文件存放地址
 *
 *	@param 	filename 	NSString型 文件名
 *
 *	@return	NSString型 地址
 */
+(NSString *)pdfDestPathDocuments:(NSString *)filename;
+(NSString *)pdfDestPathTmp:(NSString *)filename;

@end