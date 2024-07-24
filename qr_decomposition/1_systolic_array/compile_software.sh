echo "Compiling systolic array QR decomposition network to C++ and executing it"

set -e

current_date_time="`date +%Y-%m-%dT%H:%M:%S`";

if [ ! -d "streamblocks-examples" ]; then
  echo "Missing the streamblocks-examples repository in this directory. It is required to call the sqrt() function."
  echo "Pull with 'git clone https://github.com/streamblocks/streamblocks-examples.git'"
  exit 1
fi

rm -rf myprojects

streamblocks multicore --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic.cal:streamblocks-examples/system --target-path myproject qrd.Top
#tychoc --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --source-path qrd_systolic.cal --target-path myproject qrd.Top

mkdir -p  myproject/build/
cd myproject/build/
cmake ..
time cmake --build . -j24

cd ../bin
./Top

echo "Script execution started at: $current_date_time"
echo "Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"
