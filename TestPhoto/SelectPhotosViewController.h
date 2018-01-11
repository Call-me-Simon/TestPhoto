//
//  SelectPhotosViewController.h
//  TestPhoto
//
//  Created by Simon on 2018/1/10.
//  Copyright © 2018年 sunshixiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectPhotosViewController : UIViewController

@property (nonatomic, copy) void (^selectPhoto)(UIImage *);

@end
