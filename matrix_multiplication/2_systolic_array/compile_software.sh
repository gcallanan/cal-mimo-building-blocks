echo "Compiling systolic array matrix multiplication network to C++ and executing it"

set -e

current_date_time="`date +%Y-%m-%dT%H:%M:%S`";

rm -rf myproject/build

streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path matrix_mult_systolic.cal --target-path myproject mat_mul.Top
#tychoc --set experimental-network-elaboration=on --source-path matrix_mult_systolic.cal --target-path myproject mat_mul.Top

mkdir -p  myproject/build/
cd myproject/build/
cmake ..
time cmake --build . -j24

cd ../bin
./Top

echo "Script execution started at: $current_date_time"
echo "Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"
