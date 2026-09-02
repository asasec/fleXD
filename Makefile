target := iphone:clang:latest:latest
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsasecFX

FLEX_FILES = $(shell find Classes -type f \( -name "*.m" -o -name "*.mm" -o -name "*.xm" -o -name "*.x" -o -name "*.cpp" -o -name "*.c" \))

AsasecFX_FILES = $(FLEX_FILES)

# -I Classes/Headers eklenerek alt klasörlerdeki .h dosyalarının bulunması sağlanır
AsasecFX_CFLAGS = -fobjc-arc \
                  -IClasses/Headers \
                  -IClasses/Utility \
                  -IClasses/ExplorerInterface

include $(THEOS_MAKE_PATH)/tweak.mk
