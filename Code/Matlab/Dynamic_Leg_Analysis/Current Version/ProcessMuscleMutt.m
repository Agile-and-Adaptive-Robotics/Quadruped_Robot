function data = ProcessMuscleMutt()

N = 3751;
load('Golden7.mat','Trial4');

[DogLegDataKnee] = Trial4(1:3751,3)/4;
[DogLegDataHip] = Trial4(1:3751,4)*-1;
[DogLegDataAnkle]= zeros(N,1);

DogLegData = [DogLegDataHip,DogLegDataKnee,DogLegDataAnkle];

PPR = 2048;
RPT = (2*pi)/(PPR);

DogLegData = DogLegData*RPT;

data = DogLegData;

end