//
//  ZFPropagandaCell.m
//  newupop
//
//  Created by Jellyfish on 2017/7/21.
//  Copyright © 2017年 中付支付. All rights reserved.
//

#import "ZFPropagandaCell.h"

@implementation ZFPropagandaCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"ZFPropagandaCell";
    ZFPropagandaCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[ZFPropagandaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

/** 添加子控件 */
- (void)setupSubviews {
    
}


@end
