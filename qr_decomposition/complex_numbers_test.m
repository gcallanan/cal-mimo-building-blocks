clear all

% Cordic test for complex matrices. Architecture looks similar to
% Gentleman and Kung systolic array while CORDIC equations are takn from
% this paper: 
% Maltsev, Alexander, et al. "Triangular systolic array with reduced 
% latency for QR-decomposition of complex matrices." 2006 IEEE 
% international symposium on circuits and systems (ISCAS). IEEE, 2006.

K=1.6467602;
k = 1/K;

function [result, phis] = cordic_vector(in1,in2,k)
    phis = [];
    in =[in1; in2];
    for j = 0:22
        if(in(1) * in(2) >= 0)
            phi = -1;
        else
            phi = 1;
        end
        rotation = [1 phi * -2^(-j); phi * 2^(-j) 1];
        in =  rotation * in;
        phis(end+1) = phi;
    end

    result=in(1)*k;
end

function [result1,result2] = cordic_rotate(in1,in2,k,phis)
    in =[in1; in2];
    for j = 0:22
        phi = phis(j+1);
        rotation = [1 phi * -2^(-j); phi * 2^(-j) 1];
        in =  rotation * in;
    end

    result1=in(1)*k;
    result2=in(2)*k;
end


rng(1,"twister");
A = rand(2) + i * rand(2)
[Q,R] = qr(A)

% vector_rotate test

r_0 = 0;
[r_1,phis_1] = cordic_vector(0.11,r_0,k);
[r_2,phis_2] = cordic_vector(0.33,r_1,k);
%r_2

r_0 = 0;
r_1 = cordic_rotate(0.22,r_0,k,phis_1);
r_2 = cordic_rotate(0.44,r_1,k,phis_2);
%r_2

% vector mode - to calculate r11
[r_a_1,phis_a_1] = cordic_vector(real(A(1,1)),imag(A(1,1)),k);
[r_b_1,phis_b_1] = cordic_vector(0,0,k);
[r_end_1,phis_end_1] = cordic_vector(r_a_1,r_b_1,k);

[r_a_2,phis_a_2] = cordic_vector(real(A(2,1)),imag(A(2,1)),k);
[r_b_2,phis_b_2] = cordic_vector(real(r_end_1),imag(r_end_1),k);
[r_end_2,phis_end_2] = cordic_vector(r_a_2,r_b_2,k);

r11 = r_end_2;

% rotate mode - to calculate r12
r_0 = 0;
[r_c_real_1,r_c_imag_1] = cordic_rotate(real(A(1,2)),imag(A(1,2)),k,phis_a_1);
[r_d_real_1,r_d_imag_1] = cordic_rotate(real(r_0),imag(r_0),k,phis_b_1);

[r_c_end_real_1,r_d_end_real_1] = cordic_rotate(r_c_real_1,r_d_real_1,k,phis_end_1);
[r_c_end_imag_1,r_d_end_imag_1] = cordic_rotate(r_c_imag_1,r_d_imag_1,k,phis_end_1);

c_out_1 = r_c_end_real_1 + i * r_c_end_imag_1;
d_out_1 = r_d_end_real_1 + i * r_d_end_imag_1;

r_1=c_out_1;
[r_c_real_2,r_c_imag_2] = cordic_rotate(real(A(2,2)),imag(A(2,2)),k,phis_a_2);
[r_d_real_2,r_d_imag_2] = cordic_rotate(real(r_1),imag(r_1),k,phis_b_2);

[r_c_end_real_2,r_d_end_real_2] = cordic_rotate(r_c_real_2,r_d_real_2,k,phis_end_2);
[r_c_end_imag_2,r_d_end_imag_2] = cordic_rotate(r_c_imag_2,r_d_imag_2,k,phis_end_2);

c_out_2 = r_c_end_real_2 + i * r_c_end_imag_2;
d_out_2 = r_d_end_real_2 + i * r_d_end_imag_2;

r12=c_out_2

% vector mode - to calculate r21
[r_a_1,phis_a_1] = cordic_vector(real(d_out_1),imag(d_out_1),k);
[r_b_1,phis_b_1] = cordic_vector(0,0,k);
[r_end_1,phis_end_1] = cordic_vector(r_a_1,r_b_1,k);

[r_a_2,phis_a_2] = cordic_vector(real(d_out_2),imag(d_out_2),k);
[r_b_2,phis_b_2] = cordic_vector(real(r_end_1),imag(r_end_1),k);
[r_end_2,phis_end_2] = cordic_vector(r_a_2,r_b_2,k);

r21=r_end_2;

R_new = [r11,r12;0,r21]

Q_new =A/R_new

diff = Q_new * R_new - A;

assert(all(diff < 1e-13,'all'))
assert(all(eye(2)-ctranspose(Q_new)*Q_new < 1e-5,'all'))
