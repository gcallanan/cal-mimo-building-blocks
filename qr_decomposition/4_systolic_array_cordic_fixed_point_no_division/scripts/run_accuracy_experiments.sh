#!/bin/bash
echo "This script runs two mass experiments for the QR decomposition applications:"
echo "    1. It generates and colates results for different matrix sizes (K) and fixed point fractional precision."
echo "       This allows us to see how the accuracy is affected as the matrix size grows"
echo "    2. It generates and colates results for different CORDIC iterations(i) and fixed point fractional precision"
echo "       this allows us to see how the number of CORDIC iterations impacts the accuracy of our final results"
echo ""
echo "The output of these scripts is placed in the accuracy_results folder. There are .txt files that"
echo "contain the raw error results for each execution of the QR program. Additionally csv files are generated that"
echo "are collections of the errors for the different experiments in the same file to allow for easier analysis."
echo ""

set -e

start_date_time="`date +%Y-%m-%dT%H:%M:%S`";

echo "Starting experiments to measure accuracy when changing matrix size k and fixed point fractional size n"
for k in `seq 4 2 16`; do  # This is the matrix size
    echo "K is set to $k. Running tests with n from 19 to 27"
    for n in `seq 19 2 27`; do # This is the number of fractional bits in the fixed point number
        echo "    Running test for K=$k, n=$n, m=3 and i=16 (m and i are fixed)."
        # This commands just extracts the fourth last line from compile_software.sh which displays
        # the accuracy of the generated results. Additionally we add tabs to that line and then
        # display it. We suppress the rest of the output from the script as it makes it hard
        # to keep track with our progress
        \time -f "%E" -o time.log bash compile_software.sh -k $k -m 3 -n $n -i 16 | tail -n 4 | head -n 1 | sed 's/^/        /'
        
        # Print the execution time of the script
        cat time.log | sed 's/^/        Execution Time: /'
        rm time.log
    done
done

echo "Completed experiments for accuracy when scaling k and n"
echo ""
echo "Starting experiments to measure accuracy when changing CORDIC iterations i and fixed point fractional size n"
echo ""

for i in `seq 8 4 32`; do  # This is the number of CORDIC iterations
    echo "i is set to $i. Running tests with n from 19 to 27:"
    for n in `seq 19 2 27`; do # This is the number of fractional bits in the fixed point number
        echo "    Running test for K=16, n=$n, m=3 and i=$i (k and m are fixed)."
        # This commands just extracts the fourth last line from compile_software.sh which displays
        # the accuracy of the generated results. Additionally we add tabs to that line and then
        # display it. We suppress the rest of the output from the script as it makes it hard
        # to keep track with our progress
        \time -f "%E" -o time.log bash compile_software.sh -k 16 -m 3 -n $n -i $i | tail -n 4 | head -n 1 | sed 's/^/        /'
        
        # Print the execution time of the script
        cat time.log | sed 's/^/        Execution Time: /'
        rm time.log
    done
done

echo "All experiments run. Now we combine these results into csv files"

python3 scripts/generate_csv_from_accuracy_experiments.py

echo "Worst case error results recorded in 'results/experiment_results_largest_error.csv'"
echo "Average error results recorded in 'results/experiment_results_average_error.csv'"

end_date_time="`date +%Y-%m-%dT%H:%M:%S`";
echo "Script execution started at: $start_date_time"
echo "Script Total Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"

echo "Done"