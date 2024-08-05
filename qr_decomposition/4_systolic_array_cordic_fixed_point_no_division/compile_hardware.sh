#!/bin/bash
echo "Compiling systolic array QR decomposition network to HDL"
echo "This script takes in command line arguments:"
echo " -k K (default 4) Set the dimensions of the A matrix to be decomposed. A is a KxK matrix"
echo " -m M (default 3) Set the number of integer bits (including the sign bit) for Qm.n fixed point numbers"
echo " -n M (default 19) Set the number of fractional bits for Qm.n fixed point numbers"
echo " -i I (default 16) Set the number of iterations in the CORDIC process"
echo " -c C (default 10.0) FPGA Clock Period in nanoseconds"
echo " -l L (default -1) Loop unroll factor. -1 for disabled, 0 for as much as possible."
echo " -f FPGA_NAME (default xc7z020clg484-1) FPGA Part number to build"
echo " -o OUTPUT_DIRECTORY (default xc7z020clg484-1) FPGA Part number to build"

set -e

# 1. Interpret command line arguments
k=4
m=3
n=19
i=16
l=-1
clock_period_ns=10.0
fpga=xc7z020clg484-1
outputDirectory=myproject
vivado_2023_project_dir=vivado_2023_project_dir
topActor=Top
while getopts k:m:n:i:l:c:f:o: flag
do
    case "${flag}" in
        k) k=${OPTARG};;
        m) m=${OPTARG};;
        n) n=${OPTARG};;
        i) i=${OPTARG};;
        l) l=${OPTARG};;
        c) clock_period_ns=${OPTARG};;
        f) fpga=${OPTARG};;
        o) outputDirectory=${OPTARG};;
    esac
done

current_date_time="`date +%Y-%m-%dT%H:%M:%S`";
# 1.1 Set the m,n and k values in the qrd_systolic_cordic_fixedpoint.cal file
bash scripts/change_fixed_point_format.sh $m $n
sed -i  "s/    uint K = .*/    uint K = $k;/" qrd_systolic_cordic_fixedpoint.cal
sed -i  "s/    uint num_CORDIC_iterations = .*/    uint num_CORDIC_iterations = $i;/" qrd_systolic_cordic_fixedpoint.cal

# 2. Compile the CAL project to a mixture  Vitis HLS and HDL
streamblocks vivado-hls --set experimental-network-elaboration=on --source-path qrd_systolic_cordic_fixedpoint.cal --set foreach-loop-unroll-factor-hls=$l --target-path $outputDirectory qrd.$topActor
#streamblocks vivado-hls --set experimental-network-elaboration=on --set bypass-AM-generation=on --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top

# 3. Generate HDL from the HLS files
bash $outputDirectory/scripts/generateSimpleHDLTestbenches_vivado2023.sh -f $fpga -c $clock_period_ns

# 4. Generate an HDL project from all the generated HLS and HDL files. This project goes through synthesis
bash $outputDirectory/scripts/generateVivadoProjectAndSynthesize_vivado2023.sh -f $fpga -c $clock_period_ns -o $vivado_2023_project_dir

# 4.1 Add a few extra testbench files to the project. Do this by generating a TCL script and running it in Vivado
currentDir=`pwd`
projDir=$currentDir/$outputDirectory/$vivado_2023_project_dir
echo "
open_project $projDir/$topActor/$topActor.xpr
import_files -fileset sim_1 -norecurse {$currentDir/$outputDirectory/code-gen/rtl-tb/tb_innerCells_q_0_simple_vivado2023.v}
import_files -fileset sim_1 -norecurse {$currentDir/$outputDirectory/code-gen/rtl-tb/tb_boundaryCells_0_simple_vivado2023.v}
import_files -fileset sim_1 -norecurse {$currentDir/$outputDirectory/code-gen/rtl-tb/tb_source_simple_vivado2023.v}
exit
" > addMoreTestbenchesToProject.tcl
vivado -script addMoreTestbenchesToProject.tcl -mode tcl
rm addMoreTestbenchesToProject.tcl

echo "Script execution started at: $current_date_time"
echo "Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"
