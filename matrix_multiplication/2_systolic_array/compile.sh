set -e

rm -rf myproject/build

streamblocks multicore --set experimental-network-elaboration=on --source-path matrix_mult_systolic.cal --target-path myproject mat_mul.Top

mkdir -p  myproject/build/
cd myproject/build/
cmake ..
time cmake --build . -j48

cd ../bin
./Top
