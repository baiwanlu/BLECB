//
//  ViewController.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UITabBarController * rootController;
    NSMutableArray * MutControllerArray;
}
@end

@implementation ViewController


#pragma mark 设置导航栏主题
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillChangeStatusBarFrameNotification)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification
                                                   object:nil];
    }
    
    return self;
    
}
- (void)appWillChangeStatusBarFrameNotification
{
    // 对需要的UI重新适配Frame
//    NSLog(@"self.view.fream:%@",self.view.frame);
}
- (void)viewDidLoad {
    
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewDidLoad];

//    rootController = [[UITabBarController alloc]init];
//    rootController.view.frame = self.view.frame;
//    Peripherals *Peripheral_1 = [[Peripherals alloc]init];
//    UITabBarItem *item_1 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"设备",nil) image:[UIImage imageNamed:@"device_down"] tag:1];
//    UINavigationController * nav_1 = [[UINavigationController alloc]initWithRootViewController:Peripheral_1];
//    nav_1.navigationBar.barTintColor = [UIColor redColor];
//    nav_1.tabBarItem = item_1;
//    
//    
//    photograph *photograph_2 = [[photograph alloc]init];
//    UITabBarItem *item_2 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"拍照",nil) image:[UIImage imageNamed:@"camera_down"] tag:2];
//    UINavigationController * nav_2 = [[UINavigationController alloc]initWithRootViewController:photograph_2];
//    nav_2.navigationBar.barTintColor = [UIColor redColor];
//    nav_2.tabBarItem = item_2;
//
//    Loction *loction_3 = [[Loction alloc]init];
//    UITabBarItem *item_3 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"定位",nil) image:[UIImage imageNamed:@"local_down"] tag:3];
//    UINavigationController * nav_3 = [[UINavigationController alloc]initWithRootViewController:loction_3];
//    nav_3.navigationBar.barTintColor = [UIColor redColor];
//    nav_3.tabBarItem = item_3;
//    
//
//    settings *settings_4 = [[settings alloc]init];
//    UITabBarItem *item_4 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"设置",nil) image:[UIImage imageNamed:@"setting_down"] tag:4];
//    UINavigationController * nav_4 = [[UINavigationController alloc]initWithRootViewController:settings_4];
//    nav_4.navigationBar.barTintColor = [UIColor redColor];
//    nav_4.tabBarItem = item_4;
//    
//    
//    [[UITabBar appearance] setTintColor:[UIColor redColor]];
//    [rootController setSelectedIndex:1];
//    [rootController.tabBar setBackgroundColor:[UIColor whiteColor]];
//    rootController.viewControllers = @[nav_1,nav_2,nav_3,nav_4];
//    [self.view addSubview:rootController.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
