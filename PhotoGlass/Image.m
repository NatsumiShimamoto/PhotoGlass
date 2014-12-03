//
//  Image.m
//  SandMemory
//
//  Created by 梶原 一葉 on 7/31/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

#import "Image.h"

@implementation Image

//画像にマスクをかける
+ (UIImage *)mask:(UIImage *)image
         withMask:(UIImage *)maskImage
{
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
}

//画像をリサイズする
+ (UIImage *)resize:(UIImage *)image
               rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    UIGraphicsEndImageContext();
    return resizedImage;
}

//画像ファイルを取得
+ (UIImage *)getUIImageFromResources:(NSString*)fileName ext:(NSString*)ext
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:ext];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    return img;
}


@end
