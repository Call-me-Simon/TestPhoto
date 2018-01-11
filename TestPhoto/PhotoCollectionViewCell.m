//
//  PhotoCollectionViewCell.m
//  TestPhoto
//
//  Created by Simon on 2018/1/10.
//  Copyright © 2018年 sunshixiang. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import <Masonry.h>

@implementation PhotoCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

-(void)initView
{
//    self.contentView.backgroundColor = [UIColor cyanColor];
    _iconImageView = ({
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.backgroundColor = [UIColor clearColor];
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        imageview;
    });
    [self.contentView addSubview:_iconImageView];
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.width.mas_lessThanOrEqualTo(self.contentView.mas_width);
        make.height.mas_lessThanOrEqualTo(self.contentView.mas_height);
    }];
}

@end
