SHELL := cmd.exe
.SHELLFLAGS := /C

# Define variables
VERSION := $(if $(v),$(v),dev)
AHK2EXE := $(USERPROFILE)\Scoop\apps\autohotkey\current\Compiler\Ahk2Exe.exe
AHK_BASE := $(USERPROFILE)\Scoop\apps\autohotkey\current\v2\AutoHotkey64.exe
PACKER := $(USERPROFILE)\Scoop\apps\autohotkey\current\Compiler\Upx.exe
WIX_UI_EXT := $(USERPROFILE)\.wix\extensions\WixToolset.UI.wixext\7.0.0\wixext7
WIX_UTIL_EXT := $(USERPROFILE)\.wix\extensions\WixToolset.Util.wixext\7.0.0\wixext7
APP_AHK := VirtualDesktopExtension.ahk
APP_EXE := VirtualDesktopExtension.exe
APP_DLL := VirtualDesktopAccessor.dll
BUILD_DIR := build
BUILD_ZIP := .\$(BUILD_DIR)\VirtualDesktopExtension-$(VERSION).zip
BUILD_MSI := .\$(BUILD_DIR)\VirtualDesktopExtension-$(VERSION).msi
APP_FILES := ".\$(BUILD_DIR)\$(APP_EXE)", ".\$(APP_DLL)", ".\LICENSE", ".\icons\*"
GIT_REPO := git@github.com:starise/win11-virtual-desktop-extension.git

# Print a helper
help:
	echo "options: clean, build, release v=1.0.0"

# Remove the build folder
clean:
	-pwsh -noprofile -command ri $(BUILD_DIR) -Force -Recurse -ErrorAction SilentlyContinue

# Compile AHK files and compress with UPX
compile:
	pwsh -noprofile -command md $(BUILD_DIR) -Force
	$(AHK2EXE) /in $(APP_AHK) /out $(BUILD_DIR)\$(APP_EXE) /base $(AHK_BASE)
	pwsh -noprofile -command cp VirtualDesktopAccessor.dll $(BUILD_DIR)
	pwsh -noprofile -command cp -r .\icons\ $(BUILD_DIR)

# Compile and create a ZIP portable
zip: compile
	pwsh -noprofile -command Compress-Archive -Path $(APP_FILES) -DestinationPath "$(BUILD_ZIP)" -Force

# Compile and create a MSI installer
msi: compile
	wix build -acceptEula wix7 .\wix\VirtualDesktopExtension.wxs -ext $(WIX_UI_EXT)\WixToolset.UI.wixext.dll -ext $(WIX_UTIL_EXT)\WixToolset.Util.wixext.dll -arch x64 -out "$(BUILD_MSI)"

# Clean and build new packages
build: clean compile zip msi

# Create a GitHub release and publish .zip and .msi files
release:
	gh release create $(VERSION) $(BUILD_ZIP) $(BUILD_MSI) --repo $(GIT_REPO) --title "Release v$(VERSION)" --notes "Release version $(VERSION)"
