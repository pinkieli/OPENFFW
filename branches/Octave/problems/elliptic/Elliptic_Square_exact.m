function p = Elliptic_Square_exact(p)
% example on unit square
%
%   -laplace(u) = 2((x-x^2)+(y-y^2)) in Omega
%            u  = 0 on boundary of Gamma
%
% with known exact solution:
%     u = x(1-x)y(1-y)

% Copyright 2007 Andreas Byfut
%
% This file is part of FFW.
%
% FFW is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% FFW is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


% PDE definition
p.problem.geom = 'Square';
p.problem.f = @f;
p.problem.g = [];
p.problem.u_D = @u_D;
p.problem.kappa = @kappa;
p.problem.lambda = @lambda;
p.problem.mu = @mu;

% load exact solution
p.problem.u_exact = @u_exact;
p.problem.gradU_exact = @gradU_exact;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Volume force
function z = f(x,y,p)
z = 2*((x-x.^2)+(y-y.^2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dirichlet boundary values
function z = u_D(x,y,p)
z = u_exact(x,y,p);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% elliptic PDE coefficent kappa ( div(kappa*grad_u) )
function z = kappa(x,y,p)

nrPoints = length(x);
z = zeros(2,2,nrPoints);

for curPoint = 1:nrPoints 
    z(:,:,curPoint) = [1 0;
                       0 1];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% elliptic PDE coefficent lambda ( lambda*grad_u )
function z = lambda(x,y,p)
nrPoints = length(x);
z = zeros(nrPoints,2);
for curPoint = 1:nrPoints 
    z(curPoint,:) = [0 , 0];
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% elliptic PDE coefficent mu ( mu*u )
function z = mu(x,y,p)
z = zeros(length(x),1);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% exact solution
function z = u_exact(x,y,p)
z = x.*(1-x).*y.*(1-y);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (approximated) gradU
function z = gradU_exact(x,y,p)
z = zeros(length(x),2);
z(:,1) = (1-2*x).*y.*(1-y);
z(:,2) = (1-2*y).*x.*(1-x);
