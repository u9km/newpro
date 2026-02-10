# إعدادات المعمارية
ARCHS = arm64
TARGET = iphone:clang:latest:14.3

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

SovereignSecurity_FILES = SovereignSecurity.m fishhook.c
# 🎨 يجب تضمين UIKit هنا لاستخدام ShadowOverlay
SovereignSecurity_FRAMEWORKS = UIKit Foundation CoreGraphics

# ربط المكتبة - تأكد من وجود libdobby.a في المجلد الرئيسي
SovereignSecurity_LDFLAGS += -L./ -ldobby

# حل مشكلة توافق المعماريات
SovereignSecurity_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-error

include $(THEOS)/makefiles/tweak.mk
