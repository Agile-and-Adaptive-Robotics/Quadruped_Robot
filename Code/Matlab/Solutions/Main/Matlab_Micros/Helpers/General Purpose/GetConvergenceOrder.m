function [ nOrder ] = GetConvergenceOrder( xs )

if length(xs) < 4
    nOrder = 0;
    warning('Sequence must have at least 4 elements.')    
else
    nOrder = log((xs(4:end) - xs(3:end-1))./(xs(3:end-1) - xs(2:end-2)))./log((xs(3:end-1) - xs(2:end-2))./(xs(2:end-2) - xs(1:end-3)));
end

end

