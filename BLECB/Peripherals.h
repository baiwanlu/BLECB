//
//  Peripherals.h
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeripheralsCell.h"
#import "BleStatus.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SVProgressHUD.h"
#import "DICNAME.h"
#import "SVHTTPRequest.h"

/*
 1)	发送找寻移动电源命令：@SearchDevice#
 2)	发送打开免打扰功能命令：@OpenNoDisturb#
 3)	发送关闭免打扰功能命令：@CloseNoDisturb#
 4)	发送打开防盗功能命令：@OpenSecurity#
 5)	发送关闭防盗功能命令：@CloseSecurity#
 6)	设定报警距离为2米的命令：@SetAlarmDist2m#
 7)	设定报警距离为5米的命令：@SetAlarmDist5m#
 8)	设定报警距离为10米的命令：@SetAlarmDist10m#
 9)	连接时同步设置信息的命令：@TTSetABC#
 a)	其中A代表免打扰的设置：“0”：关闭；“1”：打开；
 b)	其中B代表防盗开关设置：“0”：关闭；“1”：打开；
 c)	 其中C代表报警距离设置：“0”：近；“1”：中；“2”：远。
 
 */
static NSString *const  objeKEYper = @"PERHAR";

//#define MY_TEST

#ifdef MY_TEST
/*第二版*/
//static NSString *const kCharacteristicWirteUUID = @"6F410002-B6A5-F495-E1A0-E60F26DDCB9F";
//
//static NSString *const kCharacteristicUUID = @"6F410003-B6A5-F495-E1A0-E60F26DDCB9F";

static NSString *const kServiceUUID = @"6F410001-B6A5-F495-E1A0-E60F26DDCB9F";

/*第一版*/
static NSString *const kCharacteristicWirteUUID = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";

static NSString *const kCharacteristicUUID = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
//
//static NSString *const kServiceUUID = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";//
#else
/*第二版*/
static NSString *const kCharacteristicWirteUUID = @"6F410002-B6A5-F495-E1A0-E60F26DDCB9F";

static NSString *const kCharacteristicUUID = @"6F410003-B6A5-F495-E1A0-E60F26DDCB9F";

static NSString *const kServiceUUID = @"6F410001-B6A5-F495-E1A0-E60F26DDCB9F";

#endif


static NSString *const kSearchDevice = @"@SearchDevice#";

static NSString *const kOpenNoDisturb = @"@OpenNoDisturb#";

static NSString *const kOpenSecurity = @"@OpenSecurity#";

static NSString *const kCloseSecurity = @"@CloseSecurity#";

static NSString *const kSetAlarmDist2m = @"@SetAlarmDist2m#";

static NSString *const kSetAlarmDist5m = @"@SetAlarmDist5m#";

static NSString *const kSetAlarmDist10m = @"@SetAlarmDist10m#";

static NSString *const kTTSetABC = @"@TTSetABC#";

static NSString *const kRevStartAlarm = @"@StartAlarm#";

static NSString *const kSearcePhone = @"@StartSearchPhone#";

static NSString *const kRevTackPhotos = @"@TakePhotos#";

static NSString *const kRevStoptAlarm = @"@StopAlarm#";

static NSString *const  nNoticeTakePhotos = @"NTtackePhontos";

static NSString *const  kOpenString = @"1";

static NSString *const  kCloseString = @"0";

@interface Peripherals : UIViewController<UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,CBPeripheralDelegate>
- (IBAction)BLEConnectAction:(id)sender;
- (IBAction)PeripherSettingAction:(id)sender;
- (void)BLEwriteValue:(NSString *)command per:(CBPeripheral *)p charact:(CBCharacteristic *)writechararcter;
//@property (nonatomic, strong) CBCentralManager *manager;
//@property (nonatomic, strong) CBPeripheral *peripheral;
//@property (nonatomic,strong) UIActivityIndicatorView *activity;
//@property (strong,nonatomic) NSMutableArray *nDevices;
//@property (strong,nonatomic) NSMutableArray *nServices;
//@property (strong,nonatomic) NSMutableArray *nCharacteristics;
//@property (strong ,nonatomic) CBCharacteristic *writeCharacteristic;

@end
