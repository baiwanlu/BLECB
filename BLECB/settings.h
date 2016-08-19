//
//  settings.h
//  BLECB
//
//  Created by Huang Shan on 15/4/23.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "SVHTTPRequest.h"
extern NSMutableArray *nDevices;
extern NSMutableArray *nServices;
extern NSMutableArray *nCharacteristics;
extern CBCharacteristic *writeCharacteristic;
extern NSMutableArray *_nWriteCharacteristics;

@interface settings : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic)UISwitch *switchmiandarao;
- (void)getVersion;
-(void)setMianDanRaoOpen;

@end
