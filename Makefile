# SPDX-License-Identifier: CC0-1.0
#
# SPDX-FileContributor: Antonio Niño Díaz, 2023

# User config
# ===========

NAME			:= NeoDS

GAME_TITLE		:= NeoDS
GAME_SUBTITLE1	:= Built with BlocksDS
GAME_SUBTITLE2	:= http://skylyrac.net
GAME_ICON		:= icon.bmp

# DLDI and internal SD slot of DSi
# --------------------------------

# Root folder of the SD image
SDROOT		:= sdroot
# Name of the generated image it "DSi-1.sd" for no$gba in DSi mode
SDIMAGE		:= image.bin

# Source code paths
# -----------------

NITROFATDIR	:=

# Tools
# -----

MAKE		:= make
RM			:= rm -rf

# Verbose flag
# ------------

ifeq ($(VERBOSE),1)
V		:=
else
V		:= @
endif

# Directories
# -----------

ARM9DIR		:= arm9
ARM7DIR		:= arm7

# Build artfacts
# --------------

NITROFAT_IMG	:= build/nitrofat.bin
ROM				:= $(NAME).nds

# Targets
# -------

.PHONY: all clean arm9 arm7 dldipatch sdimage

all: $(ROM)

clean:
	@echo "  CLEAN"
	$(V)$(MAKE) -f arm9/Makefile clean --no-print-directory
	$(V)$(MAKE) -f arm7/Makefile clean --no-print-directory
	$(V)$(RM) $(ROM) build $(SDIMAGE)

arm9:
	$(V)+$(MAKE) -f arm9/Makefile --no-print-directory

arm7:
	$(V)+$(MAKE) -f arm7/Makefile --no-print-directory

ifneq ($(strip $(NITROFATDIR)),)
# Additional arguments for ndstool
NDSTOOL_FAT	:= -F $(NITROFAT_IMG)

$(NITROFAT_IMG): $(NITROFATDIR)
	@echo "  IMGBUILD $@ $(NITROFATDIR)"
	$(V)sh $(BLOCKSDS)/tools/imgbuild/imgbuild.sh $@ $(NITROFATDIR)

# Make the NDS ROM depend on the filesystem image only if it is needed
$(ROM): $(NITROFAT_IMG)
endif

$(ROM): arm9 arm7
	@echo "  NDSTOOL $@"
	$(V)$(BLOCKSDS)/tools/ndstool/ndstool -c $@ \
		-7 arm7/build/arm7.elf -9 arm9/build/arm9.elf \
		-b $(GAME_ICON) "$(GAME_TITLE);$(GAME_SUBTITLE1);$(GAME_SUBTITLE2)" \
		$(NDSTOOL_FAT)

sdimage:
	@echo "  IMGBUILD $(SDIMAGE) $(SDROOT)"
	$(V)sh $(BLOCKSDS)/tools/imgbuild/imgbuild.sh $(SDIMAGE) $(SDROOT)

dldipatch: $(ROM)
	@echo "  DLDITOOL $(ROM)"
	$(V)$(BLOCKSDS)/tools/dlditool/dlditool \
		$(BLOCKSDS)/tools/dldi/r4tfv2.dldi $(ROM)