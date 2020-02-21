function [ G_sym, dt ] = tf2sym( G_tf )

%Extract the numerator and denominator from the transfer function.
[G_num, G_den, dt] = tfdata(G_tf);

%Convert the numerator and denominator into a symbolic expression.
G_sym = vpa(poly2sym(G_num{1}))/vpa(poly2sym(G_den{1}));

%Simplify the symbolic expression.
G_sym = simplify(G_sym);

end