# CAL MIMO Building Blocks

This repository contains projects written in the CAL Actor Language (CAL) that solve different
parts of the MIMO toolchain for 5G base stations.

Massive MIMO is an enabling technology for 5G communications. It allows signals from multiple mobile
devices to be received at multiple antennas connected to the same base station. The base station is
then able to process these signals in such a way as to reduce the interference from the other
mobile devices.

CAL describes applications as networks of connected actors that consume tokens on input ports and
produce tokens on output ports. CAL is often used to describe dataflow. The advantage of this
implementations is that each actor can be seen as a seperate thread of execution. Therefore large
applications consisting of hundreds of actors can execute in a highly parallel manner.

The intention is for these actor networks to get transformed to some HDL for implementation on
FPGAs or ASICs.

## Matrix Multiplication






[link](matrix_multiplication)

TODO Describe what it is and why it is important

### 1. Naive implementation

[link](matrix_multiplication/1_simple)

### 2. Systolic Array Implementations

[link](matrix_multiplication/2_systolic_array)

Describe

## QR Decomposition

QR Decomposition is the process of decomposing a matrix A into two matrices: Q and R such that
QxR = A. R is an upper right triangualr matrix. Q is a unitary matrix (`QxQ^T = I`).

QR Decomposition is a way to find the pseudoinverse of a matrix. The pseudoinverse is the
inverse of a non-square matrix and is defined by: `A+ = (A^H x A)^(-1) x A^H`. If we treat
`G = A^H x A` then `G^-1 = (QR)^-1 = Q^-1 R^-1`. A unitary matrix inverted is just its 
transpose, so `G^-1 = Q^T R^-1`. The inverse of a triangular matrix can be found quite easily
using backward substitution. The pseudoinverse is required for finding the channel matrix in
MIMO base stations.

There are a number of different QR implementations found [here](qr_decomposition) in this repository.
These implementations all build on each other. Each CAL file provides useful sources for
understanding the theory behind QR decomposition and the implementation.

These 3 projects build on top of each other with the third project (Fixed Point Systolic Array with
CORDIC) being the final and the most maintained version. It has the most supporting documentation 
and error checking scripts, so it is okay to just go straight to that version if you are not 
interested in seeing the progression.

### 1. Systolic Array Implementation

The [Systolic Array Implementation](qr_decomposition/1_systolic_array/) 

Describe

### 2. Systolic Array Implementation with CORDIC

[link](qr_decomposition/2_systolic_cordic/)

Describe

### 3. Fixed Point Systolic Array Implementation with CORDIC

[link](qr_decomposition/3_systolic_cordic_fixedpoint/)

Describe

Mention how this is the most up to date version