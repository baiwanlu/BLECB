//
//  PeripheralsCell.h
//  BLECB
//
//  Created by Huang Shan on 15/4/24.
//  Copyright (c) 2015年 Huang Shan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cellHeardImgview;

@property (weak, nonatomic) IBOutlet UILabel *PeripherNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *PerpherConectStatueLabel;

@property (weak, nonatomic) IBOutlet UIButton *PeripherConnectBut;

@property (weak, nonatomic) IBOutlet UIButton *PeripherNextBut;
@end
