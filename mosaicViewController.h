//
//  mosaicViewController.h
//  PhotoGlass
//
//  Created by 梶原 一葉 on 9/3/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

#import "Image.h"
#import "sandGlassViewController.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AudioToolbox/AudioServices.h>
#import "WSCoachMarksView.h"


@interface mosaicViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    
    IBOutlet UIImageView *imgView;//モザイクアートの元の画像
    
    UIButton *backButton;
    UIButton *facebookButton;
    UIButton *lineButton;
    UIButton *twitterButton;
    
    UIImage *savedImage;
    UIImage *captureImg;
    UIImage *shake;
    UIView *mozaikuView;

    UIImageView *shakeImageView;
    
    ALAssetsLibrary *library;//カメラロールから画像を取得する
    NSURL *groupURL;
    NSString *AlbumName;//カメラロールの、どのフォルダから取得するか
    NSMutableArray *AlAssetsArr;//カメラロールの画像の配列
    NSMutableArray *cameraArr;//カメラロールの画像の色情報の配列
    NSMutableArray *pixelArr;//モザイクアートの元画像の、各ピクセルの色情報の配列

    NSData *data;
    
    NSArray *coachMarks;
    WSCoachMarksView *coachMarksView;
}


@end
