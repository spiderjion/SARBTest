//
//  ViewController.m
//  ASITest
//
//  Created by sagles on 12-10-27.
//  Copyright (c) 2012年 sagles. All rights reserved.
//

#define CONVERT_BYTE_TO_M(x) x/(1024.0f*1024.0f)

#define DOWNLOAD_BUTTON_TAG 100
#define STOP_BUTTON_TAG 200

#import "ViewController.h"
#import "BusinessLogicController.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"

@interface ViewController ()<businessLogicDelegate>

@property (retain, nonatomic) IBOutlet UILabel *progressLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *downProgress;
@property (retain, nonatomic) IBOutlet UIButton *downButton;
@property (retain, nonatomic) IBOutlet UILabel *showSizeLabel;

/*!
 @brief     业务逻辑层
 */
@property (nonatomic, retain) BusinessLogicController *blController;

/*!
 @brief     网络检测
 */
@property (nonatomic, retain) Reachability *reachability;

/*!
 @brief     <#abstract#>
 */
@property (nonatomic, copy) NSString *totalSize;

/*!
 @brief     <#abstract#>
 */
@property (nonatomic, copy) NSString *currentSize;

/*!
 @brief     <#abstract#>
 */
@property (nonatomic, assign) long long totalBytes;

/*!
 @brief     <#abstract#>
 */
@property (nonatomic, assign) long long currentBytes;

@end

@implementation ViewController

- (void)dealloc {
    [_progressLabel release];
    [_downProgress release];
    [_downButton release];
    [_reachability release];
    [_totalSize release];
    [_currentSize release];
    [_showSizeLabel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.blController = [BusinessLogicController blControllerWithDelegate:self];
    self.reachability = [Reachability reachabilityForInternetConnection];
    
    self.totalSize = @"0";
    self.currentSize = @"0";
    
    self.downButton.tag = DOWNLOAD_BUTTON_TAG;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSize
{
    long long cur_bytes = self.currentBytes;
    long long tol_bytes = self.totalBytes;
    
    if (tol_bytes > 1024) {
        float total = (float)tol_bytes / 1024.f;
        self.totalSize = [NSString stringWithFormat:@"%.1fM",total];
    }else
    {
        self.totalSize = [NSString stringWithFormat:@"%lldK",tol_bytes];
    }
    
    if (cur_bytes > 1024) {
        float current = (float)cur_bytes / 1024.f;
        self.currentSize = [NSString stringWithFormat:@"%.1fM",current];
    }
    else
    {
        self.currentSize = [NSString stringWithFormat:@"%.2lldK",cur_bytes];
    }
    
    self.showSizeLabel.text = [NSString stringWithFormat:@"%@/%@",self.currentSize,self.totalSize];
}

#pragma mark - user interface


- (IBAction)downLoadAction:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == DOWNLOAD_BUTTON_TAG) {
        if ([self.reachability currentReachabilityStatus] != NotReachable) {
            if (![self.showSizeLabel.text isEqualToString:@"暂停"]) {
                //重置进度条
                [self.downProgress setProgress:0.0f animated:NO];
            }
            
            //开始下载MP3文件
            [_blController getGangNanStyleMP3];
            
            button.tag = STOP_BUTTON_TAG;
        }else
        {
            UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"警告"
                                                              message:@"未连接网络，请检查你的网络连接!"
                                                             delegate:self
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
            [warning show];
            [warning release];
        }
    }else if (button.tag == STOP_BUTTON_TAG) {
        [_blController.request cancel];
        
        button.tag = DOWNLOAD_BUTTON_TAG;
    }
    
}

#pragma mark - businessLogicDelegate

//result
- (void)businessLogicController:(BusinessLogicController *)controller didGetDataFinished:(id)data
{
//    [self.downButton setHidden:NO];
//    [self.downIndicator stopAnimating];
    
    self.showSizeLabel.text = @"完成";
    
    self.downButton.tag = DOWNLOAD_BUTTON_TAG;
}

- (void)businessLogicController:(BusinessLogicController *)controller didGetDataFailed:(NSError *)error
{
    self.downButton.tag = DOWNLOAD_BUTTON_TAG;
    
    if (error.code == requestCancelType) {
        self.showSizeLabel.text = @"暂停";
    }else{
        [self.downProgress setProgress:0.0f];
        self.showSizeLabel.text = @"失败";
        
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"警告"
                                                          message:@"请求错误!"
                                                         delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:nil, nil];
        [warning show];
        [warning release];
    }
}

//download progress
- (void)businessLogicController:(BusinessLogicController *)controller didUpdateDownLoadProgress:(CGFloat)progress
{
    [self.downProgress setProgress:progress animated:YES];
}

- (void)businessLogicController:(BusinessLogicController *)controller didIncrementDownloadSizeBy:(long long)bytes
{
    self.totalBytes = bytes / 1024;
    
    [self showSize];
}

- (void)businessLogicController:(BusinessLogicController *)controller didReceiveBytes:(long long)bytes
{
    self.currentBytes += bytes / 1024;
    
    [self showSize];
}

//upload progress
- (void)businessLogicController:(BusinessLogicController *)controller didUpdateUpLoadProgress:(CGFloat)progress
{
    
}

- (void)businessLogicController:(BusinessLogicController *)controller didIncrementUploadSizeBy:(long long)bytes
{
    
}

- (void)businessLogicController:(BusinessLogicController *)controller didSendBytes:(long long)bytes
{
    
}

@end
