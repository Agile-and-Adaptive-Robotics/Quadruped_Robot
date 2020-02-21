function [ rts, xs, errs ] = SecantMethod( f, xs, tol )

%Set the default input arguments.
if nargin < 3, tol = 1e-6; end
if tol < 5*eps, tol = 5*eps; end
if size(xs, 2) < 2, xs(:, 2) = xs(:, 1) + 1; end

%Set the error to begin the while loop.
errs = tol + 1;

%Set a counter for the while loop.
k = 0;

%Perform the secant method.
while sum(errs > tol) > 0             %While the error is greater than our specified tolerance...
   
    %Advance the counter.
    k = k + 1;
    
    %Compute the next iterate via the Secant Method.
    xs(:, k + 2) = xs(:, k + 1) - f(xs(:, k + 1)).*((xs(:, k + 1) - xs(:, k))./(f(xs(:, k + 1)) - f(xs(:, k))));

    %Compute the error associated with this result.
    errs = abs(f(xs(:, k + 2)));
    
end

%Define the output root.
rts = xs(:, end);

end

