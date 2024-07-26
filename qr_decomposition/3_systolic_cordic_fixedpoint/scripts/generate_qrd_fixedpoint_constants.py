# A program that generates the CAL code to be inserted into qrd_systolic_cordic_fixedpoint.cal file
# to change the format of the fixed point numbers being used.
#
# NOTE: This overwrites qrd_systolic_cordic_fixedpoint.cal


import argparse
parser = argparse.ArgumentParser(
                    prog='Fixed Point CAL Code Generator',
                    description='A program that generates the CAL code to be inserted into qrd_systolic_cordic_fixedpoint.cal file to change the format of the fixed point numbers being used.'
         )
parser.add_argument('-n', '--fixed_point_n', type=int, default=19, help="Number of fractional bits n for Qm.n fixed point numer")
parser.add_argument('-m', '--fixed_point_m', type=int, default=3, help="Number of integer bits m (including sign bit) for Qm.n fixed point numer")
args = parser.parse_args()


# Floating point format Qm.n
m = args.fixed_point_m
n = args.fixed_point_n

fp_one = 1 << n
fp_minus_one = -fp_one 

k = 0.607252956441381
k_fp = int(k * (2 ** n))
k_actual = k_fp * (2.0 ** -n)


increment = 0.11
increment_fp = int(increment * (2 ** n))
increment_actual = increment_fp * (2.0 ** -n)

lowerBoundary_P = 0.00005
lowerBoundary_P_fp = int(lowerBoundary_P * (2 ** n))
lowerBoundary_P_actual = lowerBoundary_P_fp * (2.0 ** -n)

lowerBoundary_N = -0.00005
lowerBoundary_N_fp = int(lowerBoundary_N * (2 ** n))
lowerBoundary_N_actual = lowerBoundary_N_fp * (2.0 ** -n)

output=f"""    // ==== Fixed Point Constants: Start ===

    // Fixed point number represented by Qm.n where m is the number of integer bits + sign bit
    // and n is the fractional component.
    uint m = {m};
    uint n = {n};

    // Fixed Point Constants - These are useful constants that we need to define
    // here to get the correct value when interpreting them as fixed points.
    int(size = m+n) fixed_point_one = {fp_one};
    int(size = m+n) fixed_point_minus_one = {fp_minus_one};
    int(size = m+n) nearZeroBoundaryP = {lowerBoundary_P_fp}; // {lowerBoundary_P_actual:.10f} in Q{m}.{n} representation
    int(size = m+n) nearZeroBoundaryN = {lowerBoundary_N_fp}; // {lowerBoundary_N_actual:.10f} in Q{m}.{n} representation
    int(size = m+n) fp_increment = {increment_fp}; // {increment_actual:.10f} in Q{m}.{n} format

    // The constant value that we need to multiply the results of the CORDIC algorithm by
    // k = 0.607252956441381. The fixed point equivalent of this is:
    int(size = m+n) k_CORDIC_constant = {k_fp}; // {k_actual:.10f} in Q{m}.{n} format

    // ==== Fixed Point Constants: End ==="""

print(output)