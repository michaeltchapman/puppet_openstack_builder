#!/bin/bash

for i in $(find $1 | grep "\.rpm"); do cp $i $2; done;
