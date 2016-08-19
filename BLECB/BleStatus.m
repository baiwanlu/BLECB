//
//  BleStatus.m
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import "BleStatus.h"

@implementation BleStatus
@synthesize BleBaterry,BleName,Blesignal,BleUUID;

-(id)init
{
    if (BleBaterry != nil)
    {
        BleBaterry = nil;
        BleName = nil;
        Blesignal = nil;
        BleUUID = nil;
    }
    return nil;
}
@end
