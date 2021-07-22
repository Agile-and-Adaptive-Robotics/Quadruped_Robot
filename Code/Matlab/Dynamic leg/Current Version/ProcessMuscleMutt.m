function data = ProcessMuscleMutt()

N = 4000;
load('golden4.mat','Trial4');

[DogLegDataKnee] = Trial4(:,1)/4;
[DogLegDataHip] = Trial4(:,2)*-1;
[DogLegDataAnkle]= zeros(N,1);

DogLegData = [DogLegDataHip,DogLegDataKnee,DogLegDataAnkle];

PPR = 2048;
RPT = (2*pi)/(PPR);

DogLegData = DogLegData*RPT;

data = DogLegData;

end