# JPushHelper
极光推送help

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//注册极光推送
[[JPushHelper shareManager]startWithLaunchOptions:launchOptions];

}
//取消红点
- (void)applicationWillEnterForeground:(UIApplication *)application {
[application setApplicationIconBadgeNumber:0];
[application cancelAllLocalNotifications];
// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
//注册deviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
[[JPushHelper shareManager]registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
LRLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
// iOS10 接受消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

[[JPushHelper shareManager]didReceiveRemoteNotification:userInfo];

}
//iOS10以下版本时 接受消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{

[[JPushHelper shareManager]didReceiveRemoteNotificationIOS10:userInfo];
completionHandler(UIBackgroundFetchResultNewData);

if ([userInfo isKindOfClass:[NSDictionary class]])
{
NSDictionary *dict = userInfo[@"aps"];
NSString *content = dict[@"alert"];
LRLog(@"content = %@", content);
}

if (application.applicationState == UIApplicationStateActive)
{
// 程序当前正处于前台
}
else if (application.applicationState == UIApplicationStateInactive)
{
// 程序处于后台
}
}
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
[[JPushHelper shareManager]showLocalNotificationAtFront:notification];

}
