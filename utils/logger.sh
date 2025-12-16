#!/bin/bash

log(){
    echo "$(date '+%F %T'):$1" |tree -a "$LOG_FILE"
}