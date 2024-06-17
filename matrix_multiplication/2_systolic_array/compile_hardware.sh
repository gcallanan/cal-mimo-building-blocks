set -e

current_date_time="`date +%Y-%m-%dT%H:%M:%S`";

rm -rf myproject/build

streamblocks vivado-hls --set experimental-network-elaboration=on --source-path matrix_mult_systolic.cal --target-path myproject mat_mul.Top
#tychoc --set experimental-network-elaboration=on --source-path matrix_mult_systolic.cal --target-path myproject mat_mul.Top
bash myproject/scripts/generateSimpleHDLTestbenches_vivado2023.sh

echo "Script execution started at: $current_date_time"
echo "Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"
