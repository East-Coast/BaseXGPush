//
//  XGPushManger.swift
//  Adriver
//
//  Created by lai A on 2018/12/19.
//  Copyright © 2018 YGX. All rights reserved.
//

import Foundation
import XGPush_Swift

@objc public protocol XGPushMangerDelegate: NSObjectProtocol {

    /// 推送成功回调
    ///
    /// - Parameter notification: 推送数据
    func onNotification(_ notification: NSDictionary)

}

class CCXGPushManger: NSObject, XGPushDelegate {

    weak open var delegate: XGPushMangerDelegate?

    /// 处于前台
    var isOnActive = false

    struct ConfigeDicKey {
        static let appID = "appID"
        static let appKey = "appKey"
    }

    /// 初始化结果
    typealias RegisterCompleteHandler = () -> Void
    private var regCompleteHandler: RegisterCompleteHandler?

//    /// 配置
    private var configeDic = NSDictionary()

    static let sharedInstance = CCXGPushManger()

    func startWithConfig(config: NSDictionary, andRegisterCompleteHandler:@escaping RegisterCompleteHandler) {

        configeDic = config
        regCompleteHandler = andRegisterCompleteHandler

       UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
        startSdk()
    }
//
//    /// 开启信鸽服务
    func startSdk() {
        let appIDValue = String(describing: configeDic.object(forKey: ConfigeDicKey.appID) as? String ?? "")
        let appKeyValue = String(describing: configeDic.object(forKey: ConfigeDicKey.appKey) as? String ?? "")
        assert((!appIDValue.isEmpty && !appKeyValue.isEmpty), "push config error")

        XGPush.defaultManager().isEnableDebug = true
        XGPush.defaultManager().startXG(withAppID: UInt32(appIDValue) ?? 0, appKey: appKeyValue, delegate: self)
    }

    /// 账号绑定
    ///
    /// - Parameter identifier: 账号
    func updateBindedIdentifiers(withIdentifiers: [String], type: XGPushTokenBindType) {
        XGPushTokenManager.default().updateBindedIdentifiers(withIdentifiers, bindType: type)
    }

    /// 角标设置
    func setDeclineBadge() {
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            let newBadge = UIApplication.shared.applicationIconBadgeNumber - 1
            XGPush.defaultManager().setBadge(newBadge)
            UIApplication.shared.applicationIconBadgeNumber = newBadge
        }
    }

    /// 角标重置
    func reSetBadge() {
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
            let newBadge = 0
            XGPush.defaultManager().setBadge(newBadge)
            UIApplication.shared.applicationIconBadgeNumber = newBadge
        }
    }

    //XGPushDelegate
    func xgPushDidFinishStart(_ isSuccess: Bool, error: Error?) {
        if isSuccess {
            regCompleteHandler?()
        }
    }

    func xgPushDidRegisteredDeviceToken(_ deviceToken: String?, error: Error?) {
        print("deviceToken == \(deviceToken ?? "")")
    }

    //前台接收
    func xgPushDidReceiveRemoteNotification(_ notification: Any, withCompletionHandler completionHandler: ((UInt) -> Void)? = nil) {
        isOnActive = true
        if #available(iOS 10.0, *) {
            if notification is UNNotification {
                let UNNotification = notification as? UNNotification
                let dic = UNNotification?.request.content.userInfo ?? [:]
                XGPush.defaultManager().reportXGNotificationInfo(dic)
                onReceivePushPayload(notification: dic)
                completionHandler?(UNNotificationPresentationOptions.alert.rawValue | UNNotificationPresentationOptions.badge.rawValue | UNNotificationPresentationOptions.sound.rawValue)
            }
        } else {
            if notification is NSDictionary {
                let dic = notification as? [AnyHashable: Any] ?? [:]
                XGPush.defaultManager().reportXGNotificationInfo(dic)
                onReceivePushPayload(notification: dic)
                completionHandler?(UIBackgroundFetchResult.newData.rawValue)
            }
        }
    }

    //后台接收
    @available(iOS 10.0, *)
    func xgPush(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse?, withCompletionHandler completionHandler: @escaping () -> Void) {
        isOnActive = false
        if response?.actionIdentifier == UNNotificationDefaultActionIdentifier {
            let dic = response?.notification.request.content.userInfo ?? [:]
            onReceivePushPayload(notification: dic)
        }
        completionHandler()
    }

    private func onReceivePushPayload(notification: [AnyHashable: Any]) {
        dispatchNotification(notification: notification)
    }

    private func dispatchNotification(notification: [AnyHashable: Any]) {

        let dic = notification as NSDictionary

        if delegate != nil && delegate?.responds(to: #selector(XGPushMangerDelegate.onNotification(_:))) ?? false {
            self.delegate?.onNotification(dic)
        }
    }

}
