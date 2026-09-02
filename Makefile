target := iphone:clang:latest:latest
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsasecFX

# Kaynak dosyalarını bulur
FLEX_FILES = $(shell find Classes -type f \( -name "*.m" -o -name "*.mm" -o -name "*.xm" -o -name "*.x" -o -name "*.cpp" -o -name "*.c" \))

# Classes altındaki TÜM alt klasörleri bulur ve başlarına -I ekler
HEADER_PATHS = $(patsubst %, -I%, $(shell find Classes -type d))

AsasecFX_FILES = $(FLEX_FILES)

AsasecFX_CFLAGS = -fobjc-arc $(HEADER_PATHS) -Wno-nullability-completeness -Wno-unused-property-ivar -Wno-unused-variable -Wno-switch -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-nonnull

include $(THEOS_MAKE_PATH)/tweak.mk
