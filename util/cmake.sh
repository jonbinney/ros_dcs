#!/bin/bash
LOGFILE=/ws/cmake_log
env|grep CMAKE >> $LOGFILE
echo "`pwd` + $@" >> $LOGFILE
exec /usr/bin/cmake.orig "$@"
