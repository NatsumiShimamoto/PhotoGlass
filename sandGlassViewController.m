//
//  sandGlassViewController.m
//  PhotoGlass
//
//  Created by 梶原 一葉 on 9/3/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

//一番新しいやつうううういやほおおおおお

#import <QuartzCore/QuartzCore.h>
#import "sandGlassViewController.h"
#import "Image.h"
#import "mosaicViewController.h"
#import "UIImage+GIF.h"
#import "WSCoachMarksView.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"

@interface sandGlassViewController ()
@end

@implementation sandGlassViewController
{
    NSMutableArray *picImgViewArray;
}
-(id)init
{
    picImgViewArray = [NSMutableArray array];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeImgParts];
    
    if([[UIScreen mainScreen] bounds].size.height==480){ //iPhone4,4s,iPod Touch第4世代
        back = [UIImage imageNamed:@"sandglass_4.png"];
        backView = [[UIImageView alloc] initWithImage:back];
        backView.frame = CGRectMake(0, 0, 320, 480);
        
    }else if([[UIScreen mainScreen] bounds].size.height==568){ //iPhone5,5s,iPod Touch第5世代
        back = [UIImage imageNamed:@"sandglass.png"];
        backView = [[UIImageView alloc] initWithImage:back];
        backView.frame = CGRectMake(0, 0, 320, 568);
        
       /* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(300, 500, 50, 50);
        [button setTitle:@"押してね" forState:UIControlStateNormal];
    
        */
    }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
        back = [UIImage imageNamed:@"sandglass_iPad.png"];
        backView = [[UIImageView alloc] initWithImage:back];
        backView.frame = CGRectMake(0, 0, 768, 1024);
    }
    
    //[button addTarget:self action:@selector(buttonPushed)forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:button];

    
    //gifアニメーション
    UIImage *sunaImage = [UIImage animatedGIFNamed:@"砂"];
    sunaImageView = [[UIImageView alloc] initWithImage:sunaImage];
    sunaImageView.frame = CGRectMake(158, 275, 5, 128);
    
    [self.view addSubview:backView];
    [self.view addSubview:sunaImageView];
    
    
    
    
    //UIImagePickerController
    _pickerController =[[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){_pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;}
    _pickerController.delegate = self;
    _pickerController.allowsEditing = YES;
    
    _AlbumName = @"PhotoGlass";
    _albumWasFound = FALSE;
    
    // Weak 参照を持つ
    __weak typeof(self) weakSelf = self;
    _library = [[ALAssetsLibrary alloc] init];
    [_library addAssetsGroupAlbumWithName:_AlbumName
                              resultBlock: ^(ALAssetsGroup *group) {
                                  // アルバムが既に存在する場合、group には nil が入る
                                  
                                  if (group == nil) {
                                      return;
                                  }
                                  
                                  // Strong 参照させる（ブロックの最後まで値がキープされるようにするために）
                                  __strong typeof(self) strongSelf = weakSelf;
                                  
                                  strongSelf->_groupURL = [group valueForProperty:ALAssetsGroupPropertyURL];
                                  ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
                                  ELCImagePickerController *elcPickerController = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
                                  [albumController setParent:elcPickerController];
                                  
                                  [elcPickerController setImagePickerDelegate:self];
                                  
                                  
                                  [self presentViewController:elcPickerController animated:YES completion:nil];
                              }
                             failureBlock:nil];
    
    
    
    // コーチマークの設定内容配列を作成
    // コーチマークの表示済フラグ
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShown"];
    
    if (coachMarksShown == NO) {
        
        
        // コーチマーク毎にカットアウトの位置（CGRect）とキャプション（NSString）のディクショナリ
        //(CGRect){x,y},{width,height}}
        
        if([[UIScreen mainScreen] bounds].size.height==480){ //iPhone4,4s,iPod Touch第4世代
            coachMarks = @[
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"はじめまして。あなたの青春がもっと輝くためのお手伝いをします。"},
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"写真アルバムに「PhotoGlass」というアルバムが出来ているはずです。そこにモザイクアートにしたい写真をたくさんいれてください。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{35.0f,10.0f},{250.0f,460.0f}}], @"caption": @"この砂時計が、これからあなたのパートナーです。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{40.0f,370.0f},{246.0f,100.0f}}], @"caption": @"撮った写真は、ここに溜まっていきます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{40.0f,370.0f},{246.0f,100.0f}}], @"caption": @"写真をタップするとモザイクアートの制作スタートです！"}
                           ];
            
        }else if([[UIScreen mainScreen] bounds].size.height==568){ //iPhone5,5s,iPod
            coachMarks = @[
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"はじめまして。あなたの青春がもっと輝くようなお手伝いをします。"},
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"写真アルバムに「PhotoGlass」というアルバムが出来ているはずです。そこにモザイクアートにしたい写真をたくさんいれてください。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{35.0f,10.0f},{250.0f,550.0f}}], @"caption": @"この砂時計が、これからあなたのパートナーです。あなたが大切にしたい時間砂が落ち続けます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{40.0f,378.0f},{246.0f,180.0f}}], @"caption": @"これから撮った写真は、ここに溜まっていきます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{40.0f,378.0f},{246.0f,180.0f}}], @"caption": @"写真をタップするとモザイクアートの制作スタートです！"}
                           ];
            
        }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
            coachMarks = @[
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"はじめまして。あなたの青春がもっと輝くようなお手伝いをします。"},
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"写真アルバムに「PhotoGlass」というアルバムが出来ているはずです。そこにモザイクアートにしたい写真をたくさんいれてください。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{140.0f,15.0f},{500.0f,1000.0f}}], @"caption": @"この砂時計が、これからあなたのパートナーです。あなたが大切にしたい時間砂が落ち続けます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{145.0f,675.0f},{500.0f,300.0f}}], @"caption": @"これからは、撮った写真がここに溜まっていきます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{145.0f,675.0f},{500.0f,300.0f}}], @"caption": @"写真をタップするとモザイクアートの制作スタートです！"}
                           ];
        }
        
        
        
        
        
        // WSCoachMarksViewオブジェクトの作成
        
        coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
        // 親ビューに追加
        [self.view addSubview:coachMarksView];
        // コーチマークを表示する
        [coachMarksView start];
    }
    
}



/* ---- PhotoGlassフォルダに画像追加する ---- */
//きちんと選んだとき
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([info count] < 1) {
        return;
    }
    
    UIImage *image;
    for (NSMutableDictionary *item in info) {
        image = [item objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    
}
//キャンセルしたとき
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
}

-(void)makeImgParts{
    
    /* --- 時間 --- */
    NSDate *begin =[[NSUserDefaults standardUserDefaults] objectForKey:@"begin"];
    
    if(begin== nil){
        begin = [NSDate date]; //使い始めた日にちをbeginにいれる
        [[NSUserDefaults standardUserDefaults] setObject:begin forKey:@"begin"]; //開始時刻を保存
    }
    
    // 削除する
    for (int i = (int)picImgViewArray.count - 1; i >= 0; i--) {
        [picImgViewArray[i] removeFromSuperview];
    }
    
    NSMutableArray *mapArray = [@[] mutableCopy];
    //mapArrayは[番号,X座標,Y座標]って入ってて、それぞれ[0,1,2]で呼び出せる
    
    NSString *filePath;
    float imgSize = 0.0;
    if([[UIScreen mainScreen] bounds].size.height==480 || [[UIScreen mainScreen] bounds].size.height==568){
        /* --- iPhone4,4s,iPod Touch第4世代またはiPhone5,5S --- */
        filePath = [[NSBundle mainBundle] pathForResource:@"iphonemap" ofType:@"txt"];
        //iphonemap.txtを読み込む
        imgSize = 24;
        
    }else if([[UIScreen mainScreen] bounds].size.height==1024){
        /* --- iPad --- */
        filePath = [[NSBundle mainBundle] pathForResource:@"ipadmap" ofType:@"txt"];
        //ipad.txtを読み込む
        imgSize = 40;
    }
    
    NSString *text = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:nil error:nil]; //filePathで読み込んだ文字列をtextに入れる
    //
    for(NSString *str in [text componentsSeparatedByString:@"\n"]){//.txtの文字列を改行(\n)ごとに区切る
        [mapArray addObject:[str componentsSeparatedByString:@","]];//改行で区切られた文字列をカンマごとに区切る
    }
    NSLog(@"%@",mapArray);
    
    
    
    [picImgViewArray removeAllObjects];
    
    /* --- 写真 --- */
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    __block int idx = 0;
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         NSMutableArray *array = [[NSMutableArray alloc] init];
         
         if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"])
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]]; //全部の写真とってくる(movieはない)
             
             
             
             for(int p = [group numberOfAssets]-1;p >= [group numberOfAssets]-38 && p>=0; p--)
                 
                 //[group numberOfAssets]は個数、pは順番(0から始まる)→0が一番古い写真
             {
                 NSLog(@"p is %d",p);
                 
                 [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:p]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                  {
                      assetDate = [result valueForProperty:ALAssetPropertyDate]; //メタデータの中の日付のみ取得
                      
                      NSTimeInterval  since = [assetDate timeIntervalSinceDate:begin]; //現在時刻からbeginまでの秒数
                      
                      if(since/(60*60*24) > -1000){
                          
                          if (nil != result) {
                              
                              ALAssetRepresentation *assetRespresentation = [result defaultRepresentation];
                              
                              UIImage *picImg = [UIImage imageWithCGImage:[assetRespresentation fullScreenImage]]; //フルスクリーンサイズの画像をpicImgにいれる
                              
                              [array  insertObject:[NSNumber numberWithInteger:idx] atIndex:0];
                              
                              if(idx < 36){
                                  picImgView = [[UIImageView alloc] initWithFrame:CGRectMake([mapArray[idx][1] floatValue], [mapArray[idx][2] floatValue], imgSize, imgSize)];
                                  //mapArrayのidx番目のX座標,mapArrayのidx番目のY座標,imgSize,imgSize
                                  
                              }
                              
                              //TODO:image
                              picImgView.image = picImg;
                              
                              [self.view addSubview:picImgView];
                              [self picSetting];
                              
                              [self.view sendSubviewToBack:picImgView];
                              [self.view sendSubviewToBack:backView];
                              
                              picImgView.userInteractionEnabled = YES;
                              picImgView.tag = 1;
                              
                              idx ++;
                              NSLog(@"idx is %d",idx);
                          }
                      }
                      
                  }
                  ];
                 
                 *stop = NO;
                 
             }
         }
     }failureBlock:^(NSError *error) {
     }
     ];
    
}

-(void)picSetting
{
    /* 画像の設定 */
    picImgView.contentMode = UIViewContentModeScaleAspectFill;
    picImgView.clipsToBounds = YES;
    
    CALayer *layer = picImgView.layer;
    layer.masksToBounds = YES;
    
    
    
    if([[UIScreen mainScreen] bounds].size.height==480||[[UIScreen mainScreen] bounds].size.height==568){
        layer.cornerRadius = 12.0f;
        
        
    }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
        layer.cornerRadius = 20.0f;
    }
    
    
    
    [picImgView.layer setBorderWidth:1.0];
    [picImgView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
}


//端末の向きの取得
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    mosaicViewController *mosaicViewViewController;
    
    switch (touch.view.tag) {
        case 1:
            NSLog(@"がめんせんいー");
        mosaicViewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mosaic"];
        mosaicViewViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
        [self presentViewController:mosaicViewViewController animated:YES completion:nil];
            
            break;
            
        default:
            break;
    }
    
    
}


@end
