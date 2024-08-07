#!/bin/bash
echo "This script runs two mass experiments for the QR decomposition applications:"
echo "    1. It builds the K=16 QR Algorithm for different FPGA models, clocks speeds and loop"
echo "       unroll factors to see how timing and resource utilisation change with these parameters"
echo "    2. It builds QR algorithm for different sizes of K to see how resource utilisation"
echo "       and latency change as problem size increases"
echo ""
echo "The results from the first experiment are saved in the 'fpga_param_experiments' directory"
echo "The results from the second experiment are saved in the 'fpga_scaling_experiments' directory"
echo ""

set -e
start_date_time="`date +%Y-%m-%dT%H:%M:%S`";


k=16
n=19
i=16
m=3

# These are the variable parameters for the first experiment
fpgas_partno=('xc7z020clg484-1' 'xczu7ev-ffvf1517-1-i')
fpgas_name=('Zync7000' 'ZyncUltrascalePlus')
clock_periods_ns=('10.0' '5.0' '3.3')
loop_unroll_factors=('-1' '0' '2' '4' '8')


num_fpgas=${#fpgas_partno[@]}
num_experiments=$(($num_fpgas * ${#clock_periods_ns[@]} * ${#loop_unroll_factors[@]}))
experiment_directory=fpga_param_experiments
reports_directory=$experiment_directory/reports

mkdir -p $experiment_directory
mkdir -p $reports_directory

# 1. First Experiment
#echo "Generating results for the first experiment:"
#index=1
#for fpga_index in `seq 1 1 $num_fpgas`; do
#    fpga_partno="${fpgas_partno[$fpga_index-1]}"
#    fpga_name="${fpgas_name[$fpga_index-1]}"
#    for clock_period_ns in "${clock_periods_ns[@]}"; do
#        for loop_unroll_factor in "${loop_unroll_factors[@]}"; do
#            echo "Experiment ${index}/${num_experiments}: FPGA: $fpga_name Clock: $clock_period_ns ns Unroll: $loop_unroll_factor"
#            
#            clock=`echo $clock_period_ns | tr . p`
#            project_name=build_k${k}_Q${m}p${n}_i${i}_${fpga_name}_clk${clock}
#            if [ $loop_unroll_factor -eq -1 ]; then
#                project_name=${project_name}_unrollNone
#            else
#                if [ $loop_unroll_factor -eq 0 ]; then
#                    project_name=${project_name}_unrollAll
#                else
#                    project_name=${project_name}_unroll${loop_unroll_factor}
#                fi
#            fi
#            project_directory=${experiment_directory}/$project_name
#            echo "    Output Folder: $project_directory/"
#            
#            logFileName=$project_directory.log
#            \time -f "%E" -o time.log bash compile_hardware.sh -k $k -m $m -n $n -i $i -c $clock_period_ns -l $loop_unroll_factor -f $fpga_partno -o $project_directory > $logFileName
#            cat time.log | sed 's/^/        Execution Time: /'
#            rm time.log
#
#            cp $project_directory/build/timing_summary.rpt $reports_directory/${project_name}_timing.rpt
#            cp $project_directory/build/report_utilization.rpt $reports_directory/${project_name}_utilisation.rpt
#
#            index=$(($index + 1))
#        done
#    done
#done
#echo "First Experiment Done"
#echo ""

# 2. Second Experiment
echo "Generating results for the second experiment:"
experiment_directory=fpga_scaling_experiments
reports_directory=$experiment_directory/reports
mkdir -p $experiment_directory
mkdir -p $reports_directory

num_experiments=`seq 2 2 16 | wc -l`
fpga_partno="${fpgas_partno[1]}"
fpga_name="${fpgas_name[1]}"
loop_unroll_factor="${loop_unroll_factors[0]}"
clock_period_ns="${clock_periods_ns[0]}"
clock=`echo $clock_period_ns | tr . p`

index=1
for k in `seq 2 2 16`; do
    echo "Experiment ${index}/${num_experiments}: k=$k"
    project_name=build_k${k}_Q${m}p${n}_i${i}_${fpga_name}_clk${clock}_unrollNone
    project_directory=${experiment_directory}/$project_name
    echo "    Output Folder: $project_directory/"

    logFileName=$project_directory.log
    \time -f "%E" -o time.log bash compile_hardware.sh -k $k -m $m -n $n -i $i -c $clock_period_ns -l $loop_unroll_factor -f $fpga_partno -o $project_directory > $logFileName
    cat time.log | sed 's/^/        Execution Time: /'
    rm time.log

    cp $project_directory/build/timing_summary.rpt $reports_directory/${project_name}_timing.rpt
    cp $project_directory/build/report_utilization.rpt $reports_directory/${project_name}_utilisation.rpt

    index=$(($index + 1))
done
echo "Second Experiment Done"
echo ""

end_date_time="`date +%Y-%m-%dT%H:%M:%S`";
echo "Script execution started at: $start_date_time"
echo "Script Total Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"

echo "Done"
