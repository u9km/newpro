# إعدادات المعمارية - ركز على arm64 للبدء
ARCHS = arm64 
TARGET = iphone:clang:latest:14.3

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

SovereignSecurity_FILES = SovereignSecurity.m fishhook.c
# إضافة المكتبات اللازمة
SovereignSecurity_FRAMEWORKS = UIKit Foundation CoreGraphics
SovereignSecurity_LIBRARIES = dobby
SovereignSecurity_LDFLAGS += -L./ -ldobby

# المسار الذي يوجد فيه ملف libdobby.a (تأكد من وضعه في مجلد المشروع الرئيسي)
SovereignSecurity_LDFLAGS += -L./ -ldobby

# حل مشكلة isOSVersionAtLeast وتوافق المعماريات
SovereignSecurity_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function


SovereignSecurity_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-error

include $(THEOS)/makefiles/tweak.mk
