//
//  BusinessLogicController.m
//  ASITest
//
//  Created by sagles on 12-10-27.
//  Copyright (c) 2012年 sagles. All rights reserved.
//

#import "BusinessLogicController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

static NSString *getMP3RequestURL = @"http://oss.aliyuncs.com/breath/101%20Sneak%20Peek%20%28HD%29.mp4";

static NSString *mp3Name = @"name.mp3";


@interface BusinessLogicController ()<ASIHTTPRequestDelegate,ASIProgressDelegate>

@end

@implementation BusinessLogicController

#pragma mark - life cycle

- (void)dealloc
{
    [self cancelRequest];
    [_request release];
    [_postRequest release];
    [super dealloc];
}

+ (id)blControllerWithDelegate:(id)del
{
    return [[[self alloc] initWithDelegate:del] autorelease];
}

+ (id)blController
{
    return [[[self alloc] init] autorelease];
}

- (id)initWithDelegate:(id)del
{
    if (self = [self init]) {
        self.delegate = del;
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - public methods

- (NSString *)pathWithType:(FilePathType)type
{
    switch (type) {
        case sandboxPathType:
            return NSHomeDirectory();
            break;
        case documentPathType:
            return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        case cachePathType:
            return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        case libratyPathType:
            return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        case tmpPathType:
            return NSTemporaryDirectory();
        default:
            break;
    }
}

#pragma mark - private methods

- (BOOL)isFileExist:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExist = [manager fileExistsAtPath:path];
    
    NSError *error = nil;
    if (isExist) {
        [manager removeItemAtPath:path error:&error];
    }
    
    if (error) {
        NSLog(@"remove file error : %@",error);
    }
    
    return isExist;
}

#pragma mark - requestMethods

- (void)cancelRequest
{
    [self.request clearDelegatesAndCancel];
    [self.postRequest clearDelegatesAndCancel];
}

- (void)getGangNanStyleMP3
{
    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:getMP3RequestURL]];
    
    //设置下载完的目录
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self pathWithType:documentPathType],mp3Name];
    NSLog(@"filePath = %@",filePath);
    [self isFileExist:filePath];
    [self.request setDownloadDestinationPath:filePath];
    
    //设置下载的缓存目录
    NSString *tmpPath = [NSString stringWithFormat:@"%@/%@.download",[self pathWithType:tmpPathType],mp3Name];
    NSLog(@"tmpPath = %@",tmpPath);
    [self.request setTemporaryFileDownloadPath:tmpPath];
    
    //设置允许断点续传
    [self.request setAllowResumeForFileDownloads:YES];
    
    self.request.delegate = self;
    self.request.downloadProgressDelegate = self;
    [self.request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    if ([_delegate respondsToSelector:@selector(businessLogicControllerDidStartRequest)]) {
        [_delegate businessLogicControllerDidStartRequest];
    }
}

- (void)requestRedirected:(ASIHTTPRequest *)request
{
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"request did finish!");
    
    if ([_delegate respondsToSelector:@selector(businessLogicController:didGetDataFinished:)]) {
        [_delegate businessLogicController:self didGetDataFinished:request.responseData];
    }
    
    [self cancelRequest];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request did fail!");
    
    NSError *error = nil;
    if (request.error.code == ASIRequestCancelledErrorType) {
        error = [NSError errorWithDomain:@"连接被取消" code:requestCancelType userInfo:nil];
    }else{
        error = [NSError errorWithDomain:@"连接超时" code:requestTimeoutType userInfo:nil];
    }
    
    if ([_delegate respondsToSelector:@selector(businessLogicController:didGetDataFailed:)]) {
        [_delegate businessLogicController:self didGetDataFailed:error];
    }
    
    [self cancelRequest];
}

#pragma mark - ASIProgressDelegate

- (void)setProgress:(float)newProgress
{
    if (self.request)
    {
        if ([_delegate respondsToSelector:@selector(businessLogicController:didUpdateDownLoadProgress:)]) {
            [_delegate businessLogicController:self didUpdateDownLoadProgress:newProgress];
        }
    }
    else if (self.postRequest)
    {
        if ([_delegate respondsToSelector:@selector(businessLogicController:didUpdateUpLoadProgress:)]) {
            [_delegate businessLogicController:self didUpdateUpLoadProgress:newProgress];
        }
    }
}

- (void)request:(ASIHTTPRequest *)request incrementDownloadSizeBy:(long long)newLength
{
    if ([_delegate respondsToSelector:@selector(businessLogicController:didIncrementDownloadSizeBy:)]) {
        [_delegate businessLogicController:self didIncrementDownloadSizeBy:newLength];
    }
}

- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength
{
    if ([_delegate respondsToSelector:@selector(businessLogicController:didIncrementUploadSizeBy:)]) {
        [_delegate businessLogicController:self didIncrementUploadSizeBy:newLength];
    }
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    if ([_delegate respondsToSelector:@selector(businessLogicController:didSendBytes:)]) {
        [_delegate businessLogicController:self didSendBytes:bytes];
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    if ([_delegate respondsToSelector:@selector(businessLogicController:didReceiveBytes:)]) {
        [_delegate businessLogicController:self didReceiveBytes:bytes];
    }
}

@end
