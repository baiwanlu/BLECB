//
//  BleStatus.h
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BleStatus : NSObject
{
    NSString *BleName;
    NSString *BleUUID;
    NSString *Blesignal;
    NSString *BleBaterry;
    
}
@property(nonatomic,copy) NSString *BleName;
@property(nonatomic,copy) NSString *BleUUID;
@property(nonatomic,copy) NSString *Blesignal;
@property(nonatomic,copy) NSString *BleBaterry;
@end
