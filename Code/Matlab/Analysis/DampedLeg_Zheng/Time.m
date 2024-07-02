clear
clc

load dampers_hip2_trial_rev4;

%%
temp = data(16:165,1);

count = 2;
x = 1;

for ii = 1:length(temp)
    temp(ii,2) = x*10;
        if ii == count
            count = count + 2;
            x = x + 1;
        else
        end
end

for jj = 1:(length(temp)/2)
    dat(jj,:) = temp(jj*2,:);
end

%%
dat = -dat;


        
    