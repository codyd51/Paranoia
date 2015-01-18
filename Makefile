ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = Paranoia
Paranoia_FILES = Tweak.xm
Paranoia_FRAMEWORKS = UIKit
Paranoia_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
