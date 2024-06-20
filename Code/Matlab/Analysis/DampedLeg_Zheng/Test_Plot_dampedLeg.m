clear
clc

%%
load Test_Data.mat
data_new = zeros(length(data(:,1))/2,length(data(1,:)));

% resting angles
hip = 105;
knee = 108;
ankle = 139;

for ii = 1:length(data(:,1))/2
    for jj = 1:length(data(1,:))
        data_new(ii,jj) = data(2*ii-1,jj);
    end
end

hip_offset = hip - data_new(end,1);
knee_offset = knee - data_new(end,2);
ankle_offset = ankle - data_new(end,3);

data_new(:,1) = data_new(:,1) + hip_offset;
data_new(:,2) = data_new(:,2) + knee_offset;
data_new(:,3) = data_new(:,3) + ankle_offset;

        
    
