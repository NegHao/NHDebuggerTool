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
#import "NHDevicinfo.h"
#import "TYWaveProgressView.h"

static NHDebuggerTool *magager;

@interface NHDebuggerTool ()<ZYSuspensionViewDelegate,NHDevicinfoDelegate>
@property (nonatomic, strong)ZYSuspensionView *sus;
@property (nonatomic, strong)NHDevicinfo *devicinfo;
@property (nonatomic, weak) TYWaveProgressView *waveProgressView;

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
            [magager.sus show];
            [magager addWaveProgressView];
            
            magager.devicinfo = [[NHDevicinfo alloc] init];
            magager.devicinfo.delegate = magager;
        }
    });
    return magager;
}


#pragma mark - NHDevicinfoDelegate
- (void)NHDevicinfosCpu:(float)cpu Memory:(NSString *)memory DataCounters:(NSString *)dataCounters{
    float cup_v = (floorf(cpu * 100 + 0.5)) /100 /100;
    _waveProgressView.percent = cup_v;
//    NSLog(@"%2f",cpu);
    if (cpu > 50.f) {
        [_waveProgressView setFirstWaveColor:[UIColor redColor]];
    }else{
        [_waveProgressView setFirstWaveColor:[UIColor greenColor]];
    }
    [_waveProgressView startWave];
    _waveProgressView.numberLabel.text = [NSString stringWithFormat:@"%.2f",cpu];
    _waveProgressView.explainLabel.text = memory;
}

- (void)addWaveProgressView
{
    TYWaveProgressView *waveProgressView = [[TYWaveProgressView alloc]initWithFrame:magager.sus.bounds];
    waveProgressView.waveViewMargin = UIEdgeInsetsMake(1, 1, 1, 1);
    waveProgressView.backgroundImageView.image = [UIImage imageNamed:@"bg_tk_003"];
    waveProgressView.numberLabel.text = @"0M";
    waveProgressView.numberLabel.font = [UIFont boldSystemFontOfSize:10];
    waveProgressView.numberLabel.textColor = [UIColor whiteColor];
    waveProgressView.unitLabel.text = @"%";
    waveProgressView.unitLabel.font = [UIFont boldSystemFontOfSize:8];
    waveProgressView.unitLabel.textColor = [UIColor whiteColor];
    waveProgressView.explainLabel.text = @"memory";
    waveProgressView.explainLabel.font = [UIFont systemFontOfSize:8];
    waveProgressView.explainLabel.textColor = [UIColor whiteColor];
    waveProgressView.userInteractionEnabled = NO;
    [magager.sus addSubview:waveProgressView];
    _waveProgressView = waveProgressView;
    [_waveProgressView startWave];
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
