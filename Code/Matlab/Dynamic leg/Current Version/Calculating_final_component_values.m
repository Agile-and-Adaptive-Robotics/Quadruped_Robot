clc;
% Calculating the final component values
%masses of the rat limbs and Muscle Mutt limbs
MassRat = [0.13003617937975182,0.08884824925946844,0.01667130504868613];
MassMM = [3.1849266765,1.9122904724,0.048894852];
% rat components in gf-cm [b1,b2,b3,k1,k2,k3]
OptimizedJointParametersRat = [-39192.2302847158,-2667.89163854845,-273094.478556467,-1424986.00559547,-165110.485800216,-637769.06742118, 1041.56063154080, 0.175013020846696, 117.349732238565, 0.0850447555706903, 6.68213235126660, 7.02843263410336];
% rat components in N-m
NMpRRat = [-3.843444851216082, -0.2616307953717116, -26.78141968135777, -139.74339011772815, -16.191807455726885, -62.54378025025915];
%muscle Mutt Parameters in lbf-in
OptimizedJointParametersMM = [-328.224278968718, 13183.8528818203, -15000, -4626.33116843912, -4.35250563034393, 1.52448822170137, -6885.42581532523, -136539.850675276, 14000,  -1.77402200254436, 0.289109621023439];
%MM Parameters in N-m
NMpRMM = [-37.08436544429330439, 1489.575420104191153, -1694.7725, -522.7052558566882681, -0.4917671230817203254, 0.1722440475967427498];

RatHipWn = sqrt(-NMpRRat(4)/MassRat(1))
MMHipWn = sqrt(-NMpRMM(4)/MassMM(1))

RatHipZeta = -NMpRRat(1)/(RatHipWn*2*MassRat(1))
MMHipZeta = -NMpRMM(1)/(MMHipWn*2*MassMM(1))


RatKneeWn = sqrt(-NMpRRat(5)/MassRat(2))
MMKneeWn = sqrt(-NMpRMM(5)/MassMM(2))

RatKneeZeta = -NMpRRat(2)/(RatKneeWn*2*MassRat(2))
MMKneeZeta =  NMpRMM(2)/(MMKneeWn*2*MassMM(2))


RatAnkleWn = sqrt(-NMpRRat(6)/MassRat(3))
MMAnkleWn = sqrt(NMpRMM(6)/MassMM(3))

RatAnkleZeta = -NMpRRat(3)/(RatAnkleWn*2*MassRat(3))
MMAnkleZeta = -NMpRMM(3)/(MMAnkleWn*2*MassMM(3))

options = optimset('MaxFunEval',10000,'MaxIter', 10000);
x0 = [1,1];
x = fsolve(@fun2dhip,x0,options)
%[Spring coefficiant,damping Coefficiant]
HipComponentValues =[2899.98547309764,49.5642102109336];
[25667.03415147929,438.6802237378887]

y0 = [1,1];



