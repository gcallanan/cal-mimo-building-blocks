% QR Decomposition example
% Decompose A into Q and R (QR=A) where
% - R is an upper triangular matrix
% - Q is unitary (Q^H x Q = I)

rand ("seed", 123)
matrix_size = 2;

%A = rand(matrix_size);

A = zeros(matrix_size);
next = 0.11;
for i = 1:matrix_size
  for j = 1:matrix_size
    A(i,j) = next;
    next = next + 0.11;
    if next > 1
      next = next -1;
    end
  end
end

A = round(A.*100)./100;
[Q,R] = qr(A);

% Check the error here to ensure that it is small
diffPerElement = Q*R-A;
assert(diffPerElement.^2,zeros(matrix_size),1e-13)

% Check that Q is unitary
result = Q^-1 * Q;
assert(result,eye(matrix_size),1e-13)
