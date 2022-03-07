#!/bin/bash

# Uses kitty remote control to convert the current tab into a 3-pane system
kitty @ goto-layout tall
kitty @ launch --type=window --cwd current --no-response
kitty @ launch --type=window --cwd current --no-response

