#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import "dobby.h"

// ================================================
// 🎨 1. واجهة العرض (Overlay UI)
// ================================================

@interface ShadowOverlay : UIView
+ (void)showStatus:(NSString *)message isSuccess:(BOOL)success;
@end

@implementation ShadowOverlay

+ (void)showStatus:(NSString *)message isSuccess:(BOOL)success {
    // التأكد من العمل على الـ Main Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        
        // البحث عن النافذة الرئيسية النشطة
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]] &&
                    scene.activationState == UISceneActivationStateForegroundActive) {
                    window = ((UIWindowScene *)scene).windows.firstObject;
                    break;
                }
            }
        }
        
        if (!window) {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (!window) return;

        // إعداد الملصق (Label)
        UILabel *label = [[UILabel alloc] init];
        label.text = message;
        label.numberOfLines = 0; // ليدعم تعدد الأسطر
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textColor = success ? [UIColor greenColor] : [UIColor redColor];
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6]; // خلفية شبه شفافة
        label.layer.cornerRadius = 10;
        label.layer.masksToBounds = YES;
        label.layer.zPosition = 10000; // لضمان ظهوره فوق كل شيء

        // تحديد الحجم والموقع (في أعلى الشاشة)
        CGFloat screenWidth = window.frame.size.width;
        label.frame = CGRectMake(screenWidth * 0.1, 40, screenWidth * 0.8, 60);

        [window addSubview:label];

        // تأثير ظهور سلس
        label.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            label.alpha = 1;
        }];
        
        // إزالة الرسالة بعد 5 ثواني
        [UIView animateWithDuration:0.5 delay:5.0 options:0 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    });
}
@end

// ================================================
// 🛡️ 2. محرك الحماية (Hooking)
// ================================================

static int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);

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
    void *ptrace_ptr = dlsym(RTLD_DEFAULT, "ptrace");
    if (ptrace_ptr) {
        int result = DobbyHook(ptrace_ptr, (void *)new_ptrace, (void **)&orig_ptrace);
        if (result == 0) {
            // ✅ إظهار رسالة النجاح
            [ShadowOverlay showStatus:@"[SHADOW ENGINE]\n✅ Bypass Active (Non-JB)" isSuccess:YES];
        } else {
            // ❌ إظهار رسالة الفشل
            [ShadowOverlay showStatus:@"[SHADOW ENGINE]\n❌ Patch Failed" isSuccess:NO];
        }
    } else {
        [ShadowOverlay showStatus:@"[SHADOW ENGINE]\n❌ Symbol Not Found" isSuccess:NO];
    }
}
@end

// ================================================
// 🚀 3. التشغيل تلقائياً عند فتح التطبيق
// ================================================

static __attribute__((constructor)) void start() {
    // تأخير التشغيل 5 ثواني لضمان تحميل اللعبة للواجهة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ShadowEngine loadProtection];
    });
}
