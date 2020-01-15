function impulse_data = OKID(ys, us, r)

% Steve Brunton, November 2010
% OKID code, based on 1991 NASA TM-104069 by Juang, Phan, Horta and Longman
% inputs: y (sampled output), u (sampled input), r (effective system order)
% outputs: H (Markov parameters), M (Observer gain)

% lowercase u,y indicate sampled data
% double uppercase UU, YY indicate bold-faced quantities in paper
% single uppercase U, Y indicate script quantities in paper

%Retrieve the number of input and output signals.
num_inputs = size(us, 1); num_outputs = size(ys, 1);

%Retrieve the number of data points in our input / outputs data signals.
num_data_points = size(ys, 2);

% Step 1, choose p (4 or 5 times effective system order)
% p = r*5;

% Step 2, form data matrices y and V as shown in Eq. (7), solve for observer Markov parameters, Ybar
V = zeros(num_inputs + (num_inputs + num_outputs)*r, num_data_points);

for i = 1:num_data_points
    V(1:num_inputs,i) = us(1:num_inputs, i);
end

for i = 2:r + 1
    for j = 1:num_data_points + 1 - i
        vtemp = [us(:,j); ys(:,j)];
        V(num_inputs + (i-2)*(num_inputs + num_outputs) + 1:num_inputs + (i-1)*(num_inputs + num_outputs), i + j - 1) = vtemp;
%         V((i-1)*(m+q):i*(m+q)-1,i+j-1) = vtemp;
    end
end

Ybar = ys*pinv(V, 1.e-3);

% Step 3, isolate system Markov parameters H, and observer gain M
%Retrieve the feedthrough matrix.
D = Ybar(:,1:num_inputs);

for i=1:r
    Ybar1(1:num_outputs, 1:num_inputs, i) = Ybar(:, num_inputs + 1 + (num_inputs + num_outputs)*(i - 1):num_inputs + (num_inputs + num_outputs)*(i - 1) + num_inputs);
    Ybar2(1:num_outputs, 1:num_inputs, i) = Ybar(:, num_inputs + 1 + (num_inputs+num_outputs)*(i - 1) + num_inputs:num_inputs + (num_inputs + num_outputs)*i);
end

Y(:,:,1) = Ybar1(:,:,1) + Ybar2(:,:,1)*D;

for k=2:r
    Y(:,:,k) = Ybar1(:,:,k) + Ybar2(:,:,k)*D;
    for i=1:k - 1
        Y(:,:,k) = Y(:,:,k) + Ybar2(:,:,i)*Y(:,:,k-i);
    end
end

%% Construct the Best Impulse Response Approximation.

%Store the feed-through matrix into the first entry.
impulse_data(:, :, 1) = D;

%Store the rest of the impulse response approximation into the output variable.
for k = 2: r + 1
    impulse_data(:,:,k) = Y(:,:,k - 1);
end


end

% function [H, M] = OKID(y, u, r)
% 
% % Steve Brunton, November 2010
% % OKID code, based on 1991 NASA TM-104069 by Juang, Phan, Horta and Longman
% % inputs: y (sampled output), u (sampled input), r (effective system order)
% % outputs: H (Markov parameters), M (Observer gain)
% 
% % lowercase u,y indicate sampled data
% % double uppercase UU, YY indicate bold-faced quantities in paper
% % single uppercase U, Y indicate script quantities in paper
% 
% % Step 0, check shapes of y,u
% yshape = size(y);
% q = yshape(1);  % q is the number of outputs 
% l = yshape(2);  % L is the number of output samples
% ushape = size(u);
% m = ushape(1);  % m is the number of inputs
% lu = ushape(2); % Lu i the number of input samples 
% assert(l==lu);  % L and Lu need to be the same length
% 
% 
% % Step 1, choose p (4 or 5 times effective system order)
% p = r*5;
% 
% 
% % Step 2, form data matrices y and V as shown in Eq. (7), solve for observer Markov parameters, Ybar
% V = zeros(m + (m+q)*p,l);
% for i=1:l
%     V(1:m,i) = u(1:m,i);
% end
% for i=2:p+1
%     for j=1:l+1-i
%         vtemp = [u(:,j);y(:,j)];
%         V(m+(i-2)*(m+q)+1:m+(i-1)*(m+q),i+j-1) = vtemp;
% %         V((i-1)*(m+q):i*(m+q)-1,i+j-1) = vtemp;
%     end
% end
% Ybar = y*pinv(V,1.e-3);
% 
% % Step 3, isolate system Markov parameters H, and observer gain M
% D = Ybar(:,1:m);  % feed-through term (or D matrix) is the first term
% 
% for i=1:p
%     Ybar1(1:q,1:m,i) = Ybar(:,m+1+(m+q)*(i-1):m+(m+q)*(i-1)+m);
%     Ybar2(1:q,1:m,i) = Ybar(:,m+1+(m+q)*(i-1)+m:m+(m+q)*i);
% end
% Y(:,:,1) = Ybar1(:,:,1) + Ybar2(:,:,1)*D;
% for k=2:p
%     Y(:,:,k) = Ybar1(:,:,k) + Ybar2(:,:,k)*D;
%     for i=1:k-1
%         Y(:,:,k) = Y(:,:,k) + Ybar2(:,:,i)*Y(:,:,k-i);
%     end
% end
% 
% % H = D;
% H(:,:,1) = D;
% for k=2:p+1
%     H(:,:,k) = Y(:,:,k-1);
% end
% 
% % H = Ybar;
% M = 0; % not computed yet!
% 
% end


