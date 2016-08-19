//
//  Peripherals.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "Peripherals.h"
#import "PeripheralsDetailSettingViewController.h"
#import "PhotoVIew.h"
#import "SimpleAudioPlayer.h"
#import "CUSFlashLabel.h"
#import "ViewController.h"
CBCentralManager *manager;
CBPeripheral *_peripheral;
NSMutableArray *nDevices;
NSMutableArray *nTempDevices;
NSTimer *timer;
NSMutableArray *nServices;
NSMutableArray *nCharacteristics;
CBCharacteristic *_writeCharacteristic;
NSMutableArray *allBleArray;
CBPeripheral * peripheralDeviceSelect;
NSMutableDictionary *nPerpherName;
NSMutableArray *_nWriteCharacteristics;
NSTimer *mytimer;
BOOL isActiveAPP;
SystemSoundID soundId;
bool isEndFile = YES;
BOOL isConnectLast = NO;
@interface Peripherals ()

@property(nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong) UIActivityIndicatorView *activity;
@property (nonatomic)BOOL isActiveScan;
@property (nonatomic)BOOL isCanUpdateTable;
@property(nonatomic) float batteryValue;
@property (strong,nonatomic)UIBarButtonItem *rightbutton;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation Peripherals
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (BOOL)hasConnectPerpheral
{
    for (CBPeripheral *p in nDevices)
    {
        if (p.state == CBPeripheralStateConnected)
        {
            return YES;
        }
    }
    return NO;
}
- (void)active_display
{
    _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    _activity.frame = CGRectMake(85.0f,10.0f,30.0f,30.0f);
    _activity.frame = CGRectZero;
    _activity.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
//    [_activity setCenter:CGPointMake(90.0f, self.navigationController.navigationBar.center.y)];
    _activity.hidesWhenStopped = YES;
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:_activity];
//    [self.navigationItem.rightBarButtonItem initWithCustomView:barButton];
    [self navigationItem].rightBarButtonItem = barButton;
//    [self.navigationController.navigationBar addSubview:_activity];
    [_activity startAnimating];
}
- (void)initDatas
{
    nTempDevices =[[NSMutableArray alloc]init];
    nDevices = [[NSMutableArray alloc]init];
    nServices = [[NSMutableArray alloc]init];
    nCharacteristics = [[NSMutableArray alloc]init];
    _nWriteCharacteristics = [[NSMutableArray alloc]init];
    _peripheral = nil;
    _writeCharacteristic = nil;
}
- (void)viewDidLoad {
    nPerpherName = [[NSMutableDictionary alloc]initWithDictionary:[PeripheralsDetailSettingViewController getFordicName]];
    [self initDatas];
    [self initBLE];
    [self initTableView];
//    [self BLEscan];
    [self active_display];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.title=NSLocalizedString(@"设备列表",nil);
    
    [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"设备",nil)];
    NSDictionary *attributes = @{
                                 NSUnderlineStyleAttributeName: @1,
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                 };
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initBLE
{
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];    
}
- (void)stopPlayersound
{
    NSLog(@"END FILE!!!!!");
    isEndFile = YES;
    AudioServicesDisposeSystemSoundID(soundId);
}
- (void)DisplayNotification:(NSString *)title playlenth:(double)lenth
{
    if (lenth == 0.0)
    {
        NSLog(@"stop file!!!");
        isEndFile = YES;
        AudioServicesDisposeSystemSoundID(soundId);
        return;
    }
    NSLog(@"play sound?????");
    if (isEndFile == YES)
    {
        NSLog(@"play...........");
        isEndFile = NO;
        if (lenth != 0.0)
        {
            [SVProgressHUD showInfoWithStatus:title];
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
        }
        
        NSString *path = [[NSBundle mainBundle]pathForResource:@"xulie_10" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundId);
        AudioServicesPlaySystemSound(soundId);
        
        if (mytimer) {
            [mytimer invalidate];
            mytimer = nil;
        }
        mytimer = [NSTimer scheduledTimerWithTimeInterval:lenth target:self selector:@selector(stopPlayersound) userInfo:nil repeats:NO];
//        
//        double delayInSeconds = lenth;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//                       {
//                           NSLog(@"end file!!!");
//                           isEndFile = YES;
//                           AudioServicesDisposeSystemSoundID(soundId);
//                       });
    }
}
- (void)initNotice
{
    NSLog(@"丢失报警");
    if (isActiveAPP)
    {
        //在APP
        [self DisplayNotification:NSLocalizedString(@"丢失报警",nil) playlenth:10.0];
    }
    else
    {
        //本地通知
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        if (notification != nil) {
            // 初始化本地通知
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            // 通知触发时间
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            // 触发后，弹出警告框中显示的内容
            localNotification.alertBody = NSLocalizedString(@"移动电源报警",nil);
            // 触发时的声音（这里选择的系统默认声音）
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            // 触发频率（repeatInterval是一个枚举值，可以选择每分、每小时、每天、每年等）
            localNotification.repeatInterval = kCFCalendarUnitEra;
            // 需要在App icon上显示的未读通知数（设置为1时，多个通知未读，系统会自动加1，如果不需要显示未读数，这里可以设置0）
            localNotification.applicationIconBadgeNumber = 0;
            // 设置通知的id，可用于通知移除，也可以传递其他值，当通知触发时可以获取
            localNotification.userInfo = @{@"id" : @"notificationIdBLE"};
            localNotification.alertBody = NSLocalizedString(@"丢失报警",nil);
            localNotification.soundName = @"xulie_10.wav";
            // 注册本地通知
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}
- (void)initNoticeSearchPhone
{
    NSLog(@"找录手机");

    if (isActiveAPP)
    {
        //在APP
        [self DisplayNotification:NSLocalizedString(@"找寻手机",nil) playlenth:10.0];
    }
    else
    {
        //本地通知
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        if (notification != nil) {
            // 初始化本地通知
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            // 通知触发时间
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
            // 触发后，弹出警告框中显示的内容
            localNotification.alertBody = NSLocalizedString(@"找寻手机",nil);
            // 触发时的声音（这里选择的系统默认声音）
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            // 触发频率（repeatInterval是一个枚举值，可以选择每分、每小时、每天、每年等）
            localNotification.repeatInterval = kCFCalendarUnitEra;
            // 需要在App icon上显示的未读通知数（设置为1时，多个通知未读，系统会自动加1，如果不需要显示未读数，这里可以设置0）
            localNotification.applicationIconBadgeNumber = 0;
            // 设置通知的id，可用于通知移除，也可以传递其他值，当通知触发时可以获取
            localNotification.userInfo = @{@"id" : @"notificationIdBLE"};
            localNotification.alertBody = NSLocalizedString(@"找寻手机",nil);
            localNotification.soundName = @"xulie_10.wav";
            // 注册本地通知
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}
- (void)canceLocNoticeSound
{
    //本地通知
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    if (notification != nil) {
        // 初始化本地通知
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        // 通知触发时间
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
        // 触发后，弹出警告框中显示的内容
        localNotification.alertBody = NSLocalizedString(@"找寻手机",nil);
        // 触发时的声音（这里选择的系统默认声音）
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        // 触发频率（repeatInterval是一个枚举值，可以选择每分、每小时、每天、每年等）
        localNotification.repeatInterval = kCFCalendarUnitEra;
        // 需要在App icon上显示的未读通知数（设置为1时，多个通知未读，系统会自动加1，如果不需要显示未读数，这里可以设置0）
        localNotification.applicationIconBadgeNumber = 0;
        // 设置通知的id，可用于通知移除，也可以传递其他值，当通知触发时可以获取
        localNotification.userInfo = @{@"id" : @"notificationIdBLE"};
        localNotification.alertBody = NSLocalizedString(@"找寻手机",nil);
        // 注册本地通知
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
}

- (void)removeLocalNotification {
    
    // 取出全部本地通知
    NSArray *notifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    // 设置要移除的通知id
    NSString *notificationId = @"notificationIdBLE";
    
    // 遍历进行移除
    for (UILocalNotification *localNotification in notifications) {
        
        // 将每个通知的id取出来进行对比
        if ([[localNotification.userInfo objectForKey:@"id"] isEqualToString:notificationId]) {
            
            // 移除某一个通知
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }
}

- (void)BLEscan
{
    [self initDatas];

    NSLog(@"扫描中...");
    [_activity startAnimating];
    //扫描所有的外设
//    [manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    if(manager.state == CBCentralManagerStatePoweredOn)
    [manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}
- (void)viewDidAppear:(BOOL)animated
{
    [_tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }

    [_activity stopAnimating];
    //连接上了就断开搜索服务
    if(manager.state == CBCentralManagerStatePoweredOn)
    [manager stopScan];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self BLEscan];
}
- (void)initTableView
{
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Table Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nDevices count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *peripherCustCell = @"peripherCustCell_";
    
    
    PeripheralsCell * cell =(PeripheralsCell *)[tableView
                                        dequeueReusableCellWithIdentifier:peripherCustCell];
    if (cell == nil)
    {
        NSArray *nib=[[NSBundle mainBundle]loadNibNamed:@"PeripheralsCell"
                                                  owner:self
                                                options:nil];
        cell=[nib objectAtIndex:0];
    }
    if([nDevices count]>indexPath.row)
    {
        CBPeripheral * peripheralDevice = [nDevices objectAtIndex:indexPath.row];
        if (peripheralDevice.state == CBPeripheralStateDisconnected)
        {
            [cell.cellHeardImgview setImage:[UIImage imageNamed:@"device_icon_off"]];
            [cell.PeripherConnectBut setBackgroundImage:[UIImage imageNamed:@"connect_bottom_off"] forState:UIControlStateNormal];
            [cell.PeripherConnectBut setTitle:NSLocalizedString(@"连接",nil) forState:UIControlStateNormal];
            [cell.PerpherConectStatueLabel setText:NSLocalizedString(@"未连接",nil)];
            [cell.PeripherConnectBut setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            [cell.PerpherConectStatueLabel setTextColor:[UIColor grayColor]];
        }
        else
        {
            [cell.cellHeardImgview setImage:[UIImage imageNamed:@"device_icon_on"]];
            [cell.PeripherConnectBut setBackgroundImage:[UIImage imageNamed:@"connect_bottom_on"] forState:UIControlStateNormal];
            [cell.PeripherConnectBut setTitle:NSLocalizedString(@"已连接",nil) forState:UIControlStateNormal];
            [cell.PeripherConnectBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.PerpherConectStatueLabel setText:NSLocalizedString(@"已连接",nil)];
            [cell.PerpherConectStatueLabel setTextColor:[UIColor greenColor]];
        }
        cell.PeripherConnectBut.tag = indexPath.row;
        cell.PeripherNextBut.tag = indexPath.row;
        
        CBPeripheral *p = [nDevices objectAtIndex:indexPath.row];
        if ([nPerpherName objectForKey:p.identifier] != nil)
        {
            cell.PeripherNameLabel.text = [nPerpherName objectForKey:p.identifier];
        }
        else
        {
            cell.PeripherNameLabel.text = p.name;
        }
    }
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];//显示小箭头
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 3;
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessoryButton的响应事件");
}

- (void)BLEwriteValue:(NSString *)command per:(CBPeripheral *)p charact:(CBCharacteristic *)writechararcter
{
    NSLog(@"发送数据 %@",command);

    if (command != nil)
    {
        [p writeValue:[command dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:writechararcter type:CBCharacteristicWriteWithResponse];
    }
}

- (IBAction)BLEConnectAction:(id)sender
{
    NSLog(@"连接开始");
    //test
    
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"正在连接...",nil) maskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
    UIButton *btn = (UIButton *)sender;
    
    if ([nDevices count]>btn.tag)
    {
        CBPeripheral *p = [nDevices objectAtIndex:btn.tag];
        [manager connectPeripheral:p options:nil];
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"失败,请重试...",nil) maskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
    }
}

- (IBAction)PeripherSettingAction:(id)sender
{
    NSLog(@"进入设置");
    AudioServicesDisposeSystemSoundID(soundId);
    isConnectLast = YES;//已经连接过。。这样的话，在第一次打开没有蓝牙情况下，可以判断不用叫。
    isEndFile = YES;
    CBPeripheral *p = _peripheral;
    if (p.state == CBPeripheralStateConnected)
    {
        PeripheralsDetailSettingViewController *vc = [[PeripheralsDetailSettingViewController alloc]init];
        if ([nPerpherName objectForKey:p.identifier])
        {
            vc.textName = [nPerpherName objectForKey:p.identifier];
        }
        else
        {
            vc.textName = p.name;
        }
        vc.manager = manager;
        [vc setPeripheralsub:p];
        [vc setWriteCharacteristicsub:_writeCharacteristic];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已打开,请扫描外设");
            [_rightbutton setEnabled:YES];
            [self BLEscan];
            break;
        case CBCentralManagerStateUnsupported:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"设备不支持BLE哦。",nil)];
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
            [_rightbutton setEnabled:NO];
            [_activity stopAnimating];
            NSLog(@"设备不支持BLE4.0");
            break;
        default:
            [_activity stopAnimating];
            [_rightbutton setEnabled:NO];
            [_tableView reloadData];
            NSLog(@"没打开蓝牙");
            if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:kCloseString])
                &&([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] isEqualToString:kOpenString]))
            {
                if (isConnectLast == YES)
                {
                    [self initNotice];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"disConnect_nofiy" object:self];
            break;
    }
}
//查到外设后，停止扫描，连接设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    static int PeripheralsCount = 0;
    _peripheral = peripheral;
    _isCanUpdateTable = YES;
    //    NSLog(@"查到外设:%@",peripheral);
    
    if (++PeripheralsCount<100)
    {
        if (![nTempDevices containsObject:_peripheral])
        {
            [nTempDevices addObject:peripheral];
        }
    }
    else
    {
        int i;
        PeripheralsCount = 0;
        
        for (i=0;i<[nDevices count];i++)
        {
            if (![nTempDevices containsObject:[nDevices objectAtIndex:i]])
            {
                NSMutableArray *array = [NSMutableArray array];
                [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                [nDevices removeObject:[nDevices objectAtIndex:i]];
                [_tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
            }
        }
        [nTempDevices removeAllObjects];
    }
    
    if ([nDevices containsObject:_peripheral]) {
        // 更新
        //        NSUInteger index = [nDevices indexOfObject:peripheral];
        //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        //        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        // 追加
        [nDevices addObject:peripheral];
        //test
        //        [nDevices addObject:peripheral];
        [_tableView reloadData];
        //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        //        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
- (NSString *)getConfig
{
    NSString * cmdString = [[NSString alloc]initWithFormat:@"@TTSet"];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:kCloseString forKey:@"MIANDARAO"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:kOpenString forKey:@"FANGDAO"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAOJULI"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"FANGDAOJULI"];
    }
    
    cmdString = [cmdString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"]];
    cmdString = [cmdString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"]];
    cmdString = [cmdString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAOJULI"]];
    cmdString = [cmdString stringByAppendingString:@"#"];
    return cmdString;
}
//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    
    //连接上了就断开搜索服务
    [manager stopScan];
    [_activity stopAnimating];
}
//外设断开了
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"断开了。。。。\n断开了。。。。");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disConnect_nofiy" object:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:kCloseString])
            &&([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] isEqualToString:kOpenString]))
        {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"设备已断开",nil)];
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
            [self initNotice];
        }
    });
    //    [self initDatas];
//    NSMutableArray *array = [NSMutableArray array];
//    for (int v=0; v < [nDevices count]; v++)
//    {
//        [array addObject:[NSIndexPath indexPathForRow:v inSection:0]];
//        [_tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
//    }
//    [_tableView reloadData];
//    [self initBLE];
}
/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",error);
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"连接失败，请重试。",nil)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
}
-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    int rssi = abs([peripheral.RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
    NSLog(@"距离：%@",length);
    _peripheral = peripheral;
//    [_peripheral readRSSI];
}
//已发现服务
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    int i=0;
    for (CBService *s in peripheral.services) {
        [nServices addObject:s];
    }
    for (CBService *s in peripheral.services) {
        NSLog(@"%d :服务 UUID: %@(%@)",i,s.UUID.data,s.UUID);
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    _peripheral = peripheral;
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"特征 UUID: %@ (%@)",c.UUID.data,c.UUID);
        if ([c.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicUUID]])
        {
            BOOL _isPlace = false;
            
            [peripheral setNotifyValue:YES forCharacteristic:c];
            [_peripheral readRSSI];
            for (int i=0; i < [nCharacteristics count]; i++)
            {
                CBCharacteristic *_tmpwriteCharacteristic = [nCharacteristics objectAtIndex:i];
                if ([_tmpwriteCharacteristic isEqual:c])
                {
                    _isPlace = true;
                }
            }
            
            if (_isPlace == false)
            {
                [nCharacteristics addObject:c];
            }
        }
        if ([c.UUID isEqual:[CBUUID UUIDWithString:kCharacteristicWirteUUID]]) {
            [_nWriteCharacteristics addObject:c];
            _writeCharacteristic = c;
            [self BLEwriteValue:[self getConfig] per:peripheral charact:c];
            [self performSelector:@selector(PeripherSettingAction:) withObject:self afterDelay:1.0f];
        }
    }
}
//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // BOOL isSaveSuccess;
    NSLog(@"didUpdateValueForCharacteristic%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        _batteryValue = [value floatValue];
        NSLog(@"电量%f",_batteryValue);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFA1"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        //_batteryValue = [value floatValue];
        NSLog(@"信号%@",value);
    }
    else if ([[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] isEqualToString:kRevStartAlarm])
    {
        if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:kCloseString])
            &&([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] isEqualToString:kOpenString]))
        {
            [self initNotice];
        }
        else
        {
            NSLog(@"其它情况不打开通知");
        }
    }//nNoticeTakePhotos
    else if ([[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] isEqualToString:kSearcePhone])
    {
        if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:kCloseString])
            &&([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] isEqualToString:kOpenString]))
        {
            [self initNoticeSearchPhone];
        }
        else
        {
            NSLog(@"其它情况不打开通知");
        }

    }
    else if (([[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] isEqualToString:kRevTackPhotos]))
    {
        NSLog(@"拍照命令");
        if (isActiveAPP) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NTtackePhontos" object:self];

        }
    }
    else if (([[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] isEqualToString:kRevStoptAlarm]))
    {
        if (isActiveAPP)
        {
            //在APP
            [self DisplayNotification:nil playlenth:0.0];
        }
        else
        {
//            [self canceLocNoticeSound];
        }
    }
    else
    {
    
    }
}
//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    // Notification has started
    NSLog(@"peripheral :%@",peripheral);
    if (characteristic.isNotifying)
    {
        [peripheral readValueForCharacteristic:characteristic];
        
    } else { // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [manager cancelPeripheralConnection:peripheral];
    }
    
    //更新TBALEVIEW
//    NSLog(@"%@",peripheral);
    
    BOOL replace = NO;
    for (CBPeripheral *p in nDevices)
    {
        if ([p isEqual:peripheral])
        {
            replace = YES;
        }
    }
    if (replace)
    {
        [_tableView reloadData];
    }


}
//用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"ERROR: Result of writing to characteristic: %@ of service: %@ with error: %@", characteristic.UUID, characteristic.service.UUID, error);
    }else{
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"发送成功",nil) maskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
        NSLog(@"发送数据成功");
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame{
    
    //    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    //    [dict setObject:newStatusBarFrame forKey:@"frame"];
    //
    //    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillChangeStatusBarFrameNotification
    //                                                        object:self
    //                                                      userInfo:dict];
    [UIView animateWithDuration:0.35 animations:^{
        CGRect windowFrame = self.view.frame;
        if (newStatusBarFrame.size.height > 20) {
            windowFrame.origin.y = newStatusBarFrame.size.height - 40 ;// old status bar frame is 20
        }
        else{
            windowFrame.origin.y = 0.0;
        }
        self.view.frame = windowFrame;
    }];
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
    
}
@end
