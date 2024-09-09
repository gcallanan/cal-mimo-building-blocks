# CAL MIMO Building Blocks

This repository contains projects written in the CAL Actor Language (CAL) that solve different parts of the MIMO toolchain for 5G base stations.

Massive MIMO is an enabling technology for 5G communications. It allows signals from multiple mobile devices to be received at multiple antennas connected to the same base station. The base station is then able to process these signals in such a way as to reduce the interference between these mobile devices.

CAL describes applications as networks of connected actors that consume tokens on input ports and produce tokens on output ports. CAL is often used to describe dataflow. The advantage of this implementations is that each actor can be seen as a seperate thread of execution. Therefore large applications consisting of hundreds of actors can execute in a highly parallel manner.

The intention is for these actor networks to get transformed to some HDL for implementation on FPGAs or ASICs.

## Matrix Multiplication

[link](matrix_multiplication)

TODO Describe what it is and why it is important

### 1. Naive implementation

[link](matrix_multiplication/1_simple)

### 2. Systolic Array Implementations

[link](matrix_multiplication/2_systolic_array)

Describe

## QR Decomposition

QR Decomposition is the process of decomposing a matrix A into two matrices: Q and R such that QxR = A. R is an upper right triangualr matrix. Q is a unitary matrix (`QxQ^T = I`).

QR Decomposition is a way to find the pseudoinverse of a matrix. The pseudoinverse is the inverse of a non-square matrix and is defined by: `A+ = (A^H x A)^(-1) x A^H`. If we treat `G = A^H x A` then `G^-1 = (QR)^-1 = Q^-1 R^-1`. A unitary matrix inverted is just its transpose, so `G^-1 = Q^T R^-1`. The inverse of a triangular matrix can be found quite easily using backward substitution. The pseudoinverse is required for finding the channel matrix in MIMO base stations.

There are a number of different QR implementations found [here](qr_decomposition) in this repository. These implementations all build on each other. Each CAL file provides useful sources for understanding the theory behind QR decomposition and the implementation.

These 4 projects build on top of each other with the fourth project (Fixed Point Systolic Array Implementation with complete CORDIC and DDF) being the final and the most maintained version. It has the most supporting documentation and error checking scripts, so it is okay to just go straight to that version if you are not 
interested in seeing the progression.

The 4th implementations in this list is the most up to date and should be the one referred to for 

### 1. Systolic Array Implementation

The first implementation is titled the [Systolic Array Implementation](qr_decomposition/1_systolic_array/). This is the canonical systolic array implementation for QR decomposition. It makes use of floating point representation as well as sqrt and division operations.

This is a single action per actor implementation

### 2. Systolic Array Implementation with CORDIC

The [Systolic Array Implementation with CORDIC](qr_decomposition/2_systolic_cordic/) implementation gets rid of the expensive sqrt operations by partially implementing the CORDIC rotations method (partial as divisions are
not excluded yet). Floating point numbers are still used.

This is a single action per actor implementation

### 3. Fixed Point Systolic Array Implementation with CORDIC

The [Fixed Point Systolic Array Implementation with CORDIC](qr_decomposition/3_systolic_cordic_fixedpoint/) implementation gets rid of the floating point numbers and replaces them with fixed point numbers. Everything else is very similar to the 

This is a single action per actor implementation

### 4. Fixed Point Systolic Array Implementation with complete CORDIC and DDF

The [Fixed Point Systolic Array Implementation with complete CORDIC and DDF](qr_decomposition/4_systolic_array_cordic_fixed_point_no_division) fully implements the CORDIC algorithm eliminating all division opertaions.

Actors can now have multiple actions which reduces the resource requirements of the implementation quite a bit.

### 5. Fixed-Point QR Decomposition using Givens Rotations and the CORDIC algorithm on a Systolic Array using Dataflow for non-square sized matrices.

The [Fixed-Point QR Decomposition using Givens Rotations and the CORDIC algorithm on a Systolic Array using Dataflow for non-square sized matrices](qr_decomposition/5_systolic_array_cordic_fixed_point_no_division_rectangualr_matrices/) is the implementation in 4 above extended to support non-square matrices (MxN matrices).

NOTE: This is the most up to date version of this project and should be looked at first as it has many supporting scripts and documents.



