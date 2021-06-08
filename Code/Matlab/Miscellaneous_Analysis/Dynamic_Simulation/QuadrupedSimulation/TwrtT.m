function T12 = TwrtT(T1, T2)

% This function computes the transformation T21 that describes the transformation matrix T2 with respect to the transformation matrix T1.

% Convert the transformation matrices to their rotational and translational components.
[R1, P1] = TransToRp(T1); [R2, P2] = TransToRp(T2);

% Compute the orientation of R2 with respect to R1.
R12 = RwrtR(R1, R2);

% Compute the position of P2 with respect to P1.
P12 = PwrtP(P1, P2);

% Construct teh transformation matrix associated with this new orientation and position.
T12 = RpToTrans(R12, P12);

end

