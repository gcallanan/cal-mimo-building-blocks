"""
@brief Scripts that interprets data produced by qrd_systolic_cordic_fixedpoint.cal and
       calculated the error in it.

This script takes in a file containing the output produced from executing the
network in qrd_systolic_cordic_fixedpoint.cal. It takes the integer values 
for the A,Q and R matrices and interprets them as real values. It then 
multiplies Q and R together to calculate A again. From this it determines
the error between the original A and the recalculated A.
"""
import numpy as np
import pandas as pd
import argparse
from typing import Tuple


def runErrorChecker(m: int = 3, n:int = 19, input_file_name:str="results/capture_k4_Q3p19.txt", suppress:bool=False) -> Tuple[float,float]:
   """
   Read the A,Q and R matrices from a given text file and calculate the errors from the
   input A matrix and the A matrix produced by multiplying Q and R.

   For each element in the matrix, the error is calculated with the formula:
      (a_given_ij - a_calculated_ij)/a_given_ij

   :param m:int describe about parameter p1
   :param n:int describe about parameter p2
   :param input_file_name:str describe about parameter p3
   :param suppress:bool describe about parameter p3
   :return:(float, float). A tuple containing first, the worst error value among all the arrays
                           and second, the mean error value among the arrays.
   """
   # 1. Read data from file
   with open(input_file_name, 'r') as file:
      content = file.readlines()


   # The actor network can perform QR decomposition many times. We need to verify
   # that each of these produces relatively small errors
   num_arrays = int(content[-1][1:content[-1].find(":")]) + 1
   highest_errors = []
   mean_errors = []

   for i in range(0,num_arrays):

      # 2. Get the A,Q and R matrices from the read data, convert them from integers
      # to floating point numpy arrays.

      # 2.1 Get A matrix
      A_matrix_string = [x[x.rfind(":")+2:-2].split() for x in content if x[0:x.find(":")] == f"A{i}"]
      A_matrix_fp = [[int(x)*(2**-n) for x in line] for line in A_matrix_string]
      A_matrix_fp_np = np.array(A_matrix_fp)

      # 2.2 Get the R matrix
      R_matrix_string = [x[x.rfind(":")+2:-2].split() for x in content if x[0:x.find(":")] == f"R{i}"]
      R_matrix_fp = [[int(x)*(2**-n) for x in line] for line in R_matrix_string]
      R_matrix_fp_np = np.array(R_matrix_fp)

      # 2.3 Get the Q matrix
      Q_matrix_string = [x[x.rfind(":")+2:-2].split() for x in content if x[0:x.find(":")] == f"Q{i}"]
      Q_matrix_fp = [[int(x)*(2**-n) for x in line] for line in Q_matrix_string]
      Q_matrix_fp_np = np.array(Q_matrix_fp)

      # 3. Multiply the Q and R matrix together to reconstruct the A matrix
      A_reconstructed = np.matmul(Q_matrix_fp_np, R_matrix_fp_np)

      near0 = np.mean(np.abs(A_reconstructed))/1000
      A_reconstructed[np.abs(A_reconstructed) < near0] = near0
      A_matrix_fp_np[np.abs(A_matrix_fp_np) < near0] = near0

      # 4. Determine the error between the source A matrix and the reconstructed one
      # Determine the percentage error between the different elements
      errors = np.abs((A_matrix_fp_np - A_reconstructed)/A_matrix_fp_np)
      highest_error= np.max(errors)
      mean_error= np.mean(errors)

      # 5. Print all arrays and errors. Only print the highest error value if the
      # suppress flag is set
      if(not suppress):
         print(f"R{i} matrix:")
         print(pd.DataFrame(R_matrix_fp_np))
         print()

         print(f"Q{i} matrix: ")
         print(pd.DataFrame(Q_matrix_fp_np))
         print()

         print(f"Original A{i} matrix: ")
         print(pd.DataFrame(A_matrix_fp_np))
         print()

         print(f"A{i} matrix constructed by multiplying Q{i} and R{i}: ")
         print(pd.DataFrame(A_reconstructed))
         print()

         print(f"Error between elements of original A{i} and reconstructed A{i} (a1_ij-a2_ij)/a1_ij")
         print(pd.DataFrame(errors))
         print()

         print("Highest error expressed as a percent (1 is maximum):")
         print(highest_error)
         print()

      highest_errors.append(highest_error)
      mean_errors.append(mean_error)

   if(not suppress):
      print("Maximum error across all input arrays/Mean error across all input arrays (maximum is 1):")
      print(np.max(highest_errors),np.mean(mean_errors))
   return np.max(highest_errors),np.mean(mean_errors)

# Program to be run if this script is executed.
if(__name__ == "__main__"):
   # Process command Line arguments
   parser = argparse.ArgumentParser(
                     prog='Error Checker for QRD Systolic Array program',
                     description='A program that takes the results from the actor network and calculates the error between the results and the expected'
            )
   parser.add_argument('-n', '--fixed_point_n', type=int, default=19, help="Number of fractional bits n for Qm.n fixed point numer")
   parser.add_argument('-m', '--fixed_point_m', type=int, default=3, help="Number of integer bits m (including sign bit) for Qm.n fixed point number")
   parser.add_argument('-f', '--input_file', type=str, default="results/capture_k4_Q3p19.txt", help="Name of the file containing the results from the qrd_systolic_cordic_fixedpoint.cal file")
   parser.add_argument('-s', '--suppress', help='Suppress all output from script except for the final maximum error number',
                     action='store_true')  # on/off flag
   args = parser.parse_args()

   # Execute error checker
   highest_error,mean_errors = runErrorChecker(args.fixed_point_m, args.fixed_point_n, args.input_file, args.suppress)
   print(highest_error,mean_errors)