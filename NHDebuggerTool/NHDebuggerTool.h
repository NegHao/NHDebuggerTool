//
//  NHToolManager.h
//  NHTool
//
//  Created by neghao on 2017/2/13.
//  Copyright © 2017年 NegHao.Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NHDebuggerTool;
@protocol NHDebuggerToolDelegate <NSObject>
/** 点击悬浮球的回调 */
- (void)nhSuspensionViewClick:(NHDebuggerTool *)tool;
@end

@interface NHDebuggerTool : NSObject
@property (nonatomic, assign)id<NHDebuggerToolDelegate> delegate;

/**
 *  在点击悬浮球的时候是否触发自动显示测试调试工具条，默认yes
 */
@property (nonatomic, assign)BOOL isShowFELX;

/**
 *  建立tool单例
 *  @param delegate 点击事件代理
 */
+ (id)shareInstanceDelegate:(id)delegate;

/**
 *  显示悬浮球
 */
+ (void)showSuspensionView;
- (void)showSuspensionView;

/**
 *  隐藏悬浮球
 */
+ (void)hiddenSuspensionView;

/**
 *  返回值可判定当前状态是否隐藏
 */
+ (BOOL)suspensionViewIsHidden;

/**
 *  移除
 */
+ (void)removeSuspensionViewFromScreen;
@end
