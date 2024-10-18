#!/usr/bin/env bash

# nVIDIA fix-tearing
# LG sudo nvidia-settings --assign CurrentMetaMode="HDMI-0:1920x1080_60 +0+0 { ForceFullCompositionPipeline = On }"

sudo nvidia-settings --assign "CurrentMetaMode=HDMI-0: nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
