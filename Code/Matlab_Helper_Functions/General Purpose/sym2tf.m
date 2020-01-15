function [ G_tf ] = sym2tf( G_sym )

%Retrieve the numerator and denominator from the symbolic expression in the w domain.
[G_sym_num, G_sym_den] = numden(G_sym);

%Retrieve the coeffiecients of the numerator and denominator expressions.
G_sym_num_coeffs = double(coeffs(G_sym_num, 'all'));
G_sym_den_coeffs = double(coeffs(G_sym_den, 'all'));

%Scale the polynomial coefficients.
G_sym_num_coeffs = G_sym_num_coeffs/G_sym_den_coeffs(1); G_sym_den_coeffs = G_sym_den_coeffs/G_sym_den_coeffs(1);

%Convert the symbolic w domain expression to a transfer function.
G_tf = tf(G_sym_num_coeffs, G_sym_den_coeffs);

end