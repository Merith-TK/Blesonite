#Use this for every path in the build process
BLESONITE_PATH = $(shell pwd)


VARS = $(BLESONITE_PATH)/vars

#Lets just make sure that we have the vars folder
dummy := $(shell mkdir -p $(VARS))

#We get the BLESONITE_* variables from a file in the vars folder
#if it doesnt exist we just generate the file with some defaults.
BLESONITE_BLENDER_VERSION_MAJOR = $(shell cat $(VARS)/BLESONITE_BLENDER_VERSION_MAJOR)
ifeq ($(BLESONITE_BLENDER_VERSION_MAJOR),)

BLESONITE_BLENDER_VERSION_MAJOR=4.3
BLESONITE_BLENDER_VERSION_MINOR=0
$(file >$(VARS)/BLESONITE_BLENDER_VERSION_MAJOR,$(BLESONITE_BLENDER_VERSION_MAJOR))
$(file >$(VARS)/BLESONITE_BLENDER_VERSION_MINOR,$(BLESONITE_BLENDER_VERSION_MINOR))
endif

BLESONITE_BLENDER_VERSION=$(BLESONITE_BLENDER_VERSION_MAJOR).$(BLESONITE_BLENDER_VERSION_MINOR)





BLESONITE_BLENDER_PATH = $(shell cat $(VARS)/BLESONITE_BLENDER_PATH)
ifeq ($(BLESONITE_BLENDER_PATH),)
$(file >$(VARS)/BLESONITE_BLENDER_PATH,$(BLESONITE_PATH)/blender/blender-$(BLESONITE_BLENDER_VERSION)-windows-x64/)
BLESONITE_BLENDER_PATH = $(shell cat $(VARS)/BLESONITE_BLENDER_PATH)

# [TODO] : We assume that its gonna run on windows, later we should have a native linux version but thats when pythonnet will cooperate
dummy := $(shell wget -nd https://mirrors.dotsrc.org/blender/release/Blender$(BLESONITE_BLENDER_VERSION_MAJOR)/blender-$(BLESONITE_BLENDER_VERSION)-windows-x64.zip)
dummy := $(shell mkdir -p $(BLESONITE_PATH)/blender/)
dummy := $(shell unzip blender-$(BLESONITE_BLENDER_VERSION)-windows-x64.zip -d $(BLESONITE_PATH)/blender/)
dummy := $(shell rm blender-$(BLESONITE_BLENDER_VERSION)-windows-x64.zip)


endif

BLESONITE_BLENDER_INITIALIZED = $(shell cat $(VARS)/BLESONITE_BLENDER_INITIALIZED)
ifneq ($(BLESONITE_BLENDER_INITIALIZED),1)

$(file >$(VARS)/BLESONITE_BLENDER_INITIALIZED,1)
#Using pip import to install packages
# [TODO] : Make it not use wine when on windows
dummy := $(shell wine $(BLESONITE_BLENDER_PATH)/blender.exe -b --python-expr "import pip; pip.main(['install','pythonnet']); pip.main(['install','-U','numpy'])")

endif



all:
	