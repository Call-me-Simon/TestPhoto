//
//  PhotoViewController.m
//  TestPhoto
//
//  Created by Simon on 2018/1/10.
//  Copyright © 2018年 sunshixiang. All rights reserved.
//

#import "PhotoViewController.h"
#import "SelectPhotosViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PhotoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *senderBtn;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选图片";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)sender:(id)sender {
//    [self showActionSheet];
    SelectPhotosViewController *vc = [[SelectPhotosViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    vc.selectPhoto = ^(UIImage *img) {
//        weakSelf.senderBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        weakSelf.senderBtn.layer.cornerRadius = 50;
        weakSelf.senderBtn.layer.masksToBounds = YES;
        [weakSelf.senderBtn setTitle:@"" forState:UIControlStateNormal];
        [weakSelf.senderBtn setBackgroundImage:img forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showActionSheet
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            //            mAlertView(@"", @"请在'设置'中打开相机权限")
            return;
        }
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //            mAlertView(@"", @"照相机不可用")
            return;
        }
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *vc = [[UIImagePickerController alloc] init];
        vc.delegate = self;
        vc.allowsEditing = YES;
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.senderBtn setBackgroundImage:image forState:UIControlStateNormal];
    //图片在这里压缩一下
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
    if (imageData.length/1024 > 1024*20)
    {
//        mAlertView(@"温馨提示", @"请重新选择一张不超过20M的图片");
    }
    else
    {
//        _imageType = [NSData typeForImageData:imageData];
//        _imageBase64 = [imageData base64EncodedString];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];

}

@end
