//
//  AppDelegate.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
//#import "CRNavigationController.h"
#import "SBJSON.h"
#import <AVFoundation/AVFoundation.h>
#import "MobClick.h"

extern SystemSoundID soundId;
extern  BOOL isActiveAPP;
extern bool isEndFile;
@interface AppDelegate ()
{
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MobClick startWithAppkey:@"5559f494e0f55aaf0a000101" reportPolicy:BATCH   channelId:@"Web"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
//    [MobClick checkUpdate:NSLocalizedString(@"有可用的版本更新",nil) cancelButtonTitle:NSLocalizedString(@"忽略此版本",nil) otherButtonTitles:NSLocalizedString(@"更新",nil)];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    
        Peripherals *Peripheral_1 = [[Peripherals alloc]init];
        UITabBarItem *item_1 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"设备",nil) image:[UIImage imageNamed:@"device_down"] tag:1];
        UINavigationController * nav_1 = [[UINavigationController alloc]initWithRootViewController:Peripheral_1];
        nav_1.navigationBar.barTintColor = [UIColor redColor];
        nav_1.tabBarItem = item_1;
    
    
        photograph *photograph_2 = [[photograph alloc]init];
        UITabBarItem *item_2 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"拍照",nil) image:[UIImage imageNamed:@"camera_down"] tag:2];
        UINavigationController * nav_2 = [[UINavigationController alloc]initWithRootViewController:photograph_2];
        nav_2.navigationBar.barTintColor = [UIColor redColor];
        nav_2.tabBarItem = item_2;
    
        Loction *loction_3 = [[Loction alloc]init];
        UITabBarItem *item_3 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"地图",nil) image:[UIImage imageNamed:@"local_down"] tag:3];
        UINavigationController * nav_3 = [[UINavigationController alloc]initWithRootViewController:loction_3];
        nav_3.navigationBar.barTintColor = [UIColor redColor];
        nav_3.tabBarItem = item_3;
    
    
        settings *settings_4 = [[settings alloc]init];
        UITabBarItem *item_4 = [[UITabBarItem alloc]initWithTitle:NSLocalizedString(@"设置",nil) image:[UIImage imageNamed:@"setting_down"] tag:4];
        UINavigationController * nav_4 = [[UINavigationController alloc]initWithRootViewController:settings_4];
        nav_4.navigationBar.barTintColor = [UIColor redColor];
        nav_4.tabBarItem = item_4;
    
        tabBarController = [[UITabBarController alloc] init];
        [[UITabBar appearance] setTintColor:[UIColor redColor]];
        [tabBarController setSelectedIndex:1];
        [tabBarController.tabBar setBackgroundColor:[UIColor whiteColor]];
        tabBarController.viewControllers = @[nav_1,nav_2,nav_3,nav_4];
        self.window.rootViewController = tabBarController;
        [self.window addSubview:tabBarController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    isActiveAPP = NO;
    isEndFile = YES;
    AudioServicesDisposeSystemSoundID(soundId);

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//清掉全部通知
     [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    isActiveAPP = YES;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
//    [SVProgressHUD showInfoWithStatus:notification.alertBody maskType:SVProgressHUDMaskTypeNone];
//    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:@"0"])
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"是否打开免打扰模式?",nil) message:NSLocalizedString(@"温馨提示:打开免打扰模式将无法接受到报警通知。",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"不需要",nil) otherButtonTitles:NSLocalizedString(@"打开",nil), nil];
        alert.delegate =self;
        alert.tag = 10;
        [alert show];
    }
}
- (void)getVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDic));
    //    NSString *app_Name = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString *app_Version = [infoDic objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    //    NSString *app_build = [infoDic objectForKey:@"CFBundleVersion"];
    
    float ver = [app_Version floatValue];
    
    NSString * ota_url = [NSString stringWithFormat:@"http://iosvoipapp.qiniudn.com/BLE_CB.txt"];
    [SVHTTPRequest POST:ota_url
             parameters:nil
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
                 NSString * ReturnData = [[NSString alloc] initWithData:response encoding:enc];
                 NSLog(@"return data [%@]",ReturnData);
                 
                 NSMutableArray * arry = [[NSMutableArray alloc]init];
                 SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                 
                 arry = [jsonParser objectWithString:ReturnData];
                 
                 {
                     float version = 0.0;
                     NSString * definition = nil;
                     NSDictionary * info = [[arry objectAtIndex:0] objectForKey:@"app_info"];
                     
                     version = [[info objectForKey:@"version"] floatValue];
                     
                     version = (int)(version*10);
                     if (version > (int)ver*10)
                     {
                         //需要升级
                         NSString * ota_url =nil;
                         
                         ota_url = [[NSString alloc]initWithFormat:@"%@",[info objectForKey:@"download_url"]];
                         
                         NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                         [defaults setObject:ota_url forKey:@"updata_url"];
                         [defaults synchronize];
                         
                         
                         definition =[[NSString alloc]initWithFormat:@"%@",[info objectForKey:@"version_definition"]];

                     }
                     
                     //以下是保护
                     NSString * isProtect = nil;
                     
                     NSDictionary * app_protect = [[arry objectAtIndex:0] objectForKey:@"app_protect"];
                     isProtect = [[NSString alloc]initWithFormat:@"%@",[app_protect objectForKey:@"protect"]];
                     if ([isProtect isEqualToString:@"YES"])
                     {
                         NSString *msgContent = [app_protect objectForKey:@"protect_definition"];
                         UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:msgContent delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
                         [alert show];
                     }
                     
                 }
             }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex == 1)&&(alertView.tag == 99)) {
        NSURL * url_open = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"updata_url"]];
        [[UIApplication sharedApplication]openURL:url_open];
        
    }
    if (alertView.tag == 10)
    {
        if (buttonIndex == 1)
        {
            settings *vc = [[settings alloc]init];
            [vc setMianDanRaoOpen];
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"发送成功",nil) maskType:SVProgressHUDMaskTypeNone];
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
            
        }
    }

}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
//- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
//{
//    NSMutableDictionary *statusBarChangeInfo = [[NSMutableDictionary alloc] init];
//    [statusBarChangeInfo setObject:@"statusbarchange"
//                            forKey:@"frame"];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"statusbarchange"
//                                                        object:self
//                                                      userInfo:statusBarChangeInfo];
//}
- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame{
    
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    [dict setObject:newStatusBarFrame forKey:@"frame"];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillChangeStatusBarFrameNotification
//                                                        object:self
//                                                      userInfo:dict];
//    [UIView animateWithDuration:0.35 animations:^{
//        CGRect windowFrame = self.window.frame;
//        if (newStatusBarFrame.size.height > 20) {
//            windowFrame.origin.y = newStatusBarFrame.size.height - 40 ;// old status bar frame is 20
//        }
//        else{
//            windowFrame.origin.y = 0.0;
//        }
//        self.window.frame = windowFrame;
//    }];
}
#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.wongshan.BLECB" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BLECB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BLECB.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
