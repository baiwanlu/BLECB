//
//  photograph.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "photograph.h"

#import "LLSimpleCamera.h"
BOOL isInitCamera;
@interface photograph ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UIImageView *snap_bg;
@property (strong, nonatomic) UIView *photoView;
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UIImage *imageFromSnap;
@end

@implementation photograph

- (void)setPhotoGraphView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    self.camera = [[LLSimpleCamera alloc] initWithQuality:CameraQualityPhoto andPosition:CameraPositionFront];
    [self.camera attachToViewController:self withFrame:CGRectMake(0, tabBarHeight, screenRect.size.width, screenRect.size.height-tabBarHeight)];

    self.camera.fixOrientationAfterCapture = NO;
    
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.camera setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
        
        NSLog(@"Device changed.");
        
        // device changed, check if flash is available
        if([camera isFlashAvailable]) {
            weakSelf.flashButton.hidden = NO;
            
            if(camera.flash == CameraFlashOff) {
                weakSelf.flashButton.selected = NO;
            }
            else {
                weakSelf.flashButton.selected = YES;
            }
        }
        else {
            weakSelf.flashButton.hidden = YES;
        }
    }];
    
    [self.camera setOnError:^(LLSimpleCamera *camera, NSError *error) {
        NSLog(@"Camera error: %@", error);
        
        if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
            if(error.code == LLSimpleCameraErrorCodePermission) {
                if(weakSelf.errorLabel)
                    [weakSelf.errorLabel removeFromSuperview];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.text = NSLocalizedString(@"请到设置菜单栏打开允许自拍器使用摄像头权限。",nil);
                label.numberOfLines = 2;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [label sizeToFit];
                label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
                weakSelf.errorLabel = label;
                [weakSelf.view addSubview:weakSelf.errorLabel];
            }
        }
    }];
    self.snap_bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, screenRect.size.height-tabBarHeight-70.0f-2, screenRect.size.width, 72.0f)];
    [self.snap_bg setImage:[UIImage imageNamed:@"tab_photograp_bg"]];
    [self.view addSubview:self.snap_bg];
    //snap imageview
    self.photoView = [[UIView alloc]initWithFrame:CGRectMake(10.0f, screenRect.size.height-tabBarHeight-67.0f, 65.0f, 65.0)];
    self.photoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.photoView.frame.size.width, self.photoView.frame.size.height)];
    [self.photoImageView setImage:[UIImage imageNamed:@"album"]];
    [self.photoView addSubview:self.photoImageView];
    
    UITapGestureRecognizer* recognizer;
    // handleSwipeFrom 是偵測到手势，所要呼叫的方法
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    recognizer.numberOfTapsRequired = 1; // 单击
    [self.photoView addGestureRecognizer:recognizer];

    
    [self.view addSubview:self.photoView];
    
    // snap button to capture image
    self.snapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.snapButton.frame = CGRectMake((screenRect.size.width-70.f)/2.0, screenRect.size.height-tabBarHeight-70.0f, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.frame.size.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
    
    // button to toggle flash
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.flashButton.frame = CGRectMake(10.0f,self.navigationController.navigationBar.frame.size.height+13.0f, 16.0f + 20.0f, 24.0f + 20.0f);
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash-off.png"] forState:UIControlStateNormal];
    [self.flashButton setImage:[UIImage imageNamed:@"camera-flash-on.png"] forState:UIControlStateSelected];
    self.flashButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.flashButton addTarget:self action:@selector(flashButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashButton];
    
    // button to toggle camera positions
    self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchButton.frame = CGRectMake(screenRect.size.width-50.0f, self.navigationController.navigationBar.frame.size.height+13.0f, 29.0f + 20.0f, 22.0f + 20.0f);
    [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
    self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchButton];

}
- (void)viewWillAppear:(BOOL)animated
{
    if (self.camera) {
        isInitCamera = YES;
        [self.camera start];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.camera stop];
    isInitCamera = NO;
}
-(void)LocalPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
//    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    //相册
    //[self LocalPhoto];
    if (self.imageFromSnap != nil)
    {
        PhotoVIew * vc = [[PhotoVIew alloc]init];
        vc.imagePhoto = self.imageFromSnap;
        vc.navFrame = self.navigationController.navigationBar.frame;
        [self presentViewController:vc animated:YES completion:nil];
    }
}
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil)
        {
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        else
        {
            data = UIImagePNGRepresentation(image);
        }
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        
        //得到选择后沙盒中图片的完整路径
//        NSString *filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:NO completion:nil];
        
        //创建一个选择后图片的小图标放在下方
        //类似微薄选择图后的效果
        UIImageView *smallimage = [[UIImageView alloc] initWithFrame:
                                    CGRectMake(50, 120, 40, 40)];
        
        smallimage.image = image;
        //加在视图中
        [self.view addSubview:smallimage];
        
    } 
    
}


- (void)viewDidLoad {
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(snapButtonPressed:)
                                                 name: @"NTtackePhontos"
                                               object: nil];

    
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.title=NSLocalizedString(@"拍照",nil);
    [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"拍照",nil)];

    NSDictionary *attributes = @{
                                 NSUnderlineStyleAttributeName: @1,
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                 };
    
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self setPhotoGraphView];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/* camera button methods */

- (void)switchButtonPressed:(UIButton *)button {
    [self.camera togglePosition];
}

- (void)flashButtonPressed:(UIButton *)button {
    
    if(self.camera.flash == CameraFlashOff) {
        BOOL done = [self.camera updateFlashMode:CameraFlashOn];
        if(done) {
            self.flashButton.selected = YES;
        }
    }
    else {
        BOOL done = [self.camera updateFlashMode:CameraFlashOff];
        if(done) {
            self.flashButton.selected = NO;
        }
    }
}
- (void)CameraReopen
{
    [self.camera start];
}
- (void)snapButtonPressed:(UIButton *)button {
    
    if (isInitCamera == NO)
    {
        NSLog(@"不在相机画面,不拍照");
        return;
    }
    
    // capture
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            
            // we should stop the camera, since we don't need it anymore. We will open a new vc.
            // this very important, otherwise you may experience memory crashes
            [camera stop];
            if (self.imageFromSnap != nil) {
                self.imageFromSnap = nil;
            }
            self.imageFromSnap = [[UIImage alloc]init];
            self.imageFromSnap = [image copy];
            [self performSelector:@selector(CameraReopen) withObject:self afterDelay:0.05f];
            // show the image
            //保存到相册中。
            [self saveImageToAlbum:image];
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (void)saveImageToAlbum:(UIImage *)image {
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"保存失败";
    if (!error) {
        message = @"成功保存到相册";
        [self.photoImageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.photoImageView setImage:image];
    }else
    {
        message = [error description];
    }
    NSLog(@"message is %@",message);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
