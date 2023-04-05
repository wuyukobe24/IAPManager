
//  Created on 2023/3/10.

#import "IAPManager.h"
#import <StoreKit/StoreKit.h>

@interface IAPManager()<SKProductsRequestDelegate, SKRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, copy) NSString *productsId;
@property (nonatomic, copy) void (^success)(NSString *receiptStr);
@property (nonatomic, copy) void (^fail)(NSString *errorMsg);
@end

@implementation IAPManager

static IAPManager *sharedManager = nil;
static dispatch_once_t onceToken;
+ (IAPManager *)sharedInstance {
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}

+ (void)deallocManager {
    onceToken = 0;
    sharedManager = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    NSLog(@"%s",__func__);
}

/// 校验该设备是否可以支付
+ (BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

/// 通过产品id获取产品信息
- (void)requestProductsId:(NSString *)productsId
                  success:(nonnull void (^)(NSString * _Nonnull))success
                     fail:(nonnull void (^)(NSString * _Nonnull))fail {
    self.productsId = productsId;
    if (![IAPManager canMakePayments]) {
        if (fail) {fail(@"当前设备暂不支持充值");}
        return;
    }
    self.success = success;
    self.fail = fail;
    NSLog(@"canMakePayments");
    NSSet *identifiers = [NSSet setWithObjects:productsId, nil];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

/// 添加到购买队列-调起支付
- (void)addPayment:(SKProduct *)product {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
//    if ([payment respondsToSelector:@selector(setApplicationUsername:)]){
//        payment.applicationUsername = userIdentifier;
//    }
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate
/// 获取商品信息代理回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"products request received response");
    NSArray *products = [NSArray arrayWithArray:response.products];
    NSArray *invalidProductIdentifiers = [NSArray arrayWithArray:response.invalidProductIdentifiers];
    
    /// 获取可购买产品id
    if (products.count > 0) {
        for (SKProduct *product in products) {
            NSLog(@"可购买产品id: %@", product.productIdentifier);
            [self addPayment:product];
        }
    } else {
        /// 获取不到产品则手动添加产品到购买队列（确保苹果后台已配置相应产品id）
        SKMutablePayment *payment = [[SKMutablePayment alloc] init];
        // payment.applicationUsername = @"_orderId12"; //透传参数。可以传你自己的订单号，后续可能用得到
        payment.productIdentifier = self.productsId;
        payment.quantity = 1;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    /// 无效的产品id
    [invalidProductIdentifiers enumerateObjectsUsingBlock:^(NSString *invalid, NSUInteger idx, BOOL *stop) {
        NSLog(@"无效的产品id: %@", invalid);
    }];
}

#pragma mark - SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"%s",__func__);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (self.fail) {
        self.fail(error.userInfo[@"msg"] ?: @"充值失败，请重试");
    }
    NSLog(@"%s error userInfos: %@",__func__,error.userInfo);
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased: { /// 交易成功
                NSLog(@"【支付结果】======= 交易成功");
                [self transactionSucceed:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed: { /// 交易失败
                NSLog(@"【支付结果】======= 交易失败");
                [self transactionFailed:transaction];
            }
                break;
            case SKPaymentTransactionStatePurchasing: { /// 商品添加进列表
                NSLog(@"【支付结果】======= 商品添加进列表");
            }
                break;
            case SKPaymentTransactionStateRestored: { /// 已购买过该商品
                NSLog(@"【支付结果】======= 已购买过该商品");
                [self transactionFailed:transaction];
            }
                break;
            case SKPaymentTransactionStateDeferred: { /// 交易延迟
                NSLog(@"【支付结果】======= 交易延迟");
                [self transactionFailed:transaction];
            }
                break;
            default:
            {
                [self transactionFailed:transaction];
            }
                break;
        }
    }
}

/// 交易结束-成功
- (void)transactionSucceed:(SKPaymentTransaction *)transaction {
    /// 这里的URL测试环境下为沙盒url，上线版本中应为苹果后台的URL
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    /// 转化为base64字符串
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *transactionReceipt = [transaction.transactionReceipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSLog(@"交易成功 receiptUrl = %@",receiptUrl);
    NSLog(@"交易成功 receiptData = %@",receiptData);
    NSLog(@"交易成功 receiptString = %@",receiptString);
    NSLog(@"交易成功 transactionReceipt = %@",transactionReceipt);
    if (self.success) {
        self.success(receiptString);
    }
    
//    NSError *jsonError = nil;
//    NSDictionary *info = [NSDictionary dictionaryWithObject:[transaction.transactionReceipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] forKey:@"receipt-data"];
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&jsonError];
//    NSLog(@"交易成功 info = %@",info);
//    NSLog(@"交易成功 jsonData = %@",jsonData);
    
    /// 客户端请求苹果接口进行票据校验（该操作由服务器来验证）
//    NSString *SandboxUrl = @"https://sandbox.itunes.apple.com/verifyReceipt";
//    NSString *url = @"https://buy.itunes.apple.com/verifyReceipt";
//    [self localReceiptVerifyingWithUrl:SandboxUrl AndReceipt:receiptString AndTransaction:transaction];
    // 向自己的服务器验证购买凭证（此处应该考虑将凭证本地保存,对服务器有失败重发机制）
    /**
     服务器要做的事情:
     接收ios端发过来的购买凭证。
     判断凭证是否已经存在或验证过，然后存储该凭证。
     将该凭证发送到苹果的服务器验证，并将验证结果返回给客户端。
     如果需要，修改用户相应的会员权限
     */
    
    // 监听购买结果，当失败和成功时代码中要调用如下代码:
    // 该方法通知苹果支付队列该交易已完成，不然就会已发起相同 ID 的商品购买就会有此项目将免费恢复的提示。
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

/// 交易失败
- (void)transactionFailed:(SKPaymentTransaction *)transaction {
    NSString *errorMsg = [transaction.error localizedDescription];
    if (transaction.error.code == SKErrorPaymentCancelled){
        errorMsg = @"您取消了充值操作";
        NSLog(@"您取消了内购操作");
    }
    if (self.fail) {
        self.fail(errorMsg.length > 0 ? errorMsg : @"充值失败，请重试");
    }
    NSLog(@"内购失败，transactionIdentifier: %@ code:%li msg:%@", transaction.transactionIdentifier,(long)transaction.error.code,transaction.error.localizedDescription);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

/// 请求苹果接口进行票据校验
- (void)localReceiptVerifyingWithUrl:(NSString *)requestUrl AndReceipt:(NSString *)receiptStr AndTransaction:(SKPaymentTransaction *)transaction
{
    NSDictionary *requestContents = @{
                                      @"receipt-data": receiptStr,
                                      };
    NSError *error;
    // 转换为 JSON 格式
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&error];
    NSString *verifyUrlString = requestUrl;
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:verifyUrlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    // 在后台对列中提交验证请求，并获得官方的验证JSON结果
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:storeRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"链接失败");
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else {
            NSError *error;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!jsonResponse) {
                NSLog(@"验证失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
            NSLog(@"验证成功");
            //TODO:取这个json的数据去判断，道具是否下发
        }
    }];
    [task resume];
}

@end

