#!/usr/bin/env bash
# Use text2lines.py
# Usage:
# text2input.sh LargeText.txt > LargeInput.txt
#  1. Parse the input file LargeText.txt to sentences
#  2. Prefix those lines with "> " for input format of chatbot-rnn

text2line.py $1 | awk '{print "> " $0}'
