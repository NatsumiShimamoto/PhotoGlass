//
//  mosaicViewController.m
//  PhotoGlass
//
//  Created by 梶原 一葉 on 9/3/14.
//  Copyright (c) 2014 梶原 一葉. All rights reserved.
//

#import "mosaicViewController.h"
#import "AppDelegate.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <AudioToolbox/AudioToolbox.h>

#import "SVProgressHUD.h"


@interface mosaicViewController ()
{
    AppDelegate *delegate;
    
    BOOL isAlreadyFlick;
    
    // 追加した画像を一時的に保存しておくためのリスト
    NSMutableArray *imageViewList;
}
@end

@implementation mosaicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        imageViewList = [NSMutableArray array];
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
    
    // 前に保存してあった ImageView を Subview から取り除く。
    [imageViewList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [imageViewList removeAllObjects];
    // =========== iOSバージョンで、処理を分岐 ============
    // iOS Version
    NSString *iosVersion =
    [[[UIDevice currentDevice] systemVersion] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([iosVersion floatValue] < 6.0) { // iOSのバージョンが6.0以上でないときは、ボタンを隠す
        // Twitter,Facebook連携はiOS6.0以降
        facebookButton.hidden = YES;
        twitterButton.hidden = YES;
    }
    
    
    //変数の初期化
    AlAssetsArr = [NSMutableArray array];//カメラロール画像の配列
    cameraArr = [NSMutableArray array];//カメラロールの画像の色情報の配列
    pixelArr = [NSMutableArray array];//モザイクアートの元画像のピクセルの色情報の配列
    library = [[ALAssetsLibrary alloc] init];
    
    //カメラロールのフォルダ名
    AlbumName = @"PhotoGlass";
    
    
    
    
    // Do any additional setup after loading the view.
    
    delegate = [UIApplication sharedApplication].delegate;
    delegate.cameraFlag = NO;
    
    isAlreadyFlick = NO;
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if (!delegate.cameraFlag) {
        
        if([UIImagePickerController
            isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
           ){
            
            UIImagePickerController *ipc =
            [[UIImagePickerController alloc] init];  // 生成
            ipc.delegate = self;  // デリゲートを自分自身に設定
            ipc.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;  // 画像の取得先をカメラロールに設定
            ipc.allowsEditing = YES;  // 画像取得後編集する
            
            delegate.cameraFlag = YES;
            
            ipc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:ipc animated:YES completion:nil];
            
            // モーダルビューとしてカメラ画面を呼び出す
            
            
        }
        
    }
    NSLog(@"ああああ");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//画像が選択された時に呼ばれるデリゲートメソッド
-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{
    
    [self dismissModalViewControllerAnimated:YES];  // モーダルビューを閉じる
    //    UIImage *backblueView = [UIImage imageNamed:@"blueBack.png"];
    //    blueImageView= [[UIImageView alloc] initWithImage:backblueView];
    //    CGRect rect = CGRectMake(5, 38, 310, 482);
    //    blueImageView.frame = rect;
    //    [self.view addSubview:blueImageView];
    
    UIImage *shakeImage = [UIImage imageNamed:@"shakeView.png"];
    shakeImageView = [[UIImageView alloc] initWithImage:shakeImage];
    
    if([[UIScreen mainScreen] bounds].size.height==480){ //iPhone4,4s,iPod Touch第4世代
        CGRect shakeRect = CGRectMake(70, 415, 170, 51);
        shakeImageView.frame = shakeRect;
        
    }else if([[UIScreen mainScreen] bounds].size.height==568){ //iPhone5,5s,iPod Touch第5世代
        CGRect shakeRect = CGRectMake(40, 465, 240, 71);
        shakeImageView.frame = shakeRect;
        
    }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
        CGRect shakeRect = CGRectMake(270, 910, 260, 90);
        shakeImageView.frame = shakeRect;
    }
    
    
    
    [self.view addSubview:shakeImageView];
    
    imgView.image = image;//選択した画像に差し替える
    [self.view bringSubviewToFront:imgView];
    
    //枠線
    imgView.layer.borderWidth = 1.0f;
    //枠線の色
    imgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    
    
    
    // コーチマークの表示済フラグ
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShown"];
    if (coachMarksShown == NO) {
        // 表示済フラグに「YES」を設定、次回からはコーチマークを表示しない
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        // コーチマークを表示する
        // コーチマークの設定内容配列を作成
        // コーチマーク毎にカットアウトの位置（CGRect）とキャプション（NSString）のディクショナリ
        
        coachMarks = @[
                       @{@"rect":[NSValue valueWithCGRect:(CGRect){{0,0},{0,0}}], @"caption": @"選んだ写真をモザイクアートにするためにiPhoneを振ってください"}
                       ];
        
        
        
        
        
        // WSCoachMarksViewオブジェクトの作成
        
        coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
        // 親ビューに追加
        [self.view addSubview:coachMarksView];
        // コーチマークを表示する
        [coachMarksView start];
    }
    
    
    if (coachMarksShown) {
        NSLog(@"YES( ･ω･)");
    } else {
        NSLog(@"NO( ･ω･)");
    }
    
    
}

- (BOOL)shouldAutorotate
{
    return NO; // YES:自動回転する NO:自動回転しない
}


#pragma mark - キャンセルしたときに呼ばれるよ
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

//モザイクアートを作成する
-(void)makeMosaic{
    imgView.image = [Image resize:imgView.image rect:CGRectMake(0,0,40,40)];
    
    //モザイクアートの元画像の各ピクセルの色情報をpixelArrに格納する
    [self pixelRGB:imgView.image];
    //カメラロールから画像を読み取って、色情報を配列に格納して、格納後モザイクアートを作成する
    [self inputCamera];
    
    
}


//カメラロールから画像を読み取って、色情報を配列に格納して、格納後モザイクアートを作成する
-(void)inputCamera{
    
    //カメラロールから画像を取り出す
    [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               
                               //カメラロール内のすべてのアルバムが列挙される
                               if (group) {
                                   NSLog(@"おーーーい");
                                   //アルバム名がMosaicと同一だった時の処理
                                   if ([AlbumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
                                       
                                       //Mosaic内の画像を取得する
                                       ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                           
                                           if (result) {
                                               //画像をAlAssetsArrという配列に格納
                                               [AlAssetsArr addObject:result];
                                               
                                               //画像の色情報をcameraArrという配列に格納する
                                               UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                                               UIImage *sampleImage = [Image resize:image
                                                                               rect:CGRectMake(0, 0, 10, 10)];
                                               [cameraArr addObject:[self checkColor:sampleImage]];
                                               

                                           }else{
                                               //画像の格納が終了した時に呼ばれる
                                               //モザイクアートを作成する
                                               [self makeMozaiku];
                                               
                                                                                         }
                                           
                                       };
                                       
                                       //アルバム(group)からALAssetの取得
                                       [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                                   }
                               }
                               
                           } failureBlock:nil];
    
    
}

//画像の各ピクセル値を格納する
- (void)pixelRGB:(UIImage *)img
{
    // CGImageを取得する
    CGImageRef  imageRef = img.CGImage;
    
    // データプロバイダを取得する
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    // ビットマップデータを取得する
    CFDataRef dataRef = CGDataProviderCopyData(dataProvider);
    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(dataRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    UInt8 *pixelPtr;
    UInt8 r;
    UInt8 g;
    UInt8 b;
    
    // 画像全体を１ピクセルずつ走査する
    for (int checkX = 0; checkX < img.size.width; checkX++) {
        for (int checkY=0; checkY < img.size.height; checkY++) {
            // ピクセルのポインタを取得する
            pixelPtr = buffer + (int)(checkY) * bytesPerRow + (int)(checkX) * 4;
            
            // 色情報を取得する
            r = *(pixelPtr + 2);  // 赤
            g = *(pixelPtr + 1);  // 緑
            b = *(pixelPtr + 0);  // 青
            
            //NSLog(@"x:%d y:%d R:%d G:%d B:%d", checkX, checkY, r, g, b);
            //ピクセルの色情報を配列に格納する
            UIColor *color = [UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:1];
            [pixelArr addObject:color];
            
        }
    }
    CFRelease(dataRef);
    
}

//画像の平均RGB値を返す
- (UIColor *)checkColor:(UIImage *)img{
    CGImageRef  imageRef = img.CGImage;
    
    // データプロバイダを取得する
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    // ビットマップデータを取得する
    CFDataRef dataRef = CGDataProviderCopyData(dataProvider);
    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(dataRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    
    UInt8 *pixelPtr;
    UInt8 r;
    UInt8 g;
    UInt8 b;
    
    int red =0 ;
    int green = 0;
    int blue = 0;
    
    // 画像全体を１ピクセルずつ走査する
    for (int checkX = 0; checkX < img.size.width; checkX++) {
        for (int checkY=0; checkY < img.size.height; checkY++) {
            // ピクセルのポインタを取得する
            pixelPtr = buffer + (int)(checkY) * bytesPerRow + (int)(checkX) * 4;
            
            // 色情報を取得する
            r = *(pixelPtr + 2);  // 赤
            g = *(pixelPtr + 1);  // 緑
            b = *(pixelPtr + 0);  // 青
            red += r;
            green += g;
            blue += b;
        }
    }
    CFRelease(dataRef);
    
    int num = img.size.width * img.size.height;
    //NSLog(@"color red=%f green=%f blue=%f",(float)red/255.0/num,(float)green/255.0/num,(float)blue/255.0/num);
    //画像の平均RGBを返す
    UIColor *averageColor = [UIColor colorWithRed:(float)red/255.0/num green:(float)green/255.0/num blue:(float)blue/255.0/num alpha:1];
    return averageColor;
}


//モザイクアートのアルゴリズム
-(void)makeMozaiku{
    int imageWidth = imgView.image.size.width;//元画像の横のピクセル値
    int imageHeight = imgView.image.size.height;//元画像の縦のピクセル値
    int pixelSize = 320/imgView.image.size.width;//ピクセルの大きさ
    //各ピクセルを類似したカメラロールの画像に置き換える
    for (int i=0; i<imageWidth*imageHeight; i++) {
        
        NSLog(@"ふぉおおおおおお");
        float min_value = 999;
        
        NSLog(@"今=%d/%d",i+1,imageWidth*imageHeight);
        for (int j=0; j<[cameraArr count]; j++) {
            int x,y;
            UIColor *pixelColor = [pixelArr objectAtIndex:i];//ピクセルの色情報
            UIColor *cameraColor = [cameraArr objectAtIndex:j];//カメラロールの画像の色情報
            const CGFloat *pixelComponents = CGColorGetComponents(pixelColor.CGColor);
            const CGFloat *cameraComponents = CGColorGetComponents(cameraColor.CGColor);
            float r1 = pixelComponents[0];//ピクセルの赤
            float g1 = pixelComponents[1];//ピクセルの緑
            float b1 = pixelComponents[2];//ピクセルの青
            float r2 = cameraComponents[0];//カメラロールの赤
            float g2 = cameraComponents[1];//カメラロールの緑
            float b2 = cameraComponents[2];//カメラロールの青
            
            //ピクセルの色とカメラロールの色の差を計算する
            float diff = pow((r1-r2),2.0) + pow((g1-g2),2.0) + pow((b1-b2),2.0);
            //距離は↑ユークリッド距離↑、↓コサイン距離でも可↓
            //float diff = (r1*r2 + g1*g2 + b1*b2 )/ sqrt( r1*r1 + g1*g1 + b1*b1 ) /sqrt(r2*r2 + g2*g2 + b2*b2 );
            //画像を差し替える
            if (diff < min_value) {
                min_value = diff;
                //タイル上に並べるためのx、yの計算
                x = ((i / imageHeight) * pixelSize) ;
                y = ((i % imageWidth) * pixelSize) ;
                //NSLog(@"i=%d,x=%d,y=%d,diff=%f",i,x,y,diff);
                //ALAssetからサムネール画像を取得してUIImageに変換
                UIImage *image = [UIImage imageWithCGImage:[[AlAssetsArr objectAtIndex:j] thumbnail]];
                //表示させるためにUIImageViewを作成
                UIImageView *imageView = [[UIImageView alloc] init];
                //UIImageViewのサイズと位置を設定
                imageView.frame = CGRectMake(x+0,y+110 ,pixelSize,pixelSize);
                imageView.image = image;
                
                //画面に貼り付ける
                [self.view addSubview:imageView];
                
                // 後々取り除くために保存
                [imageViewList addObject:imageView];
                
               
            }
        }
        
    }
    
    // Cross Dissolve のアニメーションを加える。
    [UIView transitionWithView:self.view
                      duration:3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self save];
                    }
                    completion:nil];
    
    // Sub view がいくつあるか表示する
    NSLog(@"Number of subviews: %lu", (unsigned long)self.view.subviews.count);
    
}


- (UIImage *)captureView {
    
    UIGraphicsBeginImageContext(CGSizeMake(320, 320));
    //UIGraphicsBeginImageContext(CGRectMake(10, 48, 300, 300));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform affine = CGAffineTransformMakeTranslation(0,-110);
    CGContextConcatCTM(context, affine);
    [self.view.layer renderInContext:context];
    captureImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return captureImg;
}


-(void)save{
    ALAssetsLibrary *savelibrary = [[ALAssetsLibrary alloc] init];
    [savelibrary writeImageToSavedPhotosAlbum:[self captureView].CGImage
                                     metadata:nil
                              completionBlock:^(NSURL *assetURL, NSError *error){
                                  
                                  
                                  if(!error){
                                      NSLog(@"保存成功");
                                      [SVProgressHUD showSuccessWithStatus:@"保存成功!"];
                                  }
                                  
                                  
                              }
     
     ];
    
    
}

-(BOOL)canBecomeFirstResponder { return YES; }



#pragma mark - MotionBegan

//モーション開始時に実行
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
    if (isAlreadyFlick) {
        return;
    }
    
    NSLog(@"motionBegan");
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    //remove MaskView
    [self removeMarksView];
    shakeImageView.hidden = YES;
    
    [SVProgressHUD showWithStatus:@"作成中..." maskType:SVProgressHUDMaskTypeGradient];
    
    
    
    
    
    //[self makeMosaic];
    
    
    
    /* --- 戻るボタン --- */
    UIImage *backButtonImage = [UIImage imageNamed:@"yazirushi.png"];
    
    
    if([[UIScreen mainScreen] bounds].size.height==480){ //iPhone4,4s,iPod Touch第4世代
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 35, 35, 30)];
        
    }else if([[UIScreen mainScreen] bounds].size.height==568){ //iPhone5,5s,iPod Touch第5世代
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 52, 35, 30)];
        
    }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(16, 52, 35, 30)];
        
    }
    
    
    
    [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];  // 画像をセットする
    
    [backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    
    /* --- Twitter --- */
    UIImage *twButtonImage = [UIImage imageNamed:@"Twitter.png"];
    
    
    if([[UIScreen mainScreen] bounds].size.height==480){ //iPhone4,4s,iPod Touch第4世代
        twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 415, 50, 50)];
        
    }else if([[UIScreen mainScreen] bounds].size.height==568){ //iPhone5,5s,iPod Touch第5世代
        twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 469, 60, 60)];
        
    }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
        twitterButton = [[UIButton alloc] initWithFrame:CGRectMake(344, 914, 80, 80)];
        
    }
    
    [twitterButton setBackgroundImage:twButtonImage forState:UIControlStateNormal];  // 画像をセットする
    [twitterButton addTarget:self action:@selector(twitterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twitterButton];
    
    NSLog(@"tuitta");
    
    
    /* --- Facebook --- */
    UIImage *fbButtonImage = [UIImage imageNamed:@"Facebook.png"];
    
    
    if([[UIScreen mainScreen] bounds].size.height==480){ //iPhone4,4s,iPod Touch第4世代
        facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(38, 415, 50, 50)];

        
    }else if([[UIScreen mainScreen] bounds].size.height==568){ //iPhone5,5s,iPod Touch第5世代
        facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(38, 469, 60, 60)];
        
    }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
        facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(138, 914, 80, 80)];

    }
    
    [facebookButton setBackgroundImage:fbButtonImage forState:UIControlStateNormal];  // 画像をセットする
    
    [facebookButton addTarget:self action:@selector(facebookButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    
    /* --- LINE --- */
    UIImage *lnButtonImage = [UIImage imageNamed:@"LINE.png"];
    
    if([[UIScreen mainScreen] bounds].size.height==480){ //iPhone4,4s,iPod Touch第4世代
        lineButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 415, 50, 50)];

    }else if([[UIScreen mainScreen] bounds].size.height==568){ //iPhone5,5s,iPod Touch第5世代
         lineButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 469, 60, 60)];
        
    }else if([[UIScreen mainScreen] bounds].size.height==1024){ //iPad
         lineButton = [[UIButton alloc] initWithFrame:CGRectMake(550, 914, 80, 80)];
    }
    
        
    [lineButton setBackgroundImage:lnButtonImage forState:UIControlStateNormal];  // 画像をセットする
    
    [lineButton addTarget:self action:@selector(lineButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lineButton];
    
    isAlreadyFlick = YES;
    
}


-(void)backButton:(UIButton*)button{
    
    AlAssetsArr = [NSMutableArray array];//カメラロール画像の配列
    cameraArr = [NSMutableArray array];//カメラロールの画像の色情報の配列
    pixelArr = [NSMutableArray array];//モザイクアートの元画像のピクセルの色情報の配列
    library = [[ALAssetsLibrary alloc] init];
    //NSLog(@"初期化したよ");
    
    [self dismissViewControllerAnimated:YES completion:nil];
}




/* --- SNS連携 --- */

-(void)twitterButton:(UIButton*)button{
    //ServiceTypeをTwitterに設定
    
    NSString *serviceType = SLServiceTypeTwitter;
    //Twitterが利用可能かチェック
    if([SLComposeViewController isAvailableForServiceType:serviceType]){
        
        //SLComposeViewControllerを初期化・生成
        SLComposeViewController *twitterpostVC = [[SLComposeViewController alloc] init];
        
        //ServiceTypeをTwitterに設定
        twitterpostVC = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        //初期テキストの設定
        [twitterpostVC setInitialText:@"#PhotoGlass"];
        
        //画像の追加
        [twitterpostVC addImage:captureImg];
        
        //投稿の可否         //↓ツイート編集終了時
        [twitterpostVC setCompletionHandler:^(SLComposeViewControllerResult result){
            if(result == SLComposeViewControllerResultDone){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"投稿を完了しました"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"投稿できませんでした"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
         ];
        
        //SLComposeViewControllerのViewを表示
        [self presentViewController:twitterpostVC animated:YES completion:nil];
        
    }
}



-(void)facebookButton:(UIButton*)button{
    
    SLComposeViewController *facebookPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    NSString* postContent = [NSString stringWithFormat:@"PhotoGlassでモザイクアートを作りました！"];
    [facebookPostVC setInitialText:postContent];
    //[facebookPostVC addURL:[NSURL URLWithString:@"url"]]; // URL文字列
    [facebookPostVC addImage:captureImg];// 画像名（文字列）
    [self presentViewController:facebookPostVC animated:YES completion:nil];
    
}
-(void)lineButton:(UIButton*)button{
    
    // 投稿したい画像イメージをtmpImageへ格納する
    UIImage *tmpImage = captureImg;
    
    // pasteboardの生成
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    // pasteboardにpng画像をセットする
    [pasteboard setData:UIImagePNGRepresentation(tmpImage) forPasteboardType:@"public.png"];
    
    // pasteboard.nameをline://msg/image/の後ろに入れてパスを生成
    NSString *LINEUrlString = [NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name];
    
    // URLスキームを利用してLINEのアプリケーションを起動する
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LINEUrlString]];
}

#pragma mark - Private
- (void)removeMarksView
{
    [coachMarksView removeFromSuperview];
    [self performSelector:@selector(makeMosaic) withObject:nil afterDelay:0.01];
    //[self performSelectorInBackground:@selector(makeMosaic) withObject:nil];
}



@end