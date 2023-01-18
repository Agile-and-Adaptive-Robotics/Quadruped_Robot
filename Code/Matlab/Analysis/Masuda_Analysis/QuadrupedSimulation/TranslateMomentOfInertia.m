function J = TranslateMomentOfInertia(I, m, d)

% This function computes the moment of inertia J about some point d given the moment of inertia I about the origin and the mass of the rigid body m.

% Compute the translated moment of inertia.
J = I + m*(((d')*d)*eye(length(d)) - d*(d'));


end

