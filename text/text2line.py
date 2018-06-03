#!/usr/bin/env python
# tested with python3.5
# Reference:
# https://stackoverflow.com/questions/48919331/how-to-parse-a-file-sentence-by-sentence-in-python

# Requirement:
# pip install nltk
# text2line.py input.txt > output.txt

import nltk.data
import sys

tokenizer = nltk.data.load('tokenizers/punkt/english.pickle')
fp = open(str(sys.argv[1]))
data = fp.read()
result = tokenizer.tokenize(data)

for sentence in result:
    print(sentence.replace("\n", " "))
