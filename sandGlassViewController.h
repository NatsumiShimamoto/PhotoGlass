//
//  sandGlassViewController.h
//  PhotoGlass
//
//  Created by 梶原 一葉 on 9/3/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "mosaicViewController.h"
#import "WSCoachMarksView.h"



@interface sandGlassViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAccelerometerDelegate>{


    
    UIImage *back;
    UIImage *suna;
    UIImage *upsand;
    
    UIImageView *backView;
    UIImageView *picImgView;
    UIImageView *sunaView;
    UIImageView *sunaImageView;
    UIImageView *sunaupImageView;
    UIImageView *upsandView;
    
    NSDate *assetDate;
    
    NSInteger assetYear;
    NSInteger assetMonth;
    NSInteger assetDay;
    NSInteger nowYear;
    NSInteger nowMonth;
    NSInteger nowDay;
    
    NSString *AlbumSandName;
    NSString *_AlbumName;
    NSString *_orientation;
    NSString *_albumWasFound;
    UIImagePickerController *_pickerController;
    
    ALAssetsLibrary *_library;
    
    NSURL *_groupURL;
  
    NSArray *coachMarks;
    WSCoachMarksView *coachMarksView;
    
}

@end
