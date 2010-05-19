function p = ODRTestimate_P1(p)
% author: David Guenther 
% Copyright 2007 David Guenther
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
%
%
%

%% INPUT
sigma_h = p.statics.sigma_h;
conjNonLinearFuncDer = p.problem.conjNonLinearFuncDer;
nrElems = p.level(end).nrElems;
nrNodes = p.level(end).nrNodes;
lvl = size(p.level,2);

%% compute P1-solution

q.level(1).geom = p.level(end).geom;
q.params = p.params;
q.problem = p.problem;
q.params.maxLevel = 1;
q.params.modules.mark.bulk.refineFirstLevel = false;
q.level(1).level = 1;

if size(p.level,2) > 2
    q.level(1).x0 = p.level(end-1).P1x;
else
    q.level(1).x0 = zeros(nrNodes,1);
end

options = optimset('Display','iter','Jacobian','on','NonlEqnAlgorithm','gn','MaxIter',10,'TolFun',1e-10,'TolX',1e-10);
q.params.options = options;

addpath(fullfile(pwd,'PDEsolvers','P1-NonLinear'));
q = run(q);
rmpath(fullfile(pwd,'PDEsolvers','P1-NonLinear'));

P1u4e = q.level(2).u4e;
P1x = q.level(2).x;

%% estimate the error by computing \eta=||DW*(p_h)-\grad v_h||_L^2

eta4T = zeros(nrElems,1);

for curElem = 1:nrElems    
    eta4T(curElem) = intNonLinear(@integrand,sigma_h,P1u4e(curElem,:),[],[],...
        conjNonLinearFuncDer,[],curElem,lvl,p);
end


%% compose the error terms
estimatedError = sqrt(sum(eta4T));

%% OUTPUT
p.level(end).etaT = sqrt(eta4T);
p.level(end).P1x = P1x;

p.level(end).estimatedError = estimatedError;

%% supply the integrand: (DW*(p_h)-\grad v_h)^2
function val = integrand(points,func,P1u4e,dontUse1,dontUse2,nonLinear,dontUse3,curElem,lvl,p)

evalFunc = func(points,curElem,lvl,p);
absFunc = (evalFunc(:,1).^2 + evalFunc(:,2).^2).^(1/2);
evalNonLinear = (nonLinear(absFunc,curElem,lvl,p)*[1,1]).*evalFunc;

gradBasisP1 = p.statics.gradBasisP1;
evalGradBasisP1 = gradBasisP1(points,curElem,lvl,p);

b1 = squeeze(evalGradBasisP1(1,:,:))';
b2 = squeeze(evalGradBasisP1(2,:,:))';
b3 = squeeze(evalGradBasisP1(3,:,:))';

gradVh = P1u4e(1)*b1 + P1u4e(2)*b2 + P1u4e(3)*b3;
val = sum( (evalNonLinear-gradVh).^2,2 );
val = reshape(val,[1 1 length(points(:,1))]);
