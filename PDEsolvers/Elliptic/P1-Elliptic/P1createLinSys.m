function p = P1createLinSys(p)
% creates the energy matrix A 
% and the right-hand side b for a conforming P1-FE method. 
% The differential operator is full elliptic with piecewise constant
% coefficients (one point gauss integration). 

% Copyright 2007 Jan Reininghaus, David Guenther, 
%                Joscha Gedicke, Andreas Byfut
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


%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load geometry
n4e = p.level(end).geom.n4e;
c4n = p.level(end).geom.c4n;
Nb = p.level(end).geom.Nb;

% load problem definition
kappa = p.problem.kappa;
lambda = p.problem.lambda;
mu = p.problem.mu;
u_D = p.problem.u_D;

% load enumerated data
fixedNodes = p.level(end).enum.fixedNodes;
midPoint4e = p.level(end).enum.midPoint4e;
grad4e = p.level(end).enum.grad4e;
area4e = p.level(end).enum.area4e;
nrNodes = p.level(end).nrNodes;
nrElems = p.level(end).nrElems;
dofU4e = p.level(end).enum.dofU4e;
e4ed = p.level(end).enum.e4ed;
NbEd = p.level(end).enum.NbEd;

% load additional data
f4e = loadField('p.level(end)','f4e',p,[]);

% load integration parameters
% degreeStima = p.params.integrationDegrees.createLinSys.Stima;
% degreeDama = p.params.integrationDegrees.createLinSys.Dama;
% degreeMama = p.params.integrationDegrees.createLinSys.Mama;
degreeRhs = p.params.integrationDegrees.createLinSys.Rhs;
degreeNeumann = p.params.integrationDegrees.createLinSys.Neumann;

% get current level number
curLvl = length(p.level);

%% Assembling global energy matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

kappa4e = kappa(midPoint4e,p);
lambda4e = lambda(midPoint4e,p);
mu4e = mu(midPoint4e,p);

% local energy matrix: loop version
S = zeros(3,3,nrElems);
genericMama = (ones(3)+eye(3))/12;
genericDama = [1 1 1]/3;

for curElem = 1:nrElems	
	grad = grad4e(:,:,curElem);
	area = area4e(curElem);
	curKappa = kappa4e(:,:,curElem);
    curLambda = lambda4e(curElem,:)';
    curMu = mu4e(curElem);
    
	localStima = grad*curKappa*grad'*area;
	localDama  = grad*curLambda*area*genericDama;
	localMama  = curMu*area*genericMama;
	
	S(:,:,curElem) = localStima + localMama + localDama;
end

% local energy matrix: loop free version 
% area = reshape(repmat(area4e',[9 1]),[3 3 nrElems]);
% lambda4e = reshape(lambda4e',[2,1,nrElems]);
% mu4e = reshape(repmat(mu4e',[9 1]),[3 3 nrElems]);
% 
% grad4eT = permute(grad4e,[2 1 3]);
% dama = ones(1,3,nrElems)/3;
% mama = repmat((ones(3)+eye(3))/12,[1,1,nrElems]);
% 
% localStima = matMul(matMul(grad4e,kappa4e),grad4eT);
% localDama = matMul(matMul(grad4e,lambda4e),dama);
% localMama = mu4e.*mama;
% 
% S = (localStima + localMama + localDama).*area;

[I,J] = localDoFtoGlobalDoF(dofU4e,dofU4e);
A = sparse(I(:),J(:),S(:));


%% Assembling Righthandside %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (~f4e)
    % f4e = integrate(n4e,curLvl,degreeRhs,@funcHandleRHSVolume,p);
    f4e = integrateVectorised(n4e,curLvl,degreeRhs,@funcHandleRHSVolumeVectorised,p);
end
b = accumarray(n4e(:),f4e(:));

%% Include Neumann conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(Nb)
     g4NbEd = integrateVectorised(Nb,curLvl,degreeNeumann,@funcHandleRHSNbVectorised,p);
     n4NbElem = n4e(e4ed(NbEd),:);
     neumann = accumarray(n4NbElem(:),g4NbEd(:),[nrNodes,1]);     
     b = b + neumann;
end
 
%% Include Dirichlet conditions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
u = zeros(nrNodes,1);
u(fixedNodes) = u_D(c4n(fixedNodes,:),p);
b = b - A*u;

%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.level(end).A = A;
p.level(end).b = b;
p.level(end).x = u;