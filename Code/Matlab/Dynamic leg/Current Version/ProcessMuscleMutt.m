function data = ProcessMuscleMutt()

N = 4000;
load('Golden6.mat');

[DogLegDataKnee] = Trial4(:,1);
[DogLegDataHip] = Trial4(:,2)*-1;
[DogLegDataAnkle]= zeros(N,1);

DogLegData = [DogLegDataHip,DogLegDataKnee,DogLegDataAnkle];

PPR = 2048;
RPT = (2*pi)/(PPR);

DogLegData = DogLegData*RPT;

data = DogLegData;

end