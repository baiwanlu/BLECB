//
//  settings.m
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "settings.h"
#import "SBJSON.h"
#import "MobClick.h"
NSString * newVersionPathurl;

@interface settings ()
{
    NSTimer *pushTimer;
}
@property (nonatomic,strong)UITableView *tableview;
@end

@implementation settings
- (void)setProsessPop
{
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"正在发送请求...",nil)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
}
- (void)BLEwriteValue:(NSString *)command
{
    for (CBPeripheral *p in nDevices)
    {
        if ((p.state == CBPeripheralStateConnected)&&(_nWriteCharacteristics != nil)&&([_nWriteCharacteristics count] > 0))
        {
            [p writeValue:[command dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:[_nWriteCharacteristics objectAtIndex:0] type:CBCharacteristicWriteWithResponse];
        }
    }
}
- (void)setMianDanRaoOpen_Push6Times
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    {
        //本地通知
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        if (notification != nil) {
            // 初始化本地通知
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            // 通知触发时间
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60 * 5];
            // 触发后，弹出警告框中显示的内容
            localNotification.alertBody = NSLocalizedString(@"温馨提示:036Anti-lost 免打扰已打开，将无法接收到报警通知。",nil);
            // 触发时的声音（这里选择的系统默认声音）
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            // 触发频率（repeatInterval是一个枚举值，可以选择每分、每小时、每天、每年等）
            localNotification.repeatInterval = kCFCalendarUnitEra;
            // 需要在App icon上显示的未读通知数（设置为1时，多个通知未读，系统会自动加1，如果不需要显示未读数，这里可以设置0）
            localNotification.applicationIconBadgeNumber = 0;
            // 设置通知的id，可用于通知移除，也可以传递其他值，当通知触发时可以获取
            localNotification.userInfo = @{@"id" : @"notificationIdBLE"};
            // 注册本地通知
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            
            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60 * 10];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60 * 15];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60 * 20];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

            localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:60 * 25];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}
-(void)setMianDanRaoOpen
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"MIANDARAO"];
    [self BLEwriteValue:@"@OpenNoDisturb#"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setStatueon_nofiy" object:self];
    
    [self setMianDanRaoOpen_Push6Times];
}
-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn)
    {
        NSLog(@"打开免打扰");
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"MIANDARAO"];
        [self BLEwriteValue:@"@OpenNoDisturb#"];
        [self setProsessPop];
        [self setMianDanRaoOpen_Push6Times];
        
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"MIANDARAO"];
        [self setProsessPop];
        [self BLEwriteValue:@"@CloseNoDisturb#"];
        NSLog(@"关闭免打扰");
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)SetFDROn
{
    [self.switchmiandarao setOn:YES];
}
- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(SetFDROn)
                                                 name: @"setStatueon_nofiy"
                                               object: nil];


    
    self.switchmiandarao = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2.0 + 80.0f, 0, 80.0f, 35.0f)];
    [self.switchmiandarao setTintColor:[UIColor redColor]];
    [self.switchmiandarao addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:@"1"])
    {
        [self.switchmiandarao setOn:YES];
    }
    else
        [self.switchmiandarao setOn:NO];

    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0-self.navigationController.navigationBar.frame.size.height+10, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableview.delegate=self;
    _tableview.dataSource = self;
    _tableview.rowHeight = 55.0f;
    
    _tableview.separatorColor = [UIColor darkGrayColor];
    _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableview];
    
    
    self.title=NSLocalizedString(@"设置",nil);
    [self.navigationController.tabBarItem setTitle:NSLocalizedString(@"设置",nil)];

    NSDictionary *attributes = @{
                                 NSUnderlineStyleAttributeName: @1,
                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                 };
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell_deafult";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        //cell的四种样式
        //UITableViewCellStyleDefault,       只显示图片和标题
        //UITableViewCellStyleValue1,		显示图片，标题和子标题（子标题在右边）
        //UITableViewCellStyleValue2,		标题和子标题
        //UITableViewCellStyleSubtitle		显示图片，标题和子标题（子标题在下边）
    }
    if (indexPath.row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"免打扰设置",nil);
//        [self.switchmiandarao setCenter:CGPointMake(self.switchmiandarao.center.x, cell.center.y)];
//        [cell.contentView addSubview:self.switchmiandarao];
        cell.accessoryView = self.switchmiandarao;
    }
    else if (indexPath.row == 1)
    {
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        CFShow((__bridge CFTypeRef)(infoDic));

        cell.textLabel.text = NSLocalizedString(@"关于036Anti-lost",nil);
        cell.detailTextLabel.text = [infoDic objectForKey:@"CFBundleShortVersionString"];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];//显示小箭头
    }
    else
    {
        
    }
    cell.textLabel.textColor = [UIColor darkGrayColor];//设置标题字体颜色
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;//默认为1
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 0.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1)
    {
        
//appstore 版本不更新
#if 0
        
        [SVProgressHUD showProgress:0.0f status:NSLocalizedString(@"正在检查...",nil)];
        [self performSelector:@selector(increateProgress) withObject:nil afterDelay:0.2f];
//        [self getVersion];
//        [MobClick checkUpdate];
        [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
        [MobClick updateOnlineConfig];  //在线参数配置
#endif
    }
}

- (void)updateMethod:(NSDictionary *)appInfo {
    NSLog(@"update info %@",appInfo);
    
    [SVProgressHUD dismiss];
    if([[appInfo objectForKey:@"update"] isEqualToString:@"YES"]==YES)
    {
        newVersionPathurl = [[NSString alloc]initWithString:[appInfo objectForKey:@"path"]];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"有可用的版本更新",nil) message:[NSString stringWithString:[appInfo objectForKey:@"update_log"]] delegate:self cancelButtonTitle:NSLocalizedString(@"忽略此版本",nil) otherButtonTitles:NSLocalizedString(@"更新",nil), nil];
        alert.tag = 10;
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"此版本已最新",nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}
static float progressVaule = 0.0f;
static bool isGetResult = false;
- (void)increateProgress
{
    progressVaule += 0.05f;
    [SVProgressHUD showProgress:progressVaule status:@"正在检查..."];
    
    if (isGetResult == true)
    {
        isGetResult = false;
        [SVProgressHUD dismiss];
        return;
    }
    if (progressVaule < 1.0f)
    {
        [self performSelector:@selector(increateProgress) withObject:nil afterDelay:0.005f];
    }
    else
    {
        progressVaule = 0.0;
        isGetResult = false;
        [SVProgressHUD dismiss];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getVersion
{
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex == 1)&&(alertView.tag == 99)) {
        NSURL * url_open = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"updata_url"]];
        [[UIApplication sharedApplication]openURL:url_open];
    }
    if((alertView.tag == 10)&&(buttonIndex == 1))
    {
        NSURL *url = [NSURL URLWithString:newVersionPathurl];  [[UIApplication sharedApplication]openURL:url];
    }
}
- (void)appUpdate:(NSDictionary *)appInfo;
{
    
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
