#Use this for every path in the build process
BLESONITE_PATH := $(shell pwd)

COMMA:= ,

VARS = $(BLESONITE_PATH)/vars

SANITIZE = $(subst /,\/,$1)

PROMPT = $(strip $(shell bash -c 'echo -e "\033[7;92mINPUT\033[0;92m $1\033[0m" >&2; read userinput; echo $$userinput'))
PROMPT_FOR_FOLDER = $(strip $(shell ./promptFolder.sh "$1" "$2"))
YESNO = $(shell ./promptYN.sh "$1")

#Lets just make sure that we have the vars folder
dummy := $(shell mkdir -p $(VARS))

BLESONITE_BLENDER_VERSION_MAJOR_DEFAULT=4.3
BLESONITE_BLENDER_VERSION_MINOR_DEFAULT=0
BLESONITE_BLENDER_VERSION:=$(BLESONITE_BLENDER_VERSION_MAJOR_DEFAULT).$(BLESONITE_BLENDER_VERSION_MINOR_DEFAULT)
BLESONITE_BLENDER_MISSING=0

#We get the BLESONITE_* variables from a file in the vars folder
#if it doesnt exist we just generate the file with some defaults.
BLESONITE_BLENDER_VERSION_MAJOR := $(shell cat $(VARS)/BLESONITE_BLENDER_VERSION_MAJOR)
BLESONITE_BLENDER_VERSION_MINOR := $(shell cat $(VARS)/BLESONITE_BLENDER_VERSION_MINOR)

BLESONITE_BLENDER_PATH := $(shell cat $(VARS)/BLESONITE_BLENDER_PATH)

ifeq ($(BLESONITE_BLENDER_VERSION_MAJOR),)
    BLESONITE_BLENDER_MISSING = 1
else ifeq ($(BLESONITE_BLENDER_PATH),)
    BLESONITE_BLENDER_MISSING = 1
endif

ifeq ($(BLESONITE_BLENDER_MISSING),1)
    DO_INSTALL_BLENDER := $(call YESNO,Do you want Blesonite to install Blender for you? (You might want this even if you have Blender.) (Y/N):)
endif

ifeq ($(DO_INSTALL_BLENDER),1)

    BLESONITE_BLENDER_VERSION:=$(call PROMPT,Type in the version of Blender which you want to install. If you are unsure press ENTER. (Default: $(BLESONITE_BLENDER_VERSION_MAJOR_DEFAULT).$(BLESONITE_BLENDER_VERSION_MINOR_DEFAULT)):)

#it could be also empty. thats why we check for 0
else ifeq ($(DO_INSTALL_BLENDER),0)

    BLESONITE_BLENDER_VERSION:=$(call PROMPT,Type in the version of your Blender installation. (Default: $(BLESONITE_BLENDER_VERSION_MAJOR_DEFAULT).$(BLESONITE_BLENDER_VERSION_MINOR_DEFAULT)):)

endif


ifeq ($(BLESONITE_BLENDER_VERSION_MAJOR),)

    ifeq ($(BLESONITE_BLENDER_VERSION),)
        BLESONITE_BLENDER_VERSION_MAJOR:=$(BLESONITE_BLENDER_VERSION_MAJOR_DEFAULT)
        BLESONITE_BLENDER_VERSION_MINOR:=$(BLESONITE_BLENDER_VERSION_MINOR_DEFAULT)
    else 
        BLESONITE_BLENDER_VERSION_MAJOR:=$(word 1,$(subst ., ,$(BLESONITE_BLENDER_VERSION))).$(word 2,$(subst ., ,$(BLESONITE_BLENDER_VERSION)))
        BLESONITE_BLENDER_VERSION_MINOR:=$(word 3,$(subst ., ,$(BLESONITE_BLENDER_VERSION)))
    endif

    $(file >$(VARS)/BLESONITE_BLENDER_VERSION_MAJOR,$(BLESONITE_BLENDER_VERSION_MAJOR))
    $(file >$(VARS)/BLESONITE_BLENDER_VERSION_MINOR,$(BLESONITE_BLENDER_VERSION_MINOR))

endif

BLESONITE_BLENDER_VERSION:=$(BLESONITE_BLENDER_VERSION_MAJOR).$(BLESONITE_BLENDER_VERSION_MINOR)
BLESONITE_BLENDER_IDENTIFIER := blender-$(BLESONITE_BLENDER_VERSION)-windows-x64

BLESONITE_BLENDER_PATH_DEFAULT:=$(BLESONITE_PATH)/$(BLESONITE_BLENDER_IDENTIFIER)/

ifeq ($(DO_INSTALL_BLENDER),1)

    BLESONITE_BLENDER_PATH:=$(call PROMPT,If you want to install Blender into a different directory than \`$(BLESONITE_BLENDER_PATH_DEFAULT)\`$(COMMA) drag and drop or paste a preferably empty folder into the terminal, otherwise just press ENTER:)

    ifeq ($(BLESONITE_BLENDER_PATH),)
        BLESONITE_BLENDER_PATH:=$(BLESONITE_BLENDER_PATH_DEFAULT)
    endif


# [TODO] : We assume that its gonna run on wine, later we should have a native linux version but thats when pythonnet will cooperate
    dummy := $(shell wget -nd https://mirrors.dotsrc.org/blender/release/Blender$(BLESONITE_BLENDER_VERSION_MAJOR)/$(BLESONITE_BLENDER_IDENTIFIER).zip)
    dummy := $(shell mkdir -p $(BLESONITE_BLENDER_PATH))
    dummy := $(shell unzip $(BLESONITE_BLENDER_IDENTIFIER).zip -d $(BLESONITE_BLENDER_PATH)/unpacked/)
    dummy := $(shell rm $(BLESONITE_BLENDER_IDENTIFIER).zip)
    dummy := $(shell mv $(BLESONITE_BLENDER_PATH)/unpacked/$(BLESONITE_BLENDER_IDENTIFIER)/* $(BLESONITE_BLENDER_PATH)/)
    dummy := $(shell rm $(BLESONITE_BLENDER_PATH)/unpacked/$(BLESONITE_BLENDER_IDENTIFIER))
    dummy := $(shell rm $(BLESONITE_BLENDER_PATH)/unpacked)

    $(file >$(VARS)/BLESONITE_BLENDER_PATH,$(BLESONITE_BLENDER_PATH))

#it could be also empty. thats why we check for 0
else ifeq ($(DO_INSTALL_BLENDER),0)

    BLESONITE_BLENDER_PATH:=$(call PROMPT_FOR_FOLDER,blender.exe,Drop the folder where blender.exe resides into the terminal or paste the path in here:)

    $(file >$(VARS)/BLESONITE_BLENDER_PATH,$(BLESONITE_BLENDER_PATH))

else

    BLESONITE_BLENDER_PATH := $(shell cat $(VARS)/BLESONITE_BLENDER_PATH)

endif


BLESONITE_BLENDER_INITIALIZED := $(shell cat $(VARS)/BLESONITE_BLENDER_INITIALIZED)
ifneq ($(BLESONITE_BLENDER_INITIALIZED),1)

    $(info I dont remember if Blender was initialized with proper packages. Launching blender in background mode, installing `pythonnet` and upgrading `numpy`)

#Using pip import to install packages
# [TODO] : Make it not use wine when on windows
    dummy := $(shell wine $(BLESONITE_BLENDER_PATH)/blender.exe -b --python-expr "import pip; pip.main(['install','pythonnet']); pip.main(['install','-U','numpy'])")

    $(file >$(VARS)/BLESONITE_BLENDER_INITIALIZED,1)

endif

BLESONITE_HEADLESS := $(shell cat $(VARS)/BLESONITE_HEADLESS)
ifeq ($(BLESONITE_HEADLESS),)

    BLESONITE_HEADLESS := $(call PROMPT_FOR_FOLDER,FrooxEngine.dll,Drop the folder where FrooxEngine.dll resides into the terminal or paste the path in here:)
    $(file >$(VARS)/BLESONITE_HEADLESS,$(BLESONITE_HEADLESS))

endif

$(BLESONITE_PATH)/src/Blue/Blue.csproj: src/Blue/Blue.csprojtemplate
	sed 's/$$BLESONITE_HEADLESS/$(call SANITIZE,$(BLESONITE_HEADLESS))/g' $(BLESONITE_PATH)/src/Blue/Blue.csprojtemplate > $(BLESONITE_PATH)/src/Blue/Blue.csproj

Blue: $(BLESONITE_PATH)/src/Blue/Blue.csproj $(BLESONITE_PATH)/src/Blue/Blue.cs
	cd $(BLESONITE_PATH)/src/Blue; dotnet build

all: Blue

clean:
	rm -rf $(VARS)
	rm $(BLESONITE_PATH)/src/Blue/Blue.csproj