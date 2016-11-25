//
//  JPushHelper.m
//  LiLian
//
//  Created by hello on 2016/11/24.
//  Copyright © 2016年 smart_small. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NetWorkTool.h"


static NSString * kJPushAppKey = @"b4a92ed3356052d09598e567";
static NSString * kJPushIdentifier = @"c9f0412b00c7dc40b026ebf5";
static NSString * channel = @"Publish channel";
static BOOL isProduction = FALSE;

#import "JPushHelper.h"
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>


#import "NSString+Category.h"
#ifdef DEBUG
#define LRString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define JPHelperLog(...) printf("%s: %s 第%d行: %s\n\n",[[NSString lr_stringDate] UTF8String], [LRString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

#else
#define JPHelperLog(...)
#endif




#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


@interface JPushHelper()<JPUSHRegisterDelegate>{
    
    NSString * _devicetToken;
    
}

@end


@implementation JPushHelper


+ (JPushHelper *)shareManager{
    static JPushHelper *sharedObject = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [[[self class] alloc] init];
        }
    });
    
    return sharedObject;
}
/// 在应用启动时调用此方法注册
- (void)startWithLaunchOptions:(NSDictionary *)launchOptions{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:kJPushAppKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:kJPushIdentifier];
    
    //2.1.9版本新增获取registration id block接口。
    
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            JPHelperLog(@"registrationID获取成功：%@",registrationID);
            
            [self sendRegId:registrationID];
        }
        else{
            JPHelperLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    
}


- (void)sendRegId: (NSString *)regId{

    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"audience"] = regId;

    [[NetWorkTool shareManager]postJSONWithUrl:@"http://192.168.0.101:8081/lilian_web/index.php/Home/jpush/pushMess" parmas:params successData:^(id json) {
        
    } failure:^(NSError *error) {
        
    }];

}

//注册设备deviceToken
- (void)registerDeviceToken:(NSData *)deviceToken{
    
    _devicetToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                      stringByReplacingOccurrencesOfString: @">" withString: @""]
                     stringByReplacingOccurrencesOfString: @" " withString: @""];
    JPHelperLog(@"_devicetToken=====%@",_devicetToken);
    JPHelperLog(@"deviceToken===%@",deviceToken);
    [JPUSHService registerDeviceToken:deviceToken];
    
}
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo{
    // apn 内容获取：
    // 取得 APNs 标准信息内容
    [JPUSHService handleRemoteNotification:userInfo];
}
//iOS10以下版本时
- (void)didReceiveRemoteNotificationIOS10:(NSDictionary *)userInfo{

    
    JPHelperLog(@"2-1 didReceiveRemoteNotification remoteNotification = %@", userInfo);
    // apn 内容获取：
    [JPUSHService handleRemoteNotification:userInfo];
    
    
    JPHelperLog(@"2-2 didReceiveRemoteNotification remoteNotification = %@", userInfo);
    if ([userInfo isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = userInfo[@"aps"];
        NSString *content = dict[@"alert"];
        JPHelperLog(@"content = %@", content);
    }
    


}

- (void)showLocalNotificationAtFront:(UILocalNotification *)notification{
    
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        JPHelperLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        
        //  [rootViewController addNotificationCount];
        
    }
    else {
        // 判断为本地通知
        JPHelperLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        JPHelperLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        // [rootViewController addNotificationCount];
        
    }
    else {
        // 判断为本地通知
        JPHelperLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}


@end
