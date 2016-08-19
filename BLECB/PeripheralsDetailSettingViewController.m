//
//  PeripheralsDetailSettingViewController.m
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "PeripheralsDetailSettingViewController.h"
#import "SVProgressHUD.h"
#import "ViewController.h"
#import "CUSFlashLabel.h"
BOOL _isActiveView;
@interface PeripheralsDetailSettingViewController ()
{
    CUSFlashLabel *titleFDR;
}
@property(nonatomic,strong)UIBarButtonItem *leftbutton;
@property (nonatomic,strong)UITableView *tableview;

@end

@implementation PeripheralsDetailSettingViewController
@synthesize textName;
- (void)ation_done:(id)sender
{
    [_textFieldName resignFirstResponder];
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"已保存",nil)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
}
-(IBAction)actionAlert:(id)sender
{
    [self BLEwriteValue:kSearchDevice];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.delegate = self;

    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MIANDARAO"] isEqualToString:@"1"])
    {
        titleFDR = [[CUSFlashLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30.0)];
        [titleFDR setText:NSLocalizedString(@"免打扰模式已经打开",nil)];
        [titleFDR setCenter:CGPointMake(self.view.center.x+16, 28.0)];
        NSLog(@"view center.x %f",self.view.center.x);
        [titleFDR setTextColor:[UIColor whiteColor]];
        [titleFDR setSpotlightColor:[UIColor grayColor]];
        [titleFDR setFont:[UIFont systemFontOfSize:15]];
        [titleFDR setTextAlignment:NSTextAlignmentCenter];
        [titleFDR setContentMode:UIViewContentModeTop];
        [titleFDR startAnimating];
        [self.navigationController.navigationBar addSubview:titleFDR];
    }
    else
    {
        titleFDR = nil;
    }

    _isActiveView = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"断开",nil)
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(actionDisconnect:)];
    [self.navigationItem setHidesBackButton:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
}
- (void)viewDidDisappear:(BOOL)animated
{
    _isActiveView = NO;
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.delegate = nil;
    if (titleFDR)
    {
        [titleFDR removeFromSuperview];
    }
}
- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(popViewFromPeripheralsDetail)
                                                 name: @"disConnect_nofiy"
                                               object: nil];

    [super viewDidLoad];
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,13, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableview.delegate=self;
    _tableview.dataSource = self;
    _tableview.rowHeight = 55.0f;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.view addSubview:_tableview];

    UIBarButtonItem *_rightbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                 target:self
                                                                 action:@selector(ation_done:)];
    [_rightbutton setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.rightBarButtonItem = _rightbutton;
//
    self.textFieldName = [[UITextField alloc]initWithFrame:CGRectMake(0.0, 0.0, 160.0, 40)];
//    [self.textFieldName setBackground:[UIImage imageNamed:@"fm_input_text.png"]];
    [self.textFieldName setBorderStyle:UITextBorderStyleRoundedRect];
    [self.textFieldName setTextAlignment:NSTextAlignmentCenter];
    self.textFieldName.delegate =self;
    [self.textFieldName addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.butDisconnect setFrame:CGRectMake((self.view.frame.size.width-107.0f)/2.0, self.butDisconnect.frame.origin.y, self.butDisconnect.frame.size.width, self.butDisconnect.frame.size.height)];
    
    self.textFieldName.text = textName;
    // Do any additional setup after loading the view from its nib.
    [self.switchProtect addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.switchProtect setTintColor:[UIColor redColor]];
    [self.segemetDistance setTintColor:[UIColor redColor]];
    [self.segemetDistance addTarget:self action:@selector(_segment_select:) forControlEvents:UIControlEventValueChanged];
    [self.segemetDistance setTitle:NSLocalizedString(@"近",nil) forSegmentAtIndex:0];
    [self.segemetDistance setTitle:NSLocalizedString(@"中",nil) forSegmentAtIndex:1];
    [self.segemetDistance setTitle:NSLocalizedString(@"远",nil) forSegmentAtIndex:2];

    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAO"] isEqualToString:kOpenString]))
    {
        [self.switchProtect setOn:YES];
    }
    else
    {
        [self.switchProtect setOn:NO];
    }
    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAOJULI"] isEqualToString:@"0"]))
    {
        [self.segemetDistance setSelectedSegmentIndex:0];
    }
    else if ((([[[NSUserDefaults standardUserDefaults] objectForKey:@"FANGDAOJULI"] isEqualToString:@"1"])))
    {
        [self.segemetDistance setSelectedSegmentIndex:1];
    }
    else
    {
        [self.segemetDistance setSelectedSegmentIndex:2];
    }
    [_btAlert setTitle:NSLocalizedString(@"寻  物",nil) forState:UIControlStateNormal];
    [_btAlert setCenter:CGPointMake(self.view.center.x, _btAlert.center.y)];
}
- (void)textFieldEditChanged:(UITextField *)textField
{
    NSLog(@"textfield text %@",textField.text);
    [nPerpherName setObject:textField.text forKey:self.Peripheralsub.identifier];
    [PeripheralsDetailSettingViewController saveFordicName:nPerpherName];
    
}
+(void)saveFordicName:(NSMutableDictionary *)dic
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"name_dic_perpher"];
}
+(NSMutableDictionary *)getFordicName
{
    NSData *data =[[NSUserDefaults standardUserDefaults] objectForKey:@"name_dic_perpher"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (void)DisConnectBLE
{
    if (self.Peripheralsub.state != CBPeripheralStateDisconnected)
    {
        [self.manager cancelPeripheralConnection:self.Peripheralsub];
    }
}
- (void)BLEwriteValue:(NSString *)command
{
    if (command != nil) {
        [_Peripheralsub writeValue:[command dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_writeCharacteristicsub type:CBCharacteristicWriteWithResponse];
    }
}
- (void)_segment_select:(id)sender
{
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            NSLog(@"近");
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"FANGDAOJULI"];
            [self BLEwriteValue:kSetAlarmDist2m];
            [self setSuccesfullPop];
        }
            break;
        case 1:
        {
            NSLog(@"中");
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"FANGDAOJULI"];
            [self BLEwriteValue:kSetAlarmDist5m];
            [self setSuccesfullPop];
        }
            break;
        case 2:
        {
            NSLog(@"远");
            [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"FANGDAOJULI"];
            [self BLEwriteValue:kSetAlarmDist10m];
            [self setSuccesfullPop];
        }
            break;
        default:
            break;
    }
    
}
- (void)setSuccesfullPop
{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"设置成功",nil)];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
}
-(void)actionDisconnect:(id)sender
{
    NSLog(@"断开");
    
    [self DisConnectBLE];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn)
    {
        NSLog(@"打开防盗");
        [[NSUserDefaults standardUserDefaults] setObject:kOpenString forKey:@"FANGDAO"];
        [self setSuccesfullPop];
        [self BLEwriteValue:kOpenSecurity];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:kCloseString forKey:@"FANGDAO"];
        [self setSuccesfullPop];
        [self BLEwriteValue:kCloseSecurity];
        NSLog(@"关闭防盗");
    }
}
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{

}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == [tabBarController.viewControllers objectAtIndex:0] &&(_isActiveView == YES))
    {
        // Enable all but the last tab.
        return NO;
    }
    
    return YES;
}
- (void)delayPopview
{
//    ViewController *vc = [[ViewController alloc]init];
//    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self presentViewController:vc animated:YES completion:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)popViewFromPeripheralsDetail
{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"正在断开...",nil) maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:250.0/255.0f green:250.0/255.0f blue:250.0/255.0f alpha:0.75f]];
    [self performSelector:@selector(delayPopview) withObject:nil afterDelay:2.0f];
}
#pragma mark Table Delegate Methods
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell_deafult";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell != nil) {
        cell = nil;
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        //cell的四种样式
        //UITableViewCellStyleDefault,       只显示图片和标题
        //UITableViewCellStyleValue1,		显示图片，标题和子标题（子标题在右边）
        //UITableViewCellStyleValue2,		标题和子标题
        //UITableViewCellStyleSubtitle		显示图片，标题和子标题（子标题在下边）
    }
    if (indexPath.section == 0)
    {
        NSLog(@"cell.center.x:%f   y:%f",cell.center.x,cell.center.y);
        [_textFieldName setCenter:CGPointMake(cell.center.x, cell.center.y+3)];
        NSLog(@"_text:%f   y:%f",_textFieldName.center.x,_textFieldName.center.y);
        cell.imageView.image = [UIImage imageNamed:@"device_icon_on"];
        _textFieldName.text = textName;
        [cell.contentView addSubview:_textFieldName];
    }
    else if(indexPath.section == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"防盗",nil);
        [self.switchProtect setCenter:CGPointMake(cell.center.x, cell.textLabel.frame.size.height/2.0)];
        [self.switchProtect setFrame:CGRectMake(self.view.frame.size.width-80.0f,(cell.frame.size.height-30.0)/2.0, 55.0, 30.0)];
        [cell.contentView addSubview:self.switchProtect];
    }
    else if (indexPath.section == 2)
    {
        [_segemetDistance setCenter:CGPointMake(cell.center.x, cell.center.y+5)];
        [cell.contentView addSubview:_segemetDistance];
    }
    else
    {
        tableView.separatorStyle = NO;
        cell.contentView.backgroundColor = _tableview.backgroundColor;
        [_btAlert setCenter:CGPointMake(cell.center.x, cell.center.y+5)];
        [cell.contentView addSubview:_btAlert];
    }
    cell.textLabel.textColor = [UIColor darkGrayColor];//设置标题字体颜色
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;//默认为1
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3) {
        return 0;
    }
    return 20.0f;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return 0.0f;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
//{
//    if (section == 0) {
//        return NSLocalizedString(@"设备名称设置",nil);
//    }
//    else if (section == 1)
//    {
//        return NSLocalizedString(@"防盗设置",nil);
//    }
//    else if (section == 2)
//    {
//        return NSLocalizedString(@"报警距离",nil);
//    }
//    else
//        return nil;
//}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    // 1. The view for the header
//    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
//    
//    // 2. Set a custom background color and a border
//    headerView.backgroundColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
//    headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
//    headerView.layer.borderWidth = 1.0;
//    
//    // 3. Add a label
//    UILabel* headerLabel = [[UILabel alloc] init];
//    headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.textColor = [UIColor whiteColor];
//    headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
//    headerLabel.text = @"This is the custom header view";
//    headerLabel.textAlignment = NSTextAlignmentLeft;
//    
//    // 4. Add the label to the header view
//    [headerView addSubview:headerLabel];
//    
//    // 5. Finally return
//    return headerView;
//}
{
    UILabel * sectionHeader = [[UILabel alloc] initWithFrame:CGRectZero];
    sectionHeader.backgroundColor = [UIColor clearColor];
    sectionHeader.textAlignment = NSTextAlignmentLeft;
    sectionHeader.font = [UIFont boldSystemFontOfSize:15];
    sectionHeader.textColor = [UIColor grayColor];
    
    switch(section) {
        case 0:sectionHeader.text = NSLocalizedString(@"设备名称设置",nil); break;
        case 1:sectionHeader.text = NSLocalizedString(@"防盗设置",nil); break;
        case 2:sectionHeader.text = NSLocalizedString(@"报警距离",nil); break;
        default:break;
    }
    return sectionHeader;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
