#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

gnome-terminal --geometry=128x32 -- bash -c "cd \"$SCRIPT_DIR\" && ./omp-server; exec bash"