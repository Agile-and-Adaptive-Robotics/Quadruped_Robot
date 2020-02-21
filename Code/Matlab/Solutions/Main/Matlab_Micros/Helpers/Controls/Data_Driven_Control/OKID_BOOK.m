function H = OKID(y,u,r)
% inputs: y (sampled output), u (sampled input), r (effective system order)
% outputs: H (Markov parameters), M (Observer gain)

% lowercase u,y indicate sampled data

% Step 0, check shapes of y,u
yshape = size(y);
q = yshape(1);  % q is the number of outputs 
l = yshape(2);  % L is the number of output samples
ushape = size(u);
m = ushape(1);  % m is the number of inputs
lu = ushape(2); % Lu i the number of input samples 
assert(l==lu);  % L and Lu need to be the same length

% Step 1, choose p (4 or 5 times effective system order)
p = r*5;

% Step 2, form data matrices y and V as shown in Eq. (7), solve for observer Markov parameters, Ybar
V = zeros(m + (m+q)*p,l);
for i=1:l
    V(1:m,i) = u(1:m,i);
end
for i=2:p+1
    for j=1:l+1-i
        vtemp = [u(:,j);y(:,j)];
        V(m+(i-2)*(m+q)+1:m+(i-1)*(m+q),i+j-1) = vtemp;
%         V((i-1)*(m+q):i*(m+q)-1,i+j-1) = vtemp;
    end
end
Ybar = y*pinv(V,1.e-3);

% Step 3, isolate system Markov parameters H, and observer gain M
D = Ybar(:,1:m);  % feed-through term (or D matrix) is the first term

for i=1:p
    Ybar1(1:q,1:m,i) = Ybar(:,m+1+(m+q)*(i-1):m+(m+q)*(i-1)+m);
    Ybar2(1:q,1:m,i) = Ybar(:,m+1+(m+q)*(i-1)+m:m+(m+q)*i);
end
Y(:,:,1) = Ybar1(:,:,1) + Ybar2(:,:,1)*D;
for k=2:p
    Y(:,:,k) = Ybar1(:,:,k) + Ybar2(:,:,k)*D;
    for i=1:k-1
        Y(:,:,k) = Y(:,:,k) + Ybar2(:,:,i)*Y(:,:,k-i);
    end
end

H = D;
H(:,:,1) = D;
for k=2:p+1
    H(:,:,k) = Y(:,:,k-1);
end