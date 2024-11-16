#!/bin/bash

if [[ $AUTOSTART_SERVER = "true" ]] || [[ $AUTOSTART_SERVER = "web_only" ]]; then
  . /usr/local/bin/wine_init.sh

  . /usr/local/bin/wine_symlinks.sh

  . /usr/local/bin/copy_server_config.sh

  . /usr/local/bin/cleanup_logs.sh

  if [[ $AUTOSTART_SERVER = "true" ]]; then
    node /usr/local/bin/start_game.mjs &
  fi;

  . /usr/local/bin/start_fs25.sh
else
  # pause in case autostart was disabled
  cat
fi;
