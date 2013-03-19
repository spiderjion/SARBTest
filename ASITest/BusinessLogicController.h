//
//  BusinessLogicController.h
//  ASITest
//
//  Created by sagles on 12-10-27.
//  Copyright (c) 2012年 sagles. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    sandboxPathType = 100,
    documentPathType,
    cachePathType,
    libratyPathType,
    tmpPathType,
}FilePathType;//文件路径type

typedef enum
{
    requestCancelType = 1000,
    requestTimeoutType,
    requestFailWithServerCodeType
}RequestErrorType;//请求错误类型

@class BusinessLogicController;
@class ASIHTTPRequest;
@class ASIFormDataRequest;

@protocol businessLogicDelegate <NSObject>
@optional

- (void)businessLogicControllerDidStartRequest;

- (void)businessLogicController:(BusinessLogicController *)controller didGetDataFinished:(id)data;
- (void)businessLogicController:(BusinessLogicController *)controller didGetDataFailed:(NSError *)error;

- (void)businessLogicController:(BusinessLogicController *)controller didUpdateDownLoadProgress:(CGFloat)progress;
- (void)businessLogicController:(BusinessLogicController *)controller didIncrementDownloadSizeBy:(long long)bytes;
- (void)businessLogicController:(BusinessLogicController *)controller didReceiveBytes:(long long)bytes;

- (void)businessLogicController:(BusinessLogicController *)controller didUpdateUpLoadProgress:(CGFloat)progress;
- (void)businessLogicController:(BusinessLogicController *)controller didIncrementUploadSizeBy:(long long)bytes;
- (void)businessLogicController:(BusinessLogicController *)controller didSendBytes:(long long)bytes;

@end

@interface BusinessLogicController : NSObject

/*!
 @brief     ASI请求，GET使用。
 */
@property (nonatomic, retain) ASIHTTPRequest *request;

/*!
 @brief     ASI请求，POST使用。
 */
@property (nonatomic, retain) ASIFormDataRequest *postRequest;

/*!
 @brief     代理
 */
@property (nonatomic, assign) id<businessLogicDelegate> delegate;


/*!
 @brief     <#abstract#>
 @return    <#return#>
 */
+ (id)blControllerWithDelegate:(id)del;

/*!
 @brief     <#abstract#>
 @return    <#return#>
 */
+ (id)blController;

/*!
 @brief     <#abstract#>
 @param     <#param#> <#param description#>
 @return    <#return#>
 */
- (id)initWithDelegate:(id)del;

/*!
 @brief     停止请求
 @return    void
 */
- (void)cancelRequest;


/*!
 @brief     获取MP3数据
 @return    void
 */
- (void)getGangNanStyleMP3;

/*!
 @brief 获取路径
 */
- (NSString *)pathWithType:(FilePathType)type;

@end
