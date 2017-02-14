//
//  NHDevicinfo.m
//  NHDebuggerTool
//
//  Created by neghao on 2017/2/13.
//  Copyright © 2017年 NegHao.Studio. All rights reserved.
//

#import "NHDevicinfo.h"
#include <mach/mach.h>
#include <malloc/malloc.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>
#include <mach/mach_init.h>
#include <mach/mach_host.h>

#define K	(1024)
#define M	(K * 1024)
#define G	(M * 1024)

@interface NHDevicinfo ()
{
    NSTimer *time;
    NSString *totalString;
    NSString *freeString;
    int64_t				_usedBytes;
    int64_t				_totalBytes;
    int64_t				_usedBytes_m;
    int64_t				_totalBytes_m;
    NSMutableArray *	_chartDatas;
    NSUInteger			_lowerBound;
    NSUInteger			_upperBound;
    BOOL				_warningMode;
}
@property (nonatomic, strong) NSTimer *cpu_timer;
@end

@implementation NHDevicinfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self cpu_timer];
    }
    return self;
}

- (void)startCheck{
    [self cpu_usage];
    [self getDataCounters];
    [self getMemory];
    if (self.delegate && [self.delegate respondsToSelector:@selector(NHDevicinfosCpu:Memory:DataCounters:)]) {
        [self.delegate NHDevicinfosCpu:_cpu Memory:_memory DataCounters:_dataCounters];
    }
}

- (float)cpu_usage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    _cpu = tot_cpu;
    
    return tot_cpu;
}

/*获取网络流量信息*/
- (NSArray *)getDataCounters
{
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    
    int WiFiSent = 0;
    int WiFiReceived = 0;
    int WWANSent = 0;
    int WWANReceived = 0;
    
    NSString *name = [[NSString alloc]init];
    
    success = getifaddrs(&addrs) == 0;
    if (success)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            //            kNSLog(@"ifa_name %s == %@n", cursor->ifa_name,name);
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                if ([name hasPrefix:@"en"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WiFiSent+=networkStatisc->ifi_obytes;
                    WiFiReceived+=networkStatisc->ifi_ibytes;
                    //                     kNSLog(@"WiFiSent %d ==%d",WiFiSent,networkStatisc->ifi_obytes);
                    //                    kNSLog(@"WiFiReceived %d ==%d",WiFiReceived,networkStatisc->ifi_ibytes);
                }
                if ([name hasPrefix:@"pdp_ip"])
                {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    WWANSent+=networkStatisc->ifi_obytes;
                    WWANReceived+=networkStatisc->ifi_ibytes;
                    //                     kNSLog(@"WWANSent %d ==%d",WWANSent,networkStatisc->ifi_obytes);
                    //                    kNSLog(@"WWANReceived %d ==%d",WWANReceived,networkStatisc->ifi_ibytes);
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
//    NSLog(@"nwifiSend:%.2f MBnwifiReceived:%.2f MBn wwansend:%.2f MBn wwanreceived:%.2f MBn",WiFiSent/1024.0/1024.0,WiFiReceived/1024.0/1024.0,WWANSent/1024.0/1024.0,WWANReceived/1024.0/1024.0);
    
    _dataCounters = [NSString stringWithFormat:@"%.1f/%.1f",WiFiSent/1024.0/1024.0,WiFiReceived/1024.0/1024.0];
    _allDataCounters = [NSArray arrayWithObjects:[NSNumber numberWithInt:WiFiSent], [NSNumber numberWithInt:WiFiReceived],[NSNumber numberWithInt:WWANSent],[NSNumber numberWithInt:WWANReceived], nil];
    return _allDataCounters;
}

- (float)getMemory
{
    struct mstats		stat = mstats();
    
    NSProcessInfo *		progress = [NSProcessInfo processInfo];
    unsigned long long	total = [progress physicalMemory];
    
    _usedBytes_m = stat.bytes_used;
    _totalBytes_m = total; // NSRealMemoryAvailable();
    
    if ( 0 == _usedBytes_m )
    {
        mach_port_t host_port;
        mach_msg_type_number_t host_size;
        vm_size_t pagesize;
        
        host_port = mach_host_self();
        host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
        host_page_size( host_port, &pagesize );
        
        vm_statistics_data_t vm_stat;
        kern_return_t ret = host_statistics( host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size );
        if ( KERN_SUCCESS != ret )
        {
            _usedBytes_m = 0;
            _totalBytes_m = 0;
        }
        else
        {
            natural_t mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
            natural_t mem_free = vm_stat.free_count * pagesize;
            natural_t mem_total = mem_used + mem_free;
            
            _usedBytes_m = mem_used;
            _totalBytes_m = mem_total;
        }
    }
    //    [_chartDatas addObject:[NSNumber numberWithUnsignedLongLong:_usedBytes]];
    //    [_chartDatas keepTail:MAX_MEMORY_HISTORY];
    //	_lowerBound = _upperBound;
    //	_upperBound = 1;
    
    for ( NSNumber * n in _chartDatas )
    {
        if ( n.intValue > _upperBound )
        {
            _upperBound = n.intValue;
            
            //			if ( _upperBound < _lowerBound )
            //			{
            //				_lowerBound = _upperBound;
            //			}
        }
        else if ( n.intValue < _lowerBound )
        {
            _lowerBound = n.intValue;
        }
    }
    
    if ( _warningMode )
    {
#if DEBUG
        [[UIApplication sharedApplication] performSelector:@selector(_performMemoryWarning)];
#endif
    }
    float memoryValue = (_totalBytes_m > 0.0f) ? ((float)_usedBytes_m / (float)_totalBytes_m) : 0.0f;
    _memory = [self format:_usedBytes_m];
    return memoryValue;
}

- (NSString *)format:(int64_t)n
{
    if ( n < K )
    {
        return [NSString stringWithFormat:@"%lldB", n];
    }
    else if ( n < M )
    {
        return [NSString stringWithFormat:@"%.1fK", (float)n / (float)K];
    }
    else if ( n < G )
    {
        return [NSString stringWithFormat:@"%.1fM", (float)n / (float)M];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fG", (float)n / (float)G];
    }
}

- (NSTimer *)cpu_timer{
    if (!_cpu_timer) {
        _cpu_timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(startCheck) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_cpu_timer forMode:NSRunLoopCommonModes];
    }
    return _cpu_timer;
}

@end
