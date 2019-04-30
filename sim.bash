#!/bin/bash

cd modelsim

if [ "$1" == "-i" ]; then
    modelsim -do sim.fdo
else
    vsim -do sim.fdo
fi
