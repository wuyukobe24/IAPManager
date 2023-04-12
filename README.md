# IAPManager
## 2023最新iOS接入苹果内购(IAP)和问题记录（App Store已审核通过）

最近项目由于审核原因需要接入苹果内购，在阅读了大量文章和苹果文档后，比较顺利的完成了内购的开发和提审（目前已审核通过）。这里记录下整个开发流程中相关的内购信息配置、内购代码开发和一些踩过的坑。

>目录：
一、接受《付费应用程序协议》
二、在 App Store Connect 中配置 App 内购买项目
三、在 Xcode 中启用 App 内购买项目
四、创建沙盒账号，用户测试 App 内购买项目
五、编写代码调试购买流程
六、服务端向App Store验证收据
七、在 App Store 上发布
八、问题记录


## 一、接受《付费应用程序协议》
#### 1、签署付费协议
要完成内购开发， 首先需要在App Store Connect 中接受《付费应用程序协议》。且只有账户持有人才能签署该协议。[签署地址](https://appstoreconnect.apple.com/agreements/#/)
#### 2、税务和银行业务信息录入
完成签署协议之后，需要完成银行账户和报税表等信息的录入。建议让公司财务去完成这些信息的填写。有关银行账户信息如下：

![1](https://upload-images.jianshu.io/upload_images/4037795-2022620d7f0da1dd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/620)

报税表填写参考：1.问你是不是美国居民，选择NO。2. 有没有在美国从事商业性活动，选择NO。其他的按照实际情况填写即可。

以上填写完成之后提交苹果审核。一般1-3个工作日即可审核通过，实测一天就审核通过了。切记一定要先填写信息，保证审核通过，不然后续的内购开发流程无法调试（获取不到配置的产品）。正常审核通过之后，付费App的右侧会显示“有效”的状态。

![2](https://upload-images.jianshu.io/upload_images/4037795-5d252427b8646cc9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 二、在 App Store Connect 中配置 App 内购买项目
这部分属于在苹果后台配置App内可以购买的产品，比如：会员，金币等产品。每个 App 内购买项目都必须关联一个 App，并且只能用于该 App。而在一个 App 内，App 内购买项目可用于该 App 的各个平台版本（iOS、macOS、Apple tvOS）。

配置路径为：打开 [App Store Connect 后台](https://appstoreconnect.apple.com/apps)，选择要配置的App，左侧边栏，选择“App 内购买项目”，点击右侧“+”，输入产品的信息：
* 类型：消耗性项目/非消耗性项目，比如金币属于消耗性项目。
* 参考名称：产品名称，比如“10个金币”。
* 产品ID：产品的唯一ID，这个比较重要，因为App内匹配购买产品的时候以这个ID为准，而且一个产品用过之后，不能再重复创建。建议使用bundle id+产品名称来命名。

点击“创建”之后，会生成一条产品信息。点击进入，在内部可以设置产品的其他信息，比如：销售范围、价格时间表（即定价）、税务类别、App Store 本地化版本（就是该产品的一些描述信息）、App Store 推广（可选）和审核信息（审核信息中要上传截图和备注，备注中可以填写用于测试购买产品的沙箱账号，沙箱账号下面会介绍）。

以上信息一定要填写完整，存储之后要达到“准备提交”状态。不然测试购买时，依然会获取不到该产品。

创建的产品没审核之前，都可以随时“移除”，所以不用担心产品创建出现错误。

![3](https://upload-images.jianshu.io/upload_images/4037795-7f876ee413d55d15.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/840)


## 三、在 Xcode 中启用 App 内购买项目
这部分属于在Xcode中去添加“In-App Purchase”配置项。配置路径为：选中App的target，选择“Signing & Capabilities”，点击“+ Capability”，输入“In-App Purchase”，在搜索结果中双击“In-App Purchase“即可。

要确保你的开发证书和App Store Connect 中App 中的bundle id是一致的。只有这样才能测试购买流程。

![4.png](https://upload-images.jianshu.io/upload_images/4037795-55cff062a3801ac5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/640)

###### 备注：后来发现这个功能配置 Capablity 已经转移到[苹果开发者后台 Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/certificates/list) 中了，在对应的App Identifiers 中已经默认配置好 In-App Purchase 了，不用单独配置了。

![](https://upload-images.jianshu.io/upload_images/4037795-b50e53ac20e05d91.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/640)


## 四、创建沙盒账号，用户测试 App 内购买项目
在开发阶段测试购买流程可以使用沙盒账号。沙盒账号可以在App Store Connect 后台配置，购买时不会真正的付款即可购买成功。苹果审核时，用的他们自己的沙盒账号。

配置路径：[App Store Connect 后台](https://appstoreconnect.apple.com/apps)，选择“用户和访问”，点击”沙盒测试员“。输入对应的姓名，电子邮箱、密码和国家。点击“创建”即可。

注意：这个邮箱是真实的电子邮箱，且没有注册过apple id的邮箱。一旦创建无法修改信息，只能删除。其中通过编辑，选择“中断此测试员的购买流程”可以调试中断购买流程。

![5](https://upload-images.jianshu.io/upload_images/4037795-9d36a5299c011657.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## 五、编写代码调试购买流程
以上信息配置完成之后，就可以编写代码进行调试了。
#### 1、引入苹果内购框架 StoreKit
```
#import <StoreKit/StoreKit.h>
```
#### 2、校验设备是否支持内购支付
```
[SKPaymentQueue canMakePayments];
```
#### 3、从苹果后台获取（流程二）配置的产品是否存在
```
// productsId 为 App Store Connect 后台配置的产品ID
NSSet *identifiers = [NSSet setWithObjects:productsId, nil];
SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
productsRequest.delegate = self;
[productsRequest start];
```
#### 4、遵守 SKProductsRequestDelegate 协议，回调中获取可购买的产品信息
获取的信息包括：
* `response.products`：可购买的产品列表。
* `response.invalidProductIdentifiers`：无效的产品信息。

这个地方有个巨大深坑：如果前面没有签署付费协议、银行账户和报税表没有完成审核、配置产品的信息状态不是“准备提交”状态，只要有一条不满足，就获取不到产品信息。即使以上信息都达到要求，也有可能获取不到产品信息！！！我就遇见了这种情况，最后在阅读了大量文章后，有篇文章建议如果确认后台已经配置好产品信息，可以手动将产品信息添加到购买队列（参考下面第5步中添加产品到购买队列），执行一次购买之后，当前回调方法就可以正常获取产品信息了。
```
#pragma mark - SKProductsRequestDelegate
/// 获取商品信息代理回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
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
```
遵守`SKRequestDelegate` 协议，可以获取请求完成和失败的方法：
```
#pragma mark - SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"%s",__func__);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s",__func__);
    NSLog(@"error userInfos: ",error.userInfo);
    NSLog(@"error _domain: ",error.domain);
}
```
#### 5、获取到信息之后，添加产品到购买队列
```
/// 添加到购买队列-调起支付
- (void)addPayment:(SKProduct *)product {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
```
如果未获取产品信息，则手动创建产品并添加到购买队列
```
/// 获取不到产品则手动添加产品到购买队列（确保苹果后台已配置相应产品id）
SKMutablePayment *payment = [[SKMutablePayment alloc] init];
/// 透传参数。可以传你自己的订单号，后续可能用得到
// payment.applicationUsername = @"_orderId12";
/// productsId 为 App Store Connect 后台配置的产品ID
payment.productIdentifier = productsId;
payment.quantity = 1;
[[SKPaymentQueue defaultQueue] addPayment:payment];
```
将产品添加到购买队列后，则会提示在弹窗中输入沙盒账号，输入沙盒账号之后，会将账号保存到设置- App Store -沙盒账户。此后会调起苹果支付的弹窗，点击购买或者取消弹窗，即可在流程6回调方法中获取到相应的支付结果。
#### 6、添加观察者 SKPaymentTransactionObserver，监听后续的支付结果
```
/// 添加观察者
[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
```
```
/// 移除观察者
- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    NSLog(@"%s",__func__);
}
```
代理方法监听后续的支付结果：
```
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
```
#### 7、交易成功之后，将获取的交易凭证发送给后端，让后端去苹果服务器进行校验
```
/// 交易结束-成功
- (void)transactionSucceed:(SKPaymentTransaction *)transaction {
    /// 这里的URL测试环境下为沙盒url，上线版本中应为苹果后台的URL
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    /// 转化为base64字符串
    NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSLog(@"交易成功 receiptUrl = %@",receiptUrl);
    NSLog(@"交易成功 receiptData = %@",receiptData);
    NSLog(@"交易成功 receiptString = %@",receiptString);
    
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
```
同时处理交易失败：
```
/// 交易失败
- (void)transactionFailed:(SKPaymentTransaction *)transaction {
    if (transaction.error.code == SKErrorPaymentCancelled){
        NSLog(@"您取消了内购操作.");
    } else {
        NSLog(@"内购失败，原因：%@",[transaction.error localizedDescription]);
    }
    NSLog(@"transactionFailed with tid: %@ and code:%li and msg:%@", transaction.transactionIdentifier,(long)transaction.error.code,transaction.error.localizedDescription);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
```
###### 备注：
1、不管交易成功还是失败，处理完逻辑一定要调用  `[[SKPaymentQueue defaultQueue] finishTransaction:transaction];` 告诉苹果已完成当前操作，不然之后再购买就会失败！
2、共享密钥 password 获取路径：App Store Connect 后台-用户和访问-共享密钥。[获取共享密钥](https://help.apple.com/app-store-connect/#/devf341c0f01)
3、这里获取到的交易凭证比较长，如果要是发给后端先调试逻辑的话一定要复制完整。大约有5000个字节（搞不懂为啥要这么长）。参考如下：
```
{"receipt-data":"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",
"password":"",
"exclude-old-transactions":true 
}
```

#### 8、这里提供一个方法，客户端可以手动去苹果服务器进行票据校验（只是测试而已，建议交给后端去做校验）
```
/// 请求苹果接口进行票据校验
- (void)localReceiptVerifyingWithUrl:(NSString *)requestUrl AndReceipt:(NSString *)receiptStr AndTransaction:(SKPaymentTransaction *)transaction
{
    NSDictionary *requestContents = @{@"receipt-data": receiptStr,};
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
```

以上就是有关苹果内购的相关代码。
完整代码可参考：[IAPManager](https://github.com/wuyukobe24/IAPManager)

![支付弹窗](https://upload-images.jianshu.io/upload_images/4037795-d30af59b257e4292.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/340)

## 六、服务端向App Store验证收据
规则：首先使用生产 URL 验证您的收据；如果您收到状态代码21007，请继续使用沙盒 URL 进行验证。遵循此方法可确保您在测试应用程序、由 App Review 审查或在 App Store 中上架时不必在 URL 之间切换。调用规则参考[苹果文档](https://developer.apple.com/documentation/appstorereceipts/verifyreceipt#sandbox-url)。

##### 请求接口URL和出入参数如下：
###### 1、URL
* `URL`：POST https://buy.itunes.apple.com/verifyReceipt
* `Sandbox URL` ： POST https://sandbox.itunes.apple.com/verifyReceipt

###### 2、HTTP Body
* `receipt-data`：（必需的）Base64 编码的收据数据。
* `password`：您的应用程序的共享密钥，它是一个十六进制字符串。有关共享密钥的更多信息，请参阅[生成收据验证码](https://help.apple.com/app-store-connect/#/devf341c0f01)。
* `exclude-old-transactions`：将此值设置为 true以便响应仅包括任何订阅的最新续订交易。仅将此字段用于包含自动续订订阅的应用收据。 

###### 3、Response Codes
* `environment`：系统生成收据的环境。可能的值：Sandbox, Production 
* `is_retryable`：boolean
* `latest_receipt`：最新的 Base64 编码的应用收据。这只会返回包含自动续订订阅的收据。
* `latest_receipt_info`：包含所有应用内购买交易的数组。这不包括您的应用标记为已完成的消耗品交易。
* `pending_renewal_info`：在 JSON 文件中，一个数组，其中每个元素都包含所标识的每个自动续订订阅的待定续订信息。这只会返回包含自动续订订阅的应用收据 product_id。
* `receipt`：您发送以供验证的收据的 JSON 表示形式。
* `status`：如果 0收据有效，或者如果有错误则为状态代码。状态码反映了应用收据整体的状态。status有关可能的状态代码和说明，请参阅。 

## 七、在 App Store 上发布
调试完成之后，如果是首次发布内购商品，则内购商品需要随App 新版本一起发布提交审核。

审核添加路径：在App Store Connect 后台中，准备提交的版本中在“App 内购买项目和订阅”模块，勾选需要提交审核的产品即可。

## 八、问题记录
#### 1、获取不到产品信息
* 协议、税务和银行业务信息是否录入正确并提交审核完成。状态为图2中的“有效”。
* App Store Connect 后台配置产品信息是否正确，产品状态是否为“准备提交”。
* Xcode中是否添加“In-App Purchase”配置项。
* 当前开发证书的bundle ID和 App Store Connect中配置了产品的 App的bundle ID是否一致。（一定要一致）
* 是否调试设备中的App 存在缓存，可卸载重装。
* 确定是真机测试且手机没有越狱。
* 以上都没问题，还获取不到，可在确保后台配置产品的情况下，先手动将产品添加到购买队列。（参考流程五中第5步）

#### 2、代理方法中获取不到支付结果
问题：能够获取产品信息，并将产品添加购买队列中，但是在代理方法 `- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions` 中监听不到支付结果？

解决：检查当前类在调用完成后是否直接被dealloc了，要确保将产品添加到购买队列后当前类仍然存活，不会提前被销毁。不然就接收不到代理回调，也就监听不到支付结果。可以使用单例来保证类的存活。

#### 3、苹果应用内支付,您已购买此App内购买项目。此项目将免费恢复

问题：使用沙箱账号（TestFlight邀请的账号没问题）重复充值同一个消耗型项目时，普通包没问题，但TestFlight包却提示"苹果应用内支付,您已购买此App内购买项目。此项目将免费恢复"，表示不能重复充值？

原因：苹果的服务器对大陆访问很慢(特别在沙盒测试环境更加不好)，导致用户在购买成功后，收不到苹果的IAP支付成功通知，交易就会一直卡在那里，没有关闭掉，后面无论怎样支付都是提示 “您已购买此App内购买项目。此项目将免费恢复”。

结果：不用解决，直接审核也能通过。目前猜测：1、审核人员用的是他们自己的沙箱账号；2、服务器在美国，审核人员也在美国。可能访问比较快。：）

--------------------

#### 如果开发过程中遇见了其他无法解决的问题，建议可以大量阅读网上有关内购的文章，以及苹果官方的内购文档。有可能在读到某句话时，你的问题就瞬间迎刃而解了。

代码参考：[IAPManager](https://github.com/wuyukobe24/IAPManager)
参考：[苹果文档](https://help.apple.com/app-store-connect/#/devb57be10e7)
其他参考：
          [iOS 苹果内购（In-App Purchase）](https://www.jianshu.com/p/bbe6f31da8b2)
          [苹果内购流程，看我就足够了](https://www.jianshu.com/p/2247f3b36be3)
          [细说苹果内购IAP](https://www.jianshu.com/p/b199a4672608)
          [苹果内购（IAP）从入门到精通（3）- 商品充值流程（非订阅型）](https://juejin.cn/post/7049626884765646884)

以上。
