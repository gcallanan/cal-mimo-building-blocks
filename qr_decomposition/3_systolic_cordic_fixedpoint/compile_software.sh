#!/bin/bash
echo "Compiling systolic array QR decomposition network to C++ and executing it"
set -e
rm -rf myprojects

current_date_time="`date +%Y-%m-%dT%H:%M:%S`";

# Floating point format of Qm.n
m=3
n=19

# 1. Generate C++ code from CAL code
streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top

# 2. Build the project binary
mkdir -p  myproject/build/
cd myproject/build/
cmake ..
time cmake --build . -j24

# 3. Execute the binary, send output of execution to stdout and  and capture.txt
cd ../bin
./Top | tee ../../capture.txt

# 4. Verify results
cd ../..
res=$(python3 qrdSystolicArrayErrorChecker.py -s -m $m -n $n)
echo "Maximum Error is: $res (maximum is one)"

# 5. Done, print ending info
echo "Software execution complete - results copied to 'capture.txt'"
echo "Script execution started at: $current_date_time"
echo "Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"
