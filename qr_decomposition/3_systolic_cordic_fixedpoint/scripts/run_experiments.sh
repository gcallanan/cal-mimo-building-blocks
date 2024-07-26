#!/bin/bash
echo "Script that runs multiple iterations of QRD for different matrix sizes and fixed point fractional formats."
echo "This allows us to generate results for all these different formats and see what accuracy is expected."
echo ""

start_date_time="`date +%Y-%m-%dT%H:%M:%S`";

for k in {2..25}; do  # This is the matrix size
    echo "K is set to $k. Running tests with n from 19 to 28:"
    for n in {19..28}; do # This is the number of fractional bits in the fixed point number
        echo "    Running test for K=$k, n=$n, and m=3 (m is fixed)."
        # This commands just extracts the fourth last line from compile_software.sh which displays
        # the accuracy of the generated results. Additionally we add tabs to that line and then
        # display it. We suppress the rest of the output from the script as it makes it hard
        # to keep track with our progress
        \time -f "%E" -o time.log bash compile_software.sh -k $k -m 3 -n $n | tail -n 4 | head -n 1 | sed 's/^/        /'
        
        # Print the execution time of the script
        cat time.log | sed 's/^/        Execution Time: /'
        rm time.log
    done
done

echo "All experiments run. Now we combine these results into csv files"

python3 scripts/generate_csv_from_experiments.py

echo "Worst case error results recorded in 'results/experiment_results_largest_error.csv'"
echo "Average error results recorded in 'results/experiment_results_average_error.csv'"

end_date_time="`date +%Y-%m-%dT%H:%M:%S`";
echo "Script execution started at: $start_date_time"
echo "Script Total Execution time: $(date -d@$SECONDS -u +%H:%M:%S)"

echo "Done"