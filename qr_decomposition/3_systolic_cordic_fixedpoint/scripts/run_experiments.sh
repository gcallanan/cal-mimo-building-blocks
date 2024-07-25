#!/bin/bash
echo "Script that runs multiple iterations of QRD for different matrix sizes and fixed point fractional formats."
echo "This allows us to generate results for all these different formats and see what accuracy is expected."
echo ""

for k in {2..25}; do  # This is the matri size
    echo "K is set to $k. Running tests with n from 19 to 29:"
    for n in {19..29}; do
        echo "    Running test for K=$k, n=$n, and m=3 (m is fixed)."
        # This commands just extracts the fourth last line from compile_software.sh which displays
        # the accuracy of the generated results. Additionally we add tabs to that line and then
        # display it. We suppress the rest of the output from the script as it makes it hard
        # to keep track with our progress
        bash compile_software.sh -k $k -m 3 -n $n | tail -n 4 | head -n 1 | sed 's/^/        /'
    done
done

echo "Done"