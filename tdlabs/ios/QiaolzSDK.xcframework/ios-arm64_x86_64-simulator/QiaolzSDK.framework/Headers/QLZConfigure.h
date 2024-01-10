//
//  QLZConfigure.h
//  QLZKit
//
//  Created by lw on 2021/1/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QiaolzSupportedOrientationType) {
    Qiaolz_Landscape,    // 横屏
    Qiaolz_Portrait      // 竖屏
};

@interface QLZConfigure : NSObject

@property (nonatomic, assign) QiaolzSupportedOrientationType orientationType;
@property (nonatomic, copy) void(^customReportViewCallback)(NSString *reportURLString);

/**
 *  初始化俏郎中SDK
 *
 *  @param appKey 注册俏郎中分配的应用唯一标识
 *  @param region region为 所在地区，AS表示东南亚，PRC表示中国大陆。若不传入region。默认是PRC。
 *  @param isTest sdk环境, YES 表示开发环境, NO 表示生产环境
 */
+ (void)startWithAppKey:(NSString *)appKey region:(NSString *)region env:(BOOL)isTest;

/**
*  获取该类的单例实例对象
*  @return  单例实例对象
*/
+ (instancetype)sharedInstance;


/** 开始进入检测页面进行检测
 *  @param token   后端服务器返回的 token
 *  @param viewController   当前控制器, 一般是传 self
 *  @param complete   结果同步回调，成功时resultDic=@{resultCode:0, msg:...}
 */
- (void)startDetectWithToken:(NSString *)token viewController:(UIViewController *)viewController complete:(void(^_Nullable)(NSDictionary * _Nonnull resultDic))complete;


/**
 *  设置环境
 *  @param isTest 是否是测试
 */
- (void)setEnvIsTest:(BOOL)isTest;


/**
 集成测试需要deviceId, 用这个 id 传给你们后端去获取 token
 */
+ (NSString *)deviceIDForIntegration;

@end

NS_ASSUME_NONNULL_END
