#!/bin/bash

DATE=$(date +%Y-%m-%d-%H%M%S)
BACKUP_DIR="$HOME"
SOURCE="$HOME/Downloads/MyHome"
tar -cvzpf $BACKUP_DIR/backup-$DATE.tar.gz $SOURCE
