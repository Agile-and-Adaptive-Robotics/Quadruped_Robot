function [ Motor_Position ] = Deg2MotorPos( theta )

%Convert the angles into motor positions.
Motor_Position = round(interp1([0 360], [0 1023], theta));

end

