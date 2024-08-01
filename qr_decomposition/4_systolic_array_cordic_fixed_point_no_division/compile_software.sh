#!/bin/bash
echo "Compiling systolic array QR decomposition network to C++ and executing it"
echo "This script takes in command line arguments:"
echo " -k K (default 4) Set the dimensions of the A matrix to be decomposed. A is a KxK matrix"
echo " -m M (default 3) Set the number of integer bits (including the sign bit) for Qm.n fixed point numbers"
echo " -n M (default 19) Set the number of fractional bits for Qm.n fixed point numbers"
echo " -i I (default 16) Set the number of iterations in the CORDIC process"
set -e
rm -rf myprojects
mkdir -p results

current_date_time="`date +%Y-%m-%dT%H:%M:%S`";

# 1. Interpret command line arguments
k=4
m=3
n=19
i=16
while getopts k:m:n:i: flag
do
    case "${flag}" in
        k) k=${OPTARG};;
        m) m=${OPTARG};;
        n) n=${OPTARG};;
        i) i=${OPTARG};;
    esac
done

# 1.1 Set the m,n and k values in the qrd_systolic_cordic_fixedpoint.cal file
bash scripts/change_fixed_point_format.sh $m $n
sed -i  "s/    uint K = .*/    uint K = $k;/" qrd_systolic_cordic_fixedpoint.cal
sed -i  "s/    uint num_CORDIC_iterations = .*/    uint num_CORDIC_iterations = $i;/" qrd_systolic_cordic_fixedpoint.cal

# 2. Generate C++ code from CAL code
streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top

# If you want to use the randInt function to generate the source actors, comment out the
# "streamblocks multicore ..." line above and uncomment the next 6 lines, see comments in
# the Source actor for "qrd_systolic_cordic_fixedpoint.cal" for more info.
#if [ ! -d "streamblocks-examples" ]; then
#  echo "Missing the streamblocks-examples repository in this directory. It is required to call the sqrt() function."
#  echo "Pull with 'git clone https://github.com/streamblocks/streamblocks-examples.git'"
#  exit 1
#fi
#streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic_cordic_fixedpoint.cal:streamblocks-examples/system --target-path myproject qrd.Top
# End of lines to uncomment

# 3. Build the project binary
mkdir -p  myproject/build/
cd myproject/build/
cmake .. 2> /dev/null
cmake --build . -j24 2> /dev/null

# 4. Execute the binary, send output of execution to stdout and a file
filename=capture_k${k}_i${i}_Q${m}p${n}.txt
cd ../bin
./Top | tee ../../accuracy_results/$filename

# 5. Verify results
cd ../..
res=$(python3 scripts/error_checker.py -s -m $m -n $n -f results/$filename)
echo "Highest, Mean error is (out of 1): $res"

# 6. Done, print ending info
echo "Software execution complete - results copied to '$filename'"
echo "Script execution started at: $current_date_time"
echo "Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"
