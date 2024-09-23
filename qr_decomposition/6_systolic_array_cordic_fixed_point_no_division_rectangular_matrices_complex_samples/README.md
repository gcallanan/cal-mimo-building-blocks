# Fixed-Point QR Decomposition using Givens Rotations and the CORDIC algorithm on a Systolic Array using Dataflow for non-square sized matrices.

## Introduction

A parametric systolic array implementation of QR decomposition using the Givens Rotations method written in the CAL actor language. All numbers are represented in fixed point format and square root . The file implementing this application is the [qrd_systolic_cordic_fixedpoint.cal](qrd_systolic_cordic_fixedpoint.cal) file. This file has lots of comments and references explaining the theory and implementation. Please see that file that file first to understand what is going on here. Previous implementations supported square KxK sized A matrices. This implementation supports rectangular MxN sized A matrices.

## Requirements

1. Operating System: `Ubuntu 2020` or above
2. `Streamblocks` - This is the compiler that we use to convert CAL to C++ or Xilinx's HDL/Vitis format. You need to download and install both the [frontend](https://github.com/streamblocks/streamblocks-tycho) and [backend](https://github.com/streamblocks/streamblocks-platforms) projects.
3. `Vivado 2023.2` - This is only required when compiling the application to hardware (FPGAs)
4. Additional python scripts are executed in `python3`. The `numpy` and `pandas` packages are expected to be installed.

## Building and Running the application

There are two scripts in the top level of the directory. 
1. [compile_software.sh](compile_software.sh) - This script compiles the CAL program to a C++ project. It then runs that project and reports on the accuracy of the result. It generate results which are saved in a capture_*.txt file located in a results directory that will be created in this project. 
2. [compile_hardware.sh](compile_hardware.sh) - This script compiles the CAL program to a a number of Vivado HLS and HDL files. It then also compiles those HLS files to HDL and puts them in a common folder. A rough testbench for each of the HDL file is then generated. Its up to you to copy the HDL files in a folder to a Vivado project for simulation and compilation.

## Additional scripts

This project contains an additional [scripts](scripts/) directory to make common functions quite easy. The scripts in this directory include:
1. [error_checker.py](scripts/error_checker.py) - The [compile_software.sh](compile_software.sh) generates a capture_*.txt containing the source integer value of the fixed point A matrix and the generated Q and R matrices. This file translates those integer values to the actual real values and then reports the accuracy of the A matrix created by multiplying Q and R with the original A matrix. This is useful as the raw captures are not very useful.
2. [change_fixed_point_format.sh](scripts/change_fixed_point_format.sh) - Sometimes you want to change the fixed point representation from the default (Q3.19). However, this requires that changing a bunch of values in the [qrd_systolic_cordic_fixedpoint.cal](qrd_systolic_cordic_fixedpoint.cal) file get changed. This script takes care of replacing all those values. So run this script from the [3_systolic_cordic_fixedpoint](3_systolic_cordic_fixedpoint) directory to update the CAL implemtation. The compilation scripts also call this script so you may not even notice that it is being called.
3. [generate_qrd_fixedpoint_constants.py](scripts/generate_qrd_fixedpoint_constants.py) - Used by the [change_fixed_point_format.sh](scripts/change_fixed_point_format.sh) script when generating the correct fixed point values.
4. [run_accuracy_experiments.sh](scripts/run_accuracy_experiments.sh) - Script that builds and executes the software implementation of the program for different parameter values and stores the accuracy results for the different builds in csv files. This allows us to see how accuracy of the results change for different matrix sizes, floating point implementations and CORDIC iterations. The actor network is compiled down to software
for quick code generation and results. 
5. [generate_csv_from_accuracy_experiments.py](scripts/generate_csv_from_accuracy_experiments.py) - Used by [run_accuracy_experiments.sh](scripts/run_accuracy_experiments.sh) to generate the CSV files of all the accuracy results.
6. [run_hardware_experiments.sh](scripts/run_hardware_experiments.sh) - Script that builds and synthesises the hardware implementation of the program for different parameter values. This allows us to see how the resource
use and timing change with for different problem sizes, clock cycles, devices and loop unroll factors.
7. [generate_csv_from_hardware_experiments.py](scripts/generate_csv_from_hardware_experiments.py) - Used by [run_hardware_experiments.sh](scripts/run_hardware_experiments.sh) to generate CSV files containing resource use and timing results,