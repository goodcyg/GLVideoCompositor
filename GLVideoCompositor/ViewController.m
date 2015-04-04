//
//  ViewController.m
//  GLVideoCompositor
//
//  Created by Mikhail Grushin on 04/04/15.
//  Copyright (c) 2015 Mikhail Grushin. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "UIButton+PHAsset.h"

typedef NS_ENUM(NSUInteger, GMAVideoNumber) {
    GMAFirstVideo = 1,
    GMASecondVideo = 2
};

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *firstVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *secondVideoButton;
@property (weak, nonatomic) IBOutlet UIScrollView *transitionsScrollView;

@property (nonatomic, strong) AVAsset *firstVideoAsset;
@property (nonatomic, strong) AVAsset *secondVideoAsset;

@property (nonatomic, assign) GMAVideoNumber currentlyPickingNumber;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private interface

- (void)pickVideoWithNumber:(GMAVideoNumber)videoNumber {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    
    [self presentViewController:picker animated:YES completion:^{
        self.currentlyPickingNumber = videoNumber;
    }];
}

#pragma mark - Actions

- (IBAction)playAction:(id)sender {
}

- (IBAction)chooseFirstVideo:(id)sender {
    if (self.firstVideoAsset) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose video"
                                                        message:@"Do you want to pick other first video?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = GMAFirstVideo;
        [alert show];
    } else {
        [self pickVideoWithNumber:GMAFirstVideo];
    }
}

- (IBAction)chooseSecondVideo:(id)sender {
    if (self.secondVideoAsset) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Choose video"
                                                        message:@"Do you want to pick other second video?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        alert.tag = GMASecondVideo;
        [alert show];
    } else {
        [self pickVideoWithNumber:GMASecondVideo];
    }
}

#pragma mark - Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self pickVideoWithNumber:alertView.tag];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = info[UIImagePickerControllerReferenceURL];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    PHAsset *ph_asset = [result firstObject];
    [[PHImageManager defaultManager] requestAVAssetForVideo:ph_asset options:nil resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if (asset) {
            if (self.currentlyPickingNumber == GMAFirstVideo) {
                self.firstVideoAsset = asset;
                [self.firstVideoButton configureImageWithPHAsset:ph_asset];
            } else if (self.currentlyPickingNumber == GMASecondVideo) {
                self.secondVideoAsset = asset;
                [self.secondVideoButton configureImageWithPHAsset:ph_asset];
            }
        }
        
        self.currentlyPickingNumber = 0;
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end