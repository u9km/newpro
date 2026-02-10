ARCHS = arm64
THEOS_PLATFORM = darwin
SDKVERSION =
TARGET = darwin:clang:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SovereignSecurity

SovereignSecurity_FILES = SovereignSecurity.m fishhook.c

SovereignSecurity_FRAMEWORKS = Foundation CoreGraphics
# UIKit ❌ غير متوفر على darwin بدون SDK

# ربط libdobby.a مباشرة (أفضل من LIBRARIES)
SovereignSecurity_LDFLAGS += $(THEOS_PROJECT_DIR)/libdobby.a

SovereignSecurity_CFLAGS = -fobjc-arc \
                           -Wno-unused-variable \
                           -Wno-unused-function \
                           -Wno-deprecated-declarations \
                           -Wno-error

include $(THEOS)/makefiles/tweak.mk
