function p = example2

% Copyright 2007 Joscha Gedicke
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


%% Problem Type
problem = 'Elliptic_Lshape';

%% PDE Solver
pdeSolver = 'P1';

%% Maximum Number Degrees of Freedom
maxNrDoF = 100;

%% Mark Criterion
mark = 'uniform';

%% Compute Discrete Solution
p = initFFW(pdeSolver,problem,mark,maxNrDoF,'elliptic');
p = computeSolution(p);

%% Show Discrete Solution
figure(1)
p.params.output.holdIt = false; 

set(gcf,'Name','Displacement');
p = show('drawU',p);
view(-30,20)

%% Show Grid
figure(2)
p.params.output.holdIt = false; 

set(gcf,'Name','Grid');
p = show('drawGrid',p);

%% Show Convergence History
figure(3)
set(gcf,'Name','Convergence History');
p.params.output.minDoF = 1;
p.params.output.drawConvergenceRate = false;
p.params.errorIntegtrateExactDegree = 9;
p.params.output.holdIt = true; 

p.params.output.name = [mark,', ',pdeSolver,', ','estimator'];
p = show('drawError_estimatedError',p);

