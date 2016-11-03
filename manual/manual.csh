#!/bin/csh
#
#   To make the MOPAC Manual
#
if -e mopac.idx makeindex mopac.idx
latex mopac
