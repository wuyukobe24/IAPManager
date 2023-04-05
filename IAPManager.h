
//  苹果内购

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IAPManager : NSObject

+ (IAPManager *)sharedInstance;

+ (void)deallocManager;

/// 校验该设备是否可以支付
+ (BOOL)canMakePayments;

/// 通过产品id获取产品信息
/// - Parameter productsId: 产品id
/// - Parameter success: success
/// - Parameter fail: fail
- (void)requestProductsId:(NSString *)productsId
                  success:(void (^)(NSString *receiptStr))success
                     fail:(void (^)(NSString *errorMsg))fail;

@end

NS_ASSUME_NONNULL_END
