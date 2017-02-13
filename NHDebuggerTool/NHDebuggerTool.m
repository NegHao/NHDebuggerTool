//
//  NHToolManager.m
//  NHTool
//
//  Created by neghao on 2017/2/13.
//  Copyright © 2017年 NegHao.Studio. All rights reserved.
//

#import "NHDebuggerTool.h"
#import "ZYSuspensionView.h"
#import "ZYSuspensionManager.h"
#import "FLEXManager.h"

static NHDebuggerTool *magager;

@interface NHDebuggerTool ()<ZYSuspensionViewDelegate>
@property (nonatomic, strong)ZYSuspensionView *sus;

@end

@implementation NHDebuggerTool

/**
 *  建立tool单例
 */
+ (id)shareInstanceDelegate:(id)delegate{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (magager == nil) {
            magager = [[NHDebuggerTool alloc]init];
            magager.isShowFELX = YES;
            magager.delegate = delegate;
            
            magager.sus = [ZYSuspensionView defaultSuspensionViewWithDelegate:magager];
            [magager.sus setTitle:@"Tool" forState:UIControlStateNormal];
            [magager.sus show];
        }
    });
    return magager;
}

+ (void)showSuspensionView{
    [magager showSuspensionView];
}

- (void)showSuspensionView
{
    magager.sus.hidden = NO;
}

+ (void)hiddenSuspensionView{
   [magager hiddenSuspensionView];
}
- (void)hiddenSuspensionView{
    magager.sus.hidden = YES;
}

+ (BOOL)suspensionViewIsHidden{
    return magager.sus.hidden;
}

- (void)suspensionViewClick:(ZYSuspensionView *)suspensionView{
    if (_isShowFELX) {
        if ([FLEXManager sharedManager].isHidden) {
            [[FLEXManager sharedManager] showExplorer];
        }else{
            [[FLEXManager sharedManager] hideExplorer];
        }
    }
    
    if (magager.delegate && [magager.delegate respondsToSelector:@selector(nhSuspensionViewClick:)]) {
        [magager.delegate nhSuspensionViewClick:self];
    }
}


+ (void)removeSuspensionViewFromScreen{
    [magager removeSuspensionViewFromScreen];
}
- (void)removeSuspensionViewFromScreen{
    [magager.sus removeFromScreen];
}


@end
