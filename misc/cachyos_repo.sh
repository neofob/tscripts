#!/usr/bin/env bash

pacman -Scc
pacman -Sy
pacman -Qqn | pacman -S -
