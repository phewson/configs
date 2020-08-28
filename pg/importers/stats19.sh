#!/bin/bash

TARGETPATH="$HOME/data/dft"
wget -nc -i stats19.txt --limit-rate=200k -P "$TARGETPATH"
