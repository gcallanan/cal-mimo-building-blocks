echo "Compiling systolic array QR decomposition network to HDL"

set -e

current_date_time="`date +%Y-%m-%dT%H:%M:%S`";

rm -rf myproject

streamblocks vivado-hls --set experimental-network-elaboration=on --set bypass-AM-generation=on --source-path qrd_systolic_cordic_fixedpoint.cal --target-path myproject qrd.Top
#streamblocks vivado-hls --set experimental-network-elaboration=on --set reduction-algorithm=ordered-condition-checking --set default-controller=bc --source-path qrd_systolic.cal --target-path myproject qrd.Top
bash myproject/scripts/generateSimpleHDLTestbenches_vivado2023.sh

echo "Script execution started at: $current_date_time"
echo "Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"
