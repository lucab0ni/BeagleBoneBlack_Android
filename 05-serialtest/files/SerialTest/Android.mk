LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional tests
LOCAL_SRC_FILES := $(call all-java-files-under, src)
LOCAL_SDK_VERSION := current
LOCAL_PACKAGE_NAME := SerialTest
LOCAL_CERTIFICATE := shared
include $(BUILD_PACKAGE)
include $(call all-makefiles-under, $(LOCAL_PATH))
