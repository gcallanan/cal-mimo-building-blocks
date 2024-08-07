import os
import time


def generateFilePrefix(fpga_part, clock_period, loop_unroll_factor, m, n, k, i):
    clock=str(clock_period).replace(".","p")
    unrollName = "None" if loop_unroll_factor == 1 else "All" if loop_unroll_factor == 1000 else loop_unroll_factor
    filePrefix = f"build_k{k}_Q{m}p{n}_i{i}_{fpga_part}_clk{clock}_unroll{unrollName}"
    return filePrefix

def processUtilisationReport(fpga_part, clock_period, loop_unroll_factor, m, n, k, i, directory_string):
    filePrefix=generateFilePrefix(fpga_part, clock_period, loop_unroll_factor, m, n, k, i)
    filePath_util = f"{directory_string}/{filePrefix}_utilisation.rpt"
    filePath_timing = f"{directory_string}/{filePrefix}_timing.rpt"
  
    with open(filePath_util, 'r') as file:
        content = file.readlines()

    timing_violations=False
    with open(filePath_timing, 'r') as file:
        contents = file.read()
        if(contents.find("VIOLATED")):
            timing_violations=True
        
        
    start_index = content.index('1. Utilization by Hierarchy\n') + 6
    headings=[entry.strip() for entry in content[start_index][1:-2].split("|")]
    
    resource_table=content[start_index:-1]
    resource_table = [line for line in resource_table if line.find("|    ") != 0 and line[0] != "+"]


    top=""
    boundaryCell=""
    innerCell_q=""
    innerCell_r=""
    source=""
    filter_q=""
    filter_r=""

    with open(f"{directory_string}/{filePrefix}_utilisation.csv", 'w') as output_file:
        output_file.write(",".join(headings) + "\n")

        for line in resource_table:
            split_line_with_whitespace = line[1:-2].split("|")
            split_line = [entry.strip() for  entry in split_line_with_whitespace]
            output_line= ",".join(split_line)
            output_file.write(output_line + "\n")

            name=split_line[0]

            if(name=="Top_vivado2023"):
                top=split_line
            elif(name=="i_boundaryCells_0"):
                boundaryCell=split_line
            elif(name=="i_innerCells_q_0"):
                innerCell_q=split_line
            elif(name=="i_innerCells_r_0"):
                innerCell_r=split_line
            elif(name=="i_source"):
                source=split_line
            elif(name=="i_filters_q_0"):
                filter_q=split_line
            elif(name=="i_filters_r_boundary_0"):
                filter_r=split_line


    return timing_violations, headings, top, boundaryCell, innerCell_q, innerCell_r, source, filter_q, filter_r

def collectParamExperimentResults():
    # 1. Generate csv files for the first experiment
    # 1.1 Load the names of all the capture files in the results folder where the number of cordic iterations is 16
    directory_string = "fpga_param_experiments/reports"
    result_files_names = [f for f in os.listdir(directory_string) if os.path.isfile(os.path.join(directory_string, f)) and "_utilisation.rpt" in f]

    fpga_parts_not_sorted = [f[f.find("Zync"):f.find("_",f.find("Zync"))] for f in result_files_names]
    fpga_parts = list(dict.fromkeys(fpga_parts_not_sorted))
    fpga_parts.sort()

    clock_periods_not_sorted = [f[f.find("clk")+3:f.find("_",f.find("clk"))] for f in result_files_names]
    clock_periods = list(dict.fromkeys(clock_periods_not_sorted))
    clock_periods = [float(f.replace("p",".")) for f in clock_periods]
    clock_periods.sort()

    loop_unroll_factors_not_sorted = [f[f.find("unroll")+6:f.find("_",f.find("unroll"))] for f in result_files_names]
    loop_unroll_factors = list(dict.fromkeys(loop_unroll_factors_not_sorted))
    loop_unroll_factors = ["1" if x == "None" else x for x in loop_unroll_factors]
    loop_unroll_factors = ["1000" if x == "All" else x for x in loop_unroll_factors]
    loop_unroll_factors = [int(x) for x in loop_unroll_factors]
    loop_unroll_factors.sort()

    f = result_files_names[0]
    k = int(f[f.find("k")+1:f.find("_",f.find("k"))])
    m = int(f[f.find("_Q")+2:f.find("p",f.find("_Q"))])
    i = int(f[f.find("_i")+2:f.find("_",f.find("_i")+2)])
    n = int(f[f.find("p",f.find("_Q"))+1:f.find("_", f.find("p",f.find("_Q")))])

    top_results=[]
    timing_violations_results=[]
    boundaryCells_results=[]
    innerCell_q_results=[]
    innerCell_r_results=[]
    source_results=[]
    filter_q_results=[]
    filter_r_results=[]

    fpga_parts = [fpga_parts[0]]

    headings=""
    for fpga_part in fpga_parts:
        for loop_unroll_factor in loop_unroll_factors:
            for clock_period in clock_periods:
                timing_violations, headings, top, boundary, innerCell_q, innerCell_r, source, filter_q, filter_r, = processUtilisationReport(fpga_part, clock_period, loop_unroll_factor,m,n,k,i,directory_string)
                title=f"{fpga_part} Clock: {clock_period} ns Loop Unroll: {loop_unroll_factor}"
                
                line = title + "," + ",".join(top)
                top_results.append(line)

                line = title + "," + str(timing_violations)
                timing_violations_results.append(line)

                line = title + "," + ",".join(boundary)
                boundaryCells_results.append(line)

                line = title + "," + ",".join(innerCell_q)
                innerCell_q_results.append(line)

                line = title + "," + ",".join(innerCell_r)
                innerCell_r_results.append(line)

                line = title + "," + ",".join(source)
                source_results.append(line)

                line = title + "," + ",".join(filter_q)
                filter_q_results.append(line)

                line = title + "," + ",".join(filter_r)
                filter_r_results.append(line)

    with open(f"{directory_string}/combined_results.csv", 'w') as output_file:
            output_file.write("Experiment Name,Timing Violations\n")
            output_file.write("\n".join(timing_violations_results) + "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(top_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(boundaryCells_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(innerCell_q_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(innerCell_r_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(source_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(filter_q_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(filter_r_results)+ "\n")

def collectScalingExperimentResults():
    # 1. Generate csv files for the first experiment
    # 1.1 Load the names of all the capture files in the results folder where the number of cordic iterations is 16
    directory_string = "fpga_scaling_experiments/reports"
    result_files_names = [f for f in os.listdir(directory_string) if os.path.isfile(os.path.join(directory_string, f)) and "_utilisation.rpt" in f]

    k_values_not_unique_not_sorted = [int(f[f.find("_")+2:f.find("_",f.find("_")+2)]) for f in result_files_names]
    k_values = list(dict.fromkeys(k_values_not_unique_not_sorted))
    k_values.sort()

    f = result_files_names[0]
    m = int(f[f.find("_Q")+2:f.find("p",f.find("_Q"))])
    i = int(f[f.find("_i")+2:f.find("_",f.find("_i")+2)])
    n = int(f[f.find("p",f.find("_Q"))+1:f.find("_", f.find("p",f.find("_Q")))])
    loop_unroll_factor = f[f.find("unroll")+6:f.find("_",f.find("unroll"))]
    loop_unroll_factor = "1" if loop_unroll_factor == "None" else loop_unroll_factor
    loop_unroll_factor = "1000" if loop_unroll_factor == "All" else loop_unroll_factor
    loop_unroll_factor = int(loop_unroll_factor)
    clock_period = float(f[f.find("clk")+3:f.find("_",f.find("clk"))].replace("p","."))
    fpga_part = f[f.find("Zync"):f.find("_",f.find("Zync"))]
    
    top_results=[]
    timing_violations_results=[]
    boundaryCells_results=[]
    innerCell_q_results=[]
    innerCell_r_results=[]
    source_results=[]
    filter_q_results=[]
    filter_r_results=[]

    headings=""
    for k in k_values:
        timing_violations, headings, top, boundary, innerCell_q, innerCell_r, source, filter_q, filter_r, = processUtilisationReport(fpga_part, clock_period, loop_unroll_factor,m,n,k,i,directory_string)
        title=f"k={k}"

        line = title + "," + ",".join(top)
        top_results.append(line)

        line = title + "," + str(timing_violations)
        timing_violations_results.append(line)

        line = title + "," + ",".join(boundary)
        boundaryCells_results.append(line)

        line = title + "," + ",".join(innerCell_q)
        innerCell_q_results.append(line)

        line = title + "," + ",".join(innerCell_r)
        innerCell_r_results.append(line)

        line = title + "," + ",".join(source)
        source_results.append(line)

        line = title + "," + ",".join(filter_q)
        filter_q_results.append(line)

        line = title + "," + ",".join(filter_r)
        filter_r_results.append(line)

    with open(f"{directory_string}/combined_results.csv", 'w') as output_file:
            output_file.write("Experiment Name,Timing Violations\n")
            output_file.write("\n".join(timing_violations_results) + "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(top_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(boundaryCells_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(innerCell_q_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(innerCell_r_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(source_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(filter_q_results)+ "\n")
            output_file.write("\n")
            output_file.write("Experiment Name," + ",".join(headings) + "\n")
            output_file.write("\n".join(filter_r_results)+ "\n")

collectScalingExperimentResults()