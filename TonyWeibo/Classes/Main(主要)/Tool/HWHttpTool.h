//
//  HWHttpTool.h
//  黑马微博2期
//
//  Created by apple on 14-10-25.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
    分层的分太厉害，分的太细，太清楚，也不好，不好找，文件太多，太多碎片！
    凡事儿都有两面性，适可而止！
 */
@interface HWHttpTool : NSObject
+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
@end
