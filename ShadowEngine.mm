#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import "dobby.h"

// ================================================
// 🎨 1. واجهة العرض المستمرة (تعديل ليبقى الإشعار ظاهراً)
// ================================================

@interface ShadowOverlay : UIView
+ (void)showStatus:(NSString *)message isSuccess:(BOOL)success;
@end

@implementation ShadowOverlay

+ (void)showStatus:(NSString *)message isSuccess:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        
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
            NSArray *windows = [UIApplication sharedApplication].windows;
            if (windows.count > 0) {
                window = windows.firstObject;
            }
        }

        if (!window) return;

        // إعداد الملصق (Label)
        UILabel *label = [[UILabel alloc] init];
        label.text = message;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:13]; // تصغير الخط قليلاً ليكون مريحاً
        label.textColor = success ? [UIColor greenColor] : [UIColor redColor];
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7]; // شفافية أقل
        label.layer.cornerRadius = 8;
        label.layer.masksToBounds = YES;
        label.layer.zPosition = 10000;

        // تحديد الحجم والموقع (جعله أصغر قليلاً في الأعلى لكي لا يضايقك أثناء اللعب)
        CGFloat screenWidth = window.frame.size.width;
        CGFloat labelWidth = screenWidth * 0.7; 
        label.frame = CGRectMake((screenWidth - labelWidth) / 2, 45, labelWidth, 50);

        [window addSubview:label];

        // تأثير الظهور فقط بدون اختفاء
        label.alpha = 0;
        [UIView animateWithDuration:0.8 animations:^{
            label.alpha = 1;
        }];
        
        // ملاحظة: تم حذف كود التلاشي (Removal code) ليبقى للأبد
    });
}
@end

// ================================================
// 🛡️ 2. محرك الحماية (Dobby Engine)
// ================================================

static int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);

int new_ptrace(int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) { 
        return 0; 
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
            // سيبقى هذا النص الأخضر ظاهراً أمامك دائماً
            [ShadowOverlay showStatus:@"[SHADOW ENGINE]\n✅ Bypass Active (Non-JB Mode)" isSuccess:YES];
        } else {
            [ShadowOverlay showStatus:@"[SHADOW ENGINE]\n❌ Patch Failed" isSuccess:NO];
        }
    } else {
        [ShadowOverlay showStatus:@"[SHADOW ENGINE]\n❌ Symbol Not Found" isSuccess:NO];
    }
}
@end

// ================================================
// 🚀 3. التشغيل
// ================================================

static __attribute__((constructor)) void start() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ShadowEngine loadProtection];
    });
}
