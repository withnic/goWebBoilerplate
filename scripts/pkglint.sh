#!/usr/bin/env bash

for pkg in $@
do
  if [[ $pkg =~ /(utils?|commons?|helpers?|shares?|)$ ]];
  then
    echo $pkg
    echo "Avoid meaningless package names"
    exit 1
  fi
done
