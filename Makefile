target := iphone:clang:latest:latest
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsasecFX

FLEX_FILES = $(shell find Classes -type f \( -name "*.m" -o -name "*.mm" -o -name "*.xm" -o -name "*.x" -o -name "*.cpp" -o -name "*.c" \))

AsasecFX_FILES = AsasecFx.xm $(FLEX_FILES) manager/AsasecFxManager.mm

AsasecFX_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
