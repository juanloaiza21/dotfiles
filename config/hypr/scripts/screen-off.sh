#!/usr/bin/env bash
# Turn the monitors off (DPMS) WITHOUT suspending: every process keeps running.
# Any key press or mouse move wakes them (misc.key_press_enables_dpms / mouse_move_enables_dpms).
# Short delay so the key press (or the rofi click) that launched this doesn't wake them right away.
sleep 0.6
hyprctl dispatch 'hl.dsp.dpms({ action = "off" })' >/dev/null
