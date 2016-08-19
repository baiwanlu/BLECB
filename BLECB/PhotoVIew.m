//
//  PhotoVIew.m
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "PhotoVIew.h"

@interface PhotoVIew ()
@property(nonatomic)BOOL isDisButton;
@property(nonatomic,strong)UIButton *backButton;
@property(nonatomic,strong)UIView   *navView;
@end

@implementation PhotoVIew
@synthesize imagePhoto;
- (void)viewDidLoad {

    UITapGestureRecognizer* recognizer;
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    recognizer.numberOfTapsRequired = 1; // 单击
    [self.view addGestureRecognizer:recognizer];

    
    [self.view setBackgroundColor:[UIColor blackColor]];
    CGRect frame = CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, self.view.frame.size.height);
    VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:frame andImage:imagePhoto];
    photoView.autoresizingMask = (1 << 6) -1;
    
    [self.view addSubview:photoView];
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(6, 3, 44.0f, 44.0f);
    [_backButton setImage:[UIImage imageNamed:@"fanhuijinguo"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    _navView = [[UIView alloc]initWithFrame:_navFrame];
    [_navView setBackgroundColor:[UIColor redColor]];
    [_navView addSubview:_backButton];
    
    UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-70.0f)/2.0f, 7.0f, 100.0f, 24.0f)];
//    [titlelabel setCenter:CGPointMake(_navView.center.x, _navView.center.y)];
    titlelabel.font = [UIFont systemFontOfSize:15.0f];
    [titlelabel setTextColor:[UIColor whiteColor]];
    [titlelabel setText:NSLocalizedString(@"图片预览",nil)];
    [_navView addSubview:titlelabel];
    [self.view addSubview:_navView];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)backAction:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_isDisButton == YES)
    {
        _isDisButton = NO;
        [_navView setHidden:YES];
    }
    else
    {
        _isDisButton = YES;
        [_navView setHidden:NO];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [_navView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
