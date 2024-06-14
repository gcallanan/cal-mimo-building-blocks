set -e

rm -rf myproject/build

streamblocks multicore --source-path matrix_multiplication.cal --target-path myproject mat_mul.Top

mkdir -p  myproject/build/
cd myproject/build/
cmake ..
time cmake --build . -j24

cd ../bin
./Top
