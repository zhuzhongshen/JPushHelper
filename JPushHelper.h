//
//  JPushHelper.h
//  LiLian
//
//  Created by hello on 2016/11/24.
//  Copyright © 2016年 smart_small. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface JPushHelper : NSObject


//单利模式
+ (JPushHelper *)shareManager;


/// 在应用启动时调用此方法注册
- (void)startWithLaunchOptions:(NSDictionary *)launchOptions;
//注册设备deviceToken
- (void)registerDeviceToken:(NSData *)deviceToken;

//iOS10版本时 接受消息
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

//iOS10以下版本时 接受消息
- (void)didReceiveRemoteNotificationIOS10:(NSDictionary *)userInfo;


- (void)showLocalNotificationAtFront:(UILocalNotification *)notification;


// 关闭接收消息通知
+ (void)unregisterRemoteNotifications;
// default is YES
// 使用友盟提供的默认提示框显示推送信息
+ (void)setAutoAlertView:(BOOL)shouldShow;

// 应用在前台时，使用自定义的alertview弹出框显示信息
+ (void)showCustomAlertViewWithUserInfo:(NSDictionary *)userInfo;


@end
