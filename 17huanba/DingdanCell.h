//
//  DingdanCell.h
//  一起换吧
//
//  Created by Chen Hao on 13-4-18.
//  Copyright (c) 2013年 Chen Hao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface DingdanCell : UITableViewCell
@property(retain,nonatomic)AsyncImageView *gdimg;
@property(retain,nonatomic)UILabel *nameL;
@property(retain,nonatomic)UILabel *bianhaoL; //订单编号
//@property(retain,nonatomic)UILabel *sell_type; //交易方式
@property(retain,nonatomic)UILabel *numberL; //订购数量
@property(retain,nonatomic)UILabel *toNameL; //对方名字
@property(retain,nonatomic)UILabel *state; //交易状态
@property(retain,nonatomic)UIButton *xiangqingBtn; //订单详情
//@property(retain,nonatomic)UIButton *shangjiaBtn; //上架按钮
//@property(retain,nonatomic)UIButton *editBtn; //下架按钮
//@property(retain,nonatomic)UIButton *shareBtn; //下架按钮

@end
