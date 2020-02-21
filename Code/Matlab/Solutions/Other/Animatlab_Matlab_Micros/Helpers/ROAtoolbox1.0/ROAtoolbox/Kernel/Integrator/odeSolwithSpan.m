function [t,x] = odeSolwithSpan(fun,tspan,x0,xspan)

% state count: n
% xspan: n by matrix, xspan(:,1) is the bottom limit
% by YUAN Guoqiang 
% Mar 2015
%

global xleft  xright 

xleft = xspan(:,1);
xright = xspan(:,2);

% options = odeset('Events',@events, 'MaxStep',20);
options = odeset('Events',@events);
[t,x] = ode45(fun,tspan,x0,options);
%[t,x] = ode23(fun,tspan,x0,options);


function [value,isterminal,direction] = events(t,x)
% Locate the time when height passes through zero in a decreasing direction
% and stop integration.  
global xleft  xright 

tm = (x - xleft) .* (xright - x);
tm = tm > 0;
value = prod(tm); % detect = 0
% for matlab2012a and pre
% if tm > 0
%     la = 1;
% else
%     la = 0;
% end
% value = la;
isterminal = 1;   % stop the integration
direction = 0;   % direction

