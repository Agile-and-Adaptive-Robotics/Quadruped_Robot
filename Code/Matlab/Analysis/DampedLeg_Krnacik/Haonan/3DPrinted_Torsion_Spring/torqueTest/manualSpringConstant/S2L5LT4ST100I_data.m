trials = {'trial1' 'trial2' 'trial3' 'trial4'};
mgrs = {'T245Nmm' 'T613Nmm' 'T858Nmm' 'T1226Nmm'};


for ii = 1:4
    mgr = mgrs{ii};
    for jj = 1:4
        trial = trials{jj};
        num = (ii-1)*4+jj;
        normCW(:,num) = S2L5LT12ST100I.(mgr).CW.(trial);
        normCCW(:,num) = S2L5LT12ST100I.(mgr).CCW.(trial);
    end
end

figure
hold on
plot(normCW)
% plot(norm2CCW)
% plot(norm3CCW)
% plot(norm4CCW)
hold off
xlim([0 150])
        