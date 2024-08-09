"""
This is a very rough script. It looks at all the captures in the accuracy_results folder, gets the
error value for each capture and then puts all the errors for the different captures into an csv
file for easy comparision between the different captures.

There are two different experiments available in the results file:
    1. Captures varying fixed point fractional component n and matrix size K.
    2. Captures varying fixed point fractional component n and number of CORDIC rotations i.

For each experiment the following is captured:
    1. The worst error among all the entries between the input A matrix and the recreated A matrix
    2. The average error among all the entries between the input A matrix and the recreated A matrix

This results in 4 csv files, 2 for each experiment.
"""

import error_checker
import os
import time

# 1. Generate csv files for the first experiment
# 1.1 Load the names of all the capture files in the results folder where the number of cordic iterations is 16
directory_string = "accuracy_results/"
result_files_names = [f for f in os.listdir(directory_string) if os.path.isfile(os.path.join(directory_string, f)) and "capture_k" in f and "i16" in f]

# 1.2 Get a list of all unique matrix sizes "K" from the list of experiments.
k_values_not_unique_not_sorted = [int(f[f.find("_")+2:f.find("_",f.find("_")+2)]) for f in result_files_names]
k_values = list(dict.fromkeys(k_values_not_unique_not_sorted))
k_values.sort()

# 1.3 Get a list of all unique fractional components "K" from the list of experiments.
n_values_not_unique_not_sorted = [int(f[f.rfind("p")+1:f.rfind(".")]) for f in result_files_names]
n_values = list(dict.fromkeys(n_values_not_unique_not_sorted))
n_values.sort()

# 1.4 Get the m value. Should be the same across files
m_values_not_unique_not_sorted = [int(f[f.rfind("Q")+1:f.rfind("p")]) for f in result_files_names]
m = m_values_not_unique_not_sorted[0]

# 1.5 Exract the error values from the different files for the first experiment and store the
# results in a string
top_line = "k\\n,"+",".join([str(n) for n in n_values])
csv_file_average_contents=[top_line]
csv_file_worst_contents=[top_line]

print("Generating results for changing k and n")

for k in k_values:
    csv_row_worst_case = f"{k},"
    csv_row_average_case = f"{k},"
    for n in n_values:
        file_name = directory_string + f"capture_k{k}_i16_Q{m}p{n}.txt"
        print("\tLoading File From: " + file_name)
        start = time.time()
        worst,average = error_checker.runErrorChecker(m,n,file_name,True)
        csv_row_average_case+=f"{average:.20f},"
        csv_row_worst_case+=f"{worst:.20f},"
        end = time.time()
        print(f"\tProcessing Time: {end - start}. Accuracy Worst: {worst}, Average: {average}")

    csv_file_worst_contents.append(csv_row_worst_case)
    csv_file_average_contents.append(csv_row_average_case)

# 1.6 Write the extracted results to file
with open(directory_string + 'experiment_results_k_scaling_largest_error.csv', 'w') as f:
    for line in csv_file_worst_contents:
        f.write(f"{line}\n")

with open(directory_string + 'experiment_results_k_scaling_average_error.csv', 'w') as f:
    for line in csv_file_average_contents:
        f.write(f"{line}\n")

# 2. Generate csv files for the second experiment
# 2.1 Load the names of all the capture files for K=16 in the results folder
result_files_names = [f for f in os.listdir(directory_string) if os.path.isfile(os.path.join(directory_string, f)) and "capture_k16" in f and not "_i16_" in f]

# 2.2 Get the varying n and i values
n_values_not_unique_not_sorted = [int(f[f.rfind("p")+1:f.rfind(".")]) for f in result_files_names]
n_values = list(dict.fromkeys(n_values_not_unique_not_sorted))
n_values.sort()

i_values_not_unique_not_sorted = [int(f[f.find("_i")+2:f.find("_",f.find("_i")+2)]) for f in result_files_names]
i_values = list(dict.fromkeys(i_values_not_unique_not_sorted))
i_values.append(16) # We excluded this from our search as i16 is for experiment one, it would confuse our i values. But its safe to add it back now
i_values.sort()

# 2.3 Exract the error values from the different files for the first experiment and store the
# results in a string
top_line = "i\\n,"+",".join([str(n) for n in n_values])
csv_file_average_contents=[top_line]
csv_file_worst_contents=[top_line]

print("Generating results for changing i and n")
for i in i_values:
    csv_row_worst_case = f"{i},"
    csv_row_average_case = f"{i},"
    for n in n_values:
        file_name = directory_string + f"capture_k16_i{i}_Q{m}p{n}.txt"
        start = time.time()
        print("\tLoading File From: " + file_name)
        worst,average = error_checker.runErrorChecker(m,n,file_name,True)
        csv_row_average_case+=f"{average:.20f},"
        csv_row_worst_case+=f"{worst:.20f},"
        end = time.time()
        print(f"\tProcessing Time: {end - start}. Accuracy Worst: {worst}, Average: {average}")

    csv_file_worst_contents.append(csv_row_worst_case)
    csv_file_average_contents.append(csv_row_average_case)

# 2.3 Write the extracted results to file
with open(directory_string + 'experiment_results_CORDIC_iters_largest_error.csv', 'w') as f:
    for line in csv_file_worst_contents:
        f.write(f"{line}\n")

with open(directory_string + 'experiment_results_CORDIC_iters_average_error.csv', 'w') as f:
    for line in csv_file_average_contents:
        f.write(f"{line}\n")
