#!/bin/bash

# Modify the qrd_systolic_cordic_fixedpoint.cal to use a different fixed point format.
#
# The format is Qm.n where m is the integer part (including the sign bit) and n is the 
# fractional part.
#
# This script modified the values of m and n in qrd_systolic_cordic_fixedpoint.cal as well
# as generating the correct required constant values.
#
# Run the script with:
#   bash generate_qrd_fixedpoint_constants.py m n
# With no arguments, this script sets m=3 and n=19. 

m=${1:-3}
n=${2:-19}

sed '/ ==== Fixed Point Constants: Start ===/Q' qrd_systolic_cordic_fixedpoint.cal > temp.txt
python3 generate_qrd_fixedpoint_constants.py -m $m -n $n >> temp.txt
sed '1,/==== Fixed Point Constants: End ===/d' qrd_systolic_cordic_fixedpoint.cal >> temp.txt
cat temp.txt > qrd_systolic_cordic_fixedpoint.cal
rm temp.txt