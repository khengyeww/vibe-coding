#!/bin/bash

# Colors
RESET="\e[0m"
MAGENTA="\e[35m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BOLD_CYAN="\e[1;96m"

# -- Configurable UI START -- #
# Label
LABEL="Progress"

# Progress Bar (Make it random!)
filled_chars=("#" "█" "▓")
empty_chars=("-" "·" "⋅" "✕" "╌")

# Spinner
SPINNER_SETS=(
  "| / - \\"
  "· o O o ·"
  "⠁ ⠂ ⠄ ⠂"
  "⠋ ⠙ ⠸ ⠴ ⠦ ⠇"
  # "⠋ ⠙ ⠸ ⠴ ⠦ ⠧ ⠇ ⠏"
)

# Multiplier for spinner speed (<1 → faster, >1 → slower)
SPINNER_SPEED_FACTOR=1.25
# -- Configurable UI END -- #

prefix="${LABEL}: "
FILLED_CHAR=${filled_chars[$RANDOM % ${#filled_chars[@]}]}
EMPTY_CHAR=${empty_chars[$RANDOM % ${#empty_chars[@]}]}
chosen="${SPINNER_SETS[$((RANDOM % ${#SPINNER_SETS[@]}))]}"
read -ra SPINNER <<< "$chosen"

# Use fixed values instead of random
# FILLED_CHAR="#"
# EMPTY_CHAR="-"
# SPINNER=( "|" "/" "-" "\\" )

logs=(
  "INFO: Initializing environment..."
  "INFO: Loading configuration..."
  "INFO: Connecting to database..."
  "WARN: Missing optional dependency..."
  "INFO: Compiling core module..."
  "INFO: Compiling UI components..."
  "INFO: Optimizing assets..."
  "INFO: Bundling resources..."
  "INFO: Uploading artifacts..."
  "ERROR: Unit test failed for module A"
  "INFO: Running integration tests..."
  "INFO: Linting code..."
  "INFO: Applying migrations..."
  "INFO: Seeding database..."
  "WARN: Temporary files missing, creating..."
  "INFO: Generating documentation..."
  "INFO: Starting services..."
  "INFO: Running health checks..."
  "INFO: Deploying application..."
  "INFO: Finalizing process..."
)

total=${#logs[@]}
max_visible=10
log_window=()
spinner_speed=0.05
steps_per_log=5

clear
i=0
frame_index=0

while [ $i -lt $total ]; do
  for step in $(seq 1 $steps_per_log); do
    progress=$(( (i * steps_per_log + step) * 100 / (total * steps_per_log) ))

    # Terminal width
    term_width=$(tput cols)

    # Spinner
    frame=""
    # Calculate spinner index using bc (supports decimals)
    spinner_index=$(echo "scale=0; $frame_index / $SPINNER_SPEED_FACTOR" | bc)
    [ $progress -lt 100 ] && frame="${SPINNER[$((spinner_index % ${#SPINNER[@]}))]} "

    # Progress with percent sign as string
    progress_str="${progress}%"

    # Fixed width of static text (visible chars only)
    # prefix, spinner, progress, +1 space
    fixed_width=$((${#prefix} + 3 + ${#frame} + ${#progress_str} + 1))

    # Bar width = terminal width - fixed width
    bar_width=$((term_width - fixed_width))
    [ $bar_width -lt 10 ] && bar_width=10

    # Done / left
    done=$(( (bar_width * progress) / 100 ))
    left=$(( bar_width - done ))

    # Build bar (no color codes inside yet)
    # bar="$(printf "%0.s#" $(seq 1 $done))$(printf "%0.s." $(seq 1 $left))"
    bar="$(printf "%0.s$FILLED_CHAR" $(seq 1 $done))"
    [ $left -gt 0 ] && bar+=$(printf "%0.s$EMPTY_CHAR" $(seq 1 $left))

    # Move cursor to top-left
    tput cup 0 0

    # Print progress bar
    printf "\r%s[${MAGENTA}%s${RESET}] ${BOLD_CYAN}%s${RESET}%s" "$prefix" "$bar" "$frame" "$progress_str"
    printf "\033[K\n" # clear rest of line

    # Print log window
    for line in "${log_window[@]}"; do
      log_type="${line:9:4}"  # timestamp is 8 chars + space
      case "$log_type" in
        INFO) color="$GREEN" ;;
        WARN) color="$YELLOW" ;;
        ERRO) color="$RED" ;;
        *) color="$RESET" ;;
      esac
      printf "%b%-${term_width}s%b\n" "$color" "$line" "$RESET"
    done

    sleep $spinner_speed
    ((frame_index++))
  done

  # Add next log line with timestamp
  log_window+=("$(date +%H:%M:%S) ${logs[$i]}")
  ((i++))
  [ ${#log_window[@]} -gt $max_visible ] && log_window=("${log_window[@]:1}")
done

echo "Process completed successfully!"
