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
        
    }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
        back = [UIImage imageNamed:@"sandglass_iPad.png"];
        backView = [[UIImageView alloc] initWithImage:back];
        backView.frame = CGRectMake(0, 0, 768, 1024);
    }
    
    
    //gifアニメーション
    UIImage *sunaImage = [UIImage animatedGIFNamed:@"砂"];
    sunaImageView = [[UIImageView alloc] initWithImage:sunaImage];
    sunaImageView.frame = CGRectMake(158, 275, 5, 128);
    
    [self.view addSubview:backView];
    [self.view addSubview:sunaImageView];
    
    //端末回転通知の開始
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
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
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"はじめまして。あなたの青春がもっと輝くようなお手伝いをします。"},
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"写真アルバムに「PhotoGlass」というアルバムが出来ているはずです。そこにモザイクアートにしたい写真をたくさんいれてください。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{35.0f,10.0f},{250.0f,460.0f}}], @"caption": @"この砂時計が、これからあなたのパートナーです。あなたが大切にしたい時間砂が落ち続けます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{40.0f,370.0f},{246.0f,100.0f}}], @"caption": @"これから撮った写真は、ここに溜まっていきます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"楽しかったあの瞬間に5りたい、と思った時はiPhoneをひっくり返してみてください。(iPhoneの縦向きロックをOFFにしてください)"}
                           ];
            
        }else if([[UIScreen mainScreen] bounds].size.height==568){ //iPhone5,5s,iPod
            coachMarks = @[
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"はじめまして。あなたの青春がもっと輝くようなお手伝いをします。"},
                            @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"写真アルバムに「PhotoGlass」というアルバムが出来ているはずです。そこにモザイクアートにしたい写真をたくさんいれてください。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{35.0f,10.0f},{250.0f,550.0f}}], @"caption": @"この砂時計が、これからあなたのパートナーです。あなたが大切にしたい時間砂が落ち続けます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{40.0f,378.0f},{246.0f,180.0f}}], @"caption": @"これから撮った写真は、ここに溜まっていきます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"楽しかったあの瞬間に戻りたい、と思った時はiPhoneをひっくり返してみてください。(iPhoneの縦向きロックをOFFにしてください)"}
                           ];
            
        }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
            coachMarks = @[
                           @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"はじめまして。あなたの青春がもっと輝くようなお手伝いをします。"},
                            @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"写真アルバムに「PhotoGlass」というアルバムが出来ているはずです。そこにモザイクアートにしたい写真をたくさんいれてください。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{35.0f,15.0f},{250.0f,550.0f}}], @"caption": @"この砂時計が、これからあなたのパートナーです。あなたが大切にしたい時間砂が落ち続けます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{40.0f,378.0f},{246.0f,180.0f}}], @"caption": @"これから撮った写真は、ここに溜まっていきます。"},
                           @{@"rect": [NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"楽しかったあの瞬間に戻りたい、と思った時はiPhoneをひっくり返してみてください。(iPhoneの縦向きロックをOFFにしてください)"}
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
    
    
    [picImgViewArray removeAllObjects];
    
    /* --- 写真 --- */
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         NSMutableArray *array = [[NSMutableArray alloc] init];
         
         //NSLog(@"number %d",(int)[group numberOfAssets]);
         //NSLog(@"group is %@",group);
         //[[self.view subviews]
         //makeObjectsPerformSelector:@selector(removeFromSuperview)];
         
         if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"])
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]]; //全部の写真とってくる(movieはない)
             //__block int f = 0;
             //NSMutableArray *array = [[NSMutableArray alloc] init];
             
             
             /*
              int p = ([group numberOfAssets]-38);
              if(p < 0){
              p = 0;
              }
              */
             //for(; p < [group numberOfAssets];p++)
             
             for(int p = [group numberOfAssets]-1;p >= [group numberOfAssets]-38 && p>=0; p--)
                 
                 //[group numberOfAssets]は個数、pは順番(0から始まる)→0が一番古い写真
             {
                 NSLog(@"p is %d",p);
                 /*
                  int m = (int)[group numberOfAssets]-38; // 表示されない最大index
                  int p_ = m+38-(p-m)-1;
                  [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:p_]
                  */
                 [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:p]
                                         options:0
                                      usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
                  {
                      assetDate = [result valueForProperty:ALAssetPropertyDate]; //メタデータの中の日付のみ取得
                      
                      NSTimeInterval  since = [assetDate timeIntervalSinceDate:begin]; //現在時刻からbeginまでの秒数
                      
                      //NSLog(@"result =============== %@",result);
                      //NSLog(@"メタデータ-------%@",[[result defaultRepresentation] metadata]);
                      
                      if(since/(60*60*24) > -10){
                          
                          //NSLog(@"since is %f",since/(60*60*24));
                          
                          if (nil != result) {
                              
                              //NSArray *array = [[NSArray alloc] init];
                              //NSLog(@"%d",(int)[group numberOfAssets]);
                              
                              
                              ALAssetRepresentation *assetRespresentation = [result defaultRepresentation];
                              
                              UIImage *picImg = [UIImage imageWithCGImage:[assetRespresentation fullScreenImage]]; //フルスクリーンサイズの画像をpicImgにいれる
                              
                              
                              
                              int i = (int)[group numberOfAssets]-p-1; //最新の写真が0
                              //NSMutableArray *array = [[NSMutableArray alloc] init];
                              //[array addObject:[NSNumber numberWithInteger:i]];
                              [array addObject:[NSNumber numberWithInteger:i]];
                              
                              NSLog(@"----------------あ%d",i);
                              //NSLog(@"配列の数　%d",(int)[array count]);
                              
                              
                              int x = 0; //x座標
                              int y = 0;
                              
                              double n = pow(-1, i);  //-1をi乗した数をresultにいれる
                              
                              if([[UIScreen mainScreen] bounds].size.height==480 || [[UIScreen mainScreen] bounds].size.height==568){
                                  /* --- iPhone4,4s,iPod Touch第4世代またはiPhone5,5S --- */
                                  
                                  if(i==0){ //１段目真ん中
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 513, 24, 24)];
                                      
                                      NSLog(@"i %d",i);
                                  }
                                  
                                  
                                  else if(0<i && i<=4){ //１段目４つ
                                      for (i = (int)[group numberOfAssets]-p-6; i <=(int)[group numberOfAssets]-p-6; i++)
                                      {
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          NSLog(@"おーい");
                                          x = 148 +24 *(i/2 + i%2)*n;
                                          y = 516+(i-1)/2*6;
                                          NSLog(@"x is %d",x);
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  else if(4<i && i<=6){ //１段目端(2)２つ
                                      for (i = (int)[group numberOfAssets]-p-1; i <=(int)[group numberOfAssets]-p-1; i++)
                                      {
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          NSLog(@"おーい");
                                          x = 148 +23 *(i/2 + i%2)*n;
                                          y = 480+(i-1)/2*6;
                                          NSLog(@"x is %d",x);
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  
                                  else if(6<i && i<=10){ //２段目４つ
                                      for (i = (int)[group numberOfAssets]-p-8; i <=(int)[group numberOfAssets]-p-8; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 136 +24 *(i/2 + i%2)*n;
                                          y = 489-i/2*5;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  
                                  else if(i==11){ //３段目真ん中
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 468, 24, 24)];
                                      
                                      NSLog(@"i %d",i);
                                  }
                                  
                                  
                                  
                                  else if(11<i && i<=13){ //２段目端(2)２つ
                                      for (i = (int)[group numberOfAssets]-p-8; i <=(int)[group numberOfAssets]-p-8; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +19 *(i/2 + i%2)*n;
                                          y = 471;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  else if(13<i && i<=15){ //３段目中２つ
                                      for (i = (int)[group numberOfAssets]-p-14; i <=(int)[group numberOfAssets]-p-14; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +23 *(i/2 + i%2)*n;
                                          y = 463;
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  else if(15<i && i<=17){ //１段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-10; i <=(int)[group numberOfAssets]-p-10; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +22 *(i/2 + i%2)*n;
                                          y = 477;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  
                                  
                                  
                                  
                                  else if(17<i && i<=19){ //４段目真ん中２つ
                                      for (i = (int)[group numberOfAssets]-p-19; i <=(int)[group numberOfAssets]-p-19; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 160 +24 *(i/2 + i%2)*n;
                                          y = 442;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  else if(19<i && i<=21){ //３段目端(2)２つ
                                      for (i = (int)[group numberOfAssets]-p-18; i <=(int)[group numberOfAssets]-p-18; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +22 *(i/2 + i%2)*n;
                                          y = 451;
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  else if(i==22){ //５段目真ん中
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 421.5, 24, 24)];
                                      
                                      NSLog(@"i %d",i);
                                  }
                                  
                                  else if(22<i && i<=24){ //２段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-17; i <=(int)[group numberOfAssets]-p-17; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +19 *(i/2 + i%2)*n;
                                          y = 456;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  else if(24<i && i<=26){ //４段目中２つ
                                      for (i = (int)[group numberOfAssets]-p-24; i <=(int)[group numberOfAssets]-p-24; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 137 +22 *(i/2 + i%2)*n;
                                          y = 430;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  else if(26<i && i<=28){ //３段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-23; i <=(int)[group numberOfAssets]-p-23; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +21 *(i/2 + i%2)*n;
                                          y = 436.5;
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  else if(28<i && i<=30){ //２段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-21; i <=(int)[group numberOfAssets]-p-21; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +18 *(i/2 + i%2)*n;
                                          y = 437;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  
                                  
                                  else if(30<i && i<=32){ //５段目中２つ
                                      for (i = (int)[group numberOfAssets]-p-31; i <=(int)[group numberOfAssets]-p-31; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +21 *(i/2 + i%2)*n;
                                          y = 409.5;
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  else if(i==33){ //てっぺん（６段目）
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(148, 398, 24, 24)];
                                      
                                      NSLog(@"i %d",i);
                                  }
                                  
                                  else if(33<i && i<=35){ //４段目端
                                      for (i = (int)[group numberOfAssets]-p-32; i <=(int)[group numberOfAssets]-p-32; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +26 *(i/2 + i%2)*n;
                                          y = 415;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  else if(35<i && i<=37){ //３段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-30; i <=(int)[group numberOfAssets]-p-30; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +19 *(i/2 + i%2)*n;
                                          y = 416;
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 24, 24)];
                                      }
                                  }
                                  
                                  
                                  
                                  
                                  
                              }else if([[UIScreen mainScreen] bounds].size.height==1024){
                                  
                                  /* --- iPad --- */
                                  
                                  if(i==0){ //１段目真ん中
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(374, 900, 40, 40)];
                                      
                                      NSLog(@"i %d",i);
                                  }
                                  
                                  
                                  else if(0<i && i<=4){ //１段目４つ
                                      for (i = (int)[group numberOfAssets]-p-6; i <=(int)[group numberOfAssets]-p-6; i++)
                                      {
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          NSLog(@"おーい");
                                          x = 374 +40 *(i/2 + i%2)*n;
                                          y = 900+(i-1)/2*6;
                                          NSLog(@"x is %d",x);
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  else if(4<i && i<=6){ //１段目端(2)２つ
                                      for (i = (int)[group numberOfAssets]-p-1; i <=(int)[group numberOfAssets]-p-1; i++)
                                      {
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          NSLog(@"おーい");
                                          x = 374 +40 *(i/2 + i%2)*n;
                                          y = 860+(i-1)/2*6;
                                          NSLog(@"x is %d",x);
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  
                                  else if(6<i && i<=10){ //２段目４つ
                                      for (i = (int)[group numberOfAssets]-p-8; i <=(int)[group numberOfAssets]-p-8; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 354 +40 *(i/2 + i%2)*n;
                                          y = 860-i/2*5;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  
                                  else if(i==11){ //３段目真ん中
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(374, 826, 40, 40)];
                                      
                                      NSLog(@"i %d",i);
                                  }
                                  
                                  
                                  
                                  else if(11<i && i<=13){ //２段目端(2)２つ
                                      for (i = (int)[group numberOfAssets]-p-8; i <=(int)[group numberOfAssets]-p-8; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +33 *(i/2 + i%2)*n;
                                          y = 837;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  else if(13<i && i<=15){ //３段目中２つ
                                      for (i = (int)[group numberOfAssets]-p-14; i <=(int)[group numberOfAssets]-p-14; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +40 *(i/2 + i%2)*n;
                                          y = 815;
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  else if(15<i && i<=17){ //１段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-10; i <=(int)[group numberOfAssets]-p-10; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +36 *(i/2 + i%2)*n;
                                          y = 840;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  
                                  
                                  
                                  
                                  else if(17<i && i<=19){ //４段目真ん中２つ
                                      for (i = (int)[group numberOfAssets]-p-19; i <=(int)[group numberOfAssets]-p-19; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 394 +40 *(i/2 + i%2)*n;
                                          y = 780;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  else if(19<i && i<=21){ //３段目端(2)２つ
                                      for (i = (int)[group numberOfAssets]-p-18; i <=(int)[group numberOfAssets]-p-18; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +40 *(i/2 + i%2)*n;
                                          y = 800;
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  else if(i==22){ //５段目真ん中
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(374, 745, 40, 40)];
                                      
                                      NSLog(@"i %d",i);
                                  }
                                  
                                  else if(22<i && i<=24){ //２段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-17; i <=(int)[group numberOfAssets]-p-17; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +31 *(i/2 + i%2)*n;
                                          y = 803;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  else if(24<i && i<=26){ //４段目中２つ
                                      for (i = (int)[group numberOfAssets]-p-24; i <=(int)[group numberOfAssets]-p-24; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 354 +39 *(i/2 + i%2)*n;
                                          y = 765;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  else if(26<i && i<=28){ //３段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-23; i <=(int)[group numberOfAssets]-p-23; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +35 *(i/2 + i%2)*n;
                                          y = 768;
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  else if(28<i && i<=30){ //２段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-21; i <=(int)[group numberOfAssets]-p-21; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +30 *(i/2 + i%2)*n;
                                          y = 770;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  
                                  
                                  else if(30<i && i<=32){ //５段目中２つ
                                      for (i = (int)[group numberOfAssets]-p-31; i <=(int)[group numberOfAssets]-p-31; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +40 *(i/2 + i%2)*n;
                                          y = 728;
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  else if(i==33){ //てっぺん（６段目）
                                      picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(374, 703, 40, 40)];
                                      
                                      NSLog(@"i %d",i);
                                  }
                                  
                                  else if(33<i && i<=35){ //４段目端
                                      for (i = (int)[group numberOfAssets]-p-32; i <=(int)[group numberOfAssets]-p-32; i++)
                                      {
                                          
                                          NSLog(@"ww %d",(int)[group numberOfAssets]);
                                          NSLog(@"p %d",p);
                                          NSLog(@"i %d",i);
                                          
                                          x = 148 +400 *(i/2 + i%2)*n;
                                          y = 70;
                                          NSLog(@"y %d",y);
                                          
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                                  
                                  else if(35<i && i<=37){ //３段目端(1)２つ
                                      for (i = (int)[group numberOfAssets]-p-30; i <=(int)[group numberOfAssets]-p-30; i++)
                                      {
                                          NSLog(@"i %d",i);
                                          
                                          x = 374 +32 *(i/2 + i%2)*n;
                                          y = 735;
                                          //[array addObject:[NSNumber numberWithInteger:x]];
                                          picImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
                                      }
                                  }
                                  
                              }
                              
                              //TODO:image
                              picImgView.image = picImg;
                              
                              [self.view addSubview:picImgView];
                              [self picSetting];
                              
                              [self.view sendSubviewToBack:picImgView];
                              [self.view sendSubviewToBack:backView];
                              
                              
                              
                          }
                      }
                      /*else{
                       f = 1;
                       //NSLog(@"表示されない");
                       }
                       */
                  }
                  ];
                 
                 *stop = NO;
                 
             }
         }
     }failureBlock:^(NSError *error) {
         //NSLog(@"error: %@", error);
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
- (void)didRotate:(NSNotification *)notification
{
    UIDeviceOrientation orientation = (UIDeviceOrientation)[[notification object] orientation];
    
    if (orientation==UIDeviceOrientationPortraitUpsideDown) {
        _orientation = @"縦(上下逆)";
        
        NSLog(@"がめんせんいー");
        mosaicViewController *mosaicViewViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mosaic"];
        mosaicViewViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:mosaicViewViewController animated:YES completion:nil];
        
        
        
    }else if (orientation == UIDeviceOrientationPortrait) {
        _orientation = @"縦";
        
    }
    
    
}

- (BOOL)shouldAutorotate
{
    return YES;//回転許可
}

//回転する方向の指定
- (NSUInteger)supportedInterfaceOrientations
{
    //全方位回転
    //return UIInterfaceOrientationMaskAll;
    ////Portrait(HomeButtonが下)のみ
    return UIInterfaceOrientationMaskPortrait;
    
}

@end
