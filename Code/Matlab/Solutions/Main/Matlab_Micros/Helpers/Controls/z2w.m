function [ Gw ] = z2w( Gz )

%Convert the transfer function to a symbolic expression.
[Gz_sym, dt] = tf2sym(Gz);

%Define symbolic variables.
syms x w

%Transform the symbolic expression into the w domain.
Gw_sym = subs( Gz_sym, x, (1 + (dt/2)*w)/(1 - (dt/2)*w) );

%Simplify the symbolic expression.
Gw_sym = simplify(Gw_sym);

%Convert the symbolic expression to a transfer function.
Gw = sym2tf(Gw_sym);

end