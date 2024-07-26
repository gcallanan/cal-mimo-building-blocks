import error_checker
import os

directory_string = "results/"
result_files_names = [f for f in os.listdir(directory_string) if os.path.isfile(os.path.join(directory_string, f)) and "capture_k" in f]

k_values_not_unique_not_sorted = [int(f[f.find("_")+2:f.rfind("_")]) for f in result_files_names]
k_values = list(dict.fromkeys(k_values_not_unique_not_sorted))
k_values.sort()

n_values_not_unique_not_sorted = [int(f[f.rfind("p")+1:f.rfind(".")]) for f in result_files_names]
n_values = list(dict.fromkeys(n_values_not_unique_not_sorted))
n_values.sort()

m_values_not_unique_not_sorted = [int(f[f.rfind("Q")+1:f.rfind("p")]) for f in result_files_names]
m = m_values_not_unique_not_sorted[0]

top_line = "k\\n,"+",".join([str(n) for n in n_values])
csv_file_average_contents=[top_line]
csv_file_worst_contents=[top_line]

for k in k_values:
    csv_row_worst_case = f"{k},"
    csv_row_average_case = f"{k},"
    for n in n_values:
        file_name = directory_string + f"capture_k{k}_Q{m}p{n}.txt"
        worst,average = error_checker.runErrorChecker(m,n,file_name,True)
        csv_row_average_case+=f"{average:.20f},"
        csv_row_worst_case+=f"{worst:.20f},"

    csv_file_worst_contents.append(csv_row_worst_case)
    csv_file_average_contents.append(csv_row_average_case)

with open(directory_string + 'experiment_results_largest_error.csv', 'w') as f:
    for line in csv_file_worst_contents:
        f.write(f"{line}\n")

with open(directory_string + 'experiment_results_average_error.csv', 'w') as f:
    for line in csv_file_average_contents:
        f.write(f"{line}\n")
