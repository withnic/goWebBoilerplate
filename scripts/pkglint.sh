#!/usr/bin/env bash

for pkg in $@
do
  if [[ $pkg =~ /(util|utils|common|commons|helper|helpers)$ ]];
  then
    echo $pkg
    echo "Avoid meaningless package names"
    exit 1
  fi
done