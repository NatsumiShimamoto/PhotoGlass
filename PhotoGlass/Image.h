//
//  Image.h
//  SandMemory
//
//  Created by 梶原 一葉 on 7/31/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Image : UIImage

+ (UIImage *)mask:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIImage *)resize:(UIImage *)image rect:(CGRect)rect;
+ (UIImage *)getUIImageFromResources:(NSString*)fileName ext:(NSString*)ext;


@end
