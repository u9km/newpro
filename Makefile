# إعدادات المعمارية
ARCHS = arm64
TARGET = iphone:clang:latest:14.3

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

SovereignSecurity_FILES = SovereignSecurity.m fishhook.c
SovereignSecurity_FRAMEWORKS = UIKit Foundation CoreGraphics

# --- التعديل هنا ---
# ربط مكتبة dobby ومكتبة C++ القياسية
SovereignSecurity_LDFLAGS += -L./ -ldobby -lc++
# --------------------

# حل مشكلة توافق المعماريات
SovereignSecurity_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-error

include $(THEOS)/makefiles/tweak.mk
