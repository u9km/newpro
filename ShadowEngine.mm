#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "fishhook.h" // 🛠️ تم استبدال Dobby بـ fishhook

// ================================================
// 🎨 1. واجهة العرض العائمة (تظل كما هي)
// ================================================
@interface ShadowOverlay : UIView
+ (void)showStatus:(NSString *)message isSuccess:(BOOL)success;
@end

@implementation ShadowOverlay
+ (void)showStatus:(NSString *)message isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) return;
        UILabel *label = [[UILabel alloc] init];
        label.text = message;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:13];
        label.textColor = success ? [UIColor greenColor] : [UIColor redColor];
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        label.layer.cornerRadius = 8;
        label.layer.masksToBounds = YES;
        label.frame = CGRectMake(window.frame.size.width * 0.15, 30, window.frame.size.width * 0.7, 50);
        [window addSubview:label];
        label.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{ label.alpha = 1; }];
        [UIView animateWithDuration:0.5 delay:3.0 options:0 animations:^{ label.alpha = 0; } completion:^(BOOL finished) { [label removeFromSuperview]; }];
    });
}
@end

// ================================================
// 🛡️ 2. محرك الحماية (Hooking using Fishhook)
// ================================================

// تخزين الدالة الأصلية
static int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);

// الدالة الجديدة
int new_ptrace(int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) { // PT_DENY_ATTACH
        return 0; // إرجاع نجاح وهمي
    }
    return orig_ptrace(request, pid, addr, data);
}

@interface ShadowEngine : NSObject
+ (void)loadProtection;
@end

@implementation ShadowEngine

+ (void)loadProtection {
    // 🎯 استخدام fishhook لعمل rebind لدالة ptrace
    struct rebinding ptrace_rebinding = {
        "ptrace",
        (void *)new_ptrace,
        (void **)&orig_ptrace
    };
    
    // محاولة إعادة الربط (Rebind)
    int result = rebind_symbols((struct rebinding[1]){ptrace_rebinding}, 1);
    
    if (result == 0) {
        [ShadowOverlay showStatus:@"[SHADOW ENGINE]\n✅ Bypass Active (Fishhook)" isSuccess:YES];
    } else {
        [ShadowOverlay showStatus:@"[SHADOW ENGINE]\n❌ Patch Failed" isSuccess:NO];
    }
}
@end

// ================================================
// 🚀 3. التشغيل تلقائياً (Entry Point)
// ================================================
static __attribute__((constructor)) void start() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ShadowEngine loadProtection];
    });
}
