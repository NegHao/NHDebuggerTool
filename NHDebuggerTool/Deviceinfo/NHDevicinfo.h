//
//  NHDevicinfo.h
//  NHDebuggerTool
//
//  Created by neghao on 2017/2/13.
//  Copyright © 2017年 NegHao.Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NHDevicinfoDelegate <NSObject>

- (void)NHDevicinfosCpu:(float)cpu Memory:(NSString *)memory DataCounters:(NSString *)dataCounters;

@end

@interface NHDevicinfo : NSObject
@property (nonatomic, assign)id<NHDevicinfoDelegate> delegate;
@property (nonatomic, assign)float cpu;
@property (nonatomic, copy  )NSString *memory;
@property (nonatomic, copy  )NSString *dataCounters;
@property (nonatomic, copy  )NSArray  *allDataCounters;

@end
