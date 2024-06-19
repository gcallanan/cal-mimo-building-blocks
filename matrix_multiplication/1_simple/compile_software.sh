echo "Compiling naive matrix multiplication network to C++ and executing it."

set -e

current_date_time="`date +%Y-%m-%dT%H:%M:%S`";

rm -rf myproject

streamblocks multicore --set experimental-network-elaboration=on --source-path matrix_multiplication.cal --target-path myproject mat_mul.Top

mkdir -p  myproject/build/
cd myproject/build/
cmake ..
time cmake --build . -j48

cd ../bin
./Top

echo "Script execution started at: $current_date_time"
echo "Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"
