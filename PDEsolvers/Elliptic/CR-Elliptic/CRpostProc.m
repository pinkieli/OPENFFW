function p = CRpostProc(p)
% computes the post-processing datas for 
% a nonconforming CR-FE method.

% Copyright 2007 Jan Reininghaus, David Guenther
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

x = p.level(end).x;
f = p.problem.f;

% load enumerated data
NCgrad4e = p.level(end).enum.gradNC4e;
ed4e = p.level(end).enum.ed4e;
midPoint4e = p.level(end).enum.midPoint4e;
nrElems = p.level(end).nrElems;
nrEdges = p.level(end).nrEdges;


%% PostProc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
u = x(1:nrEdges);

grad4e = zeros(nrElems,2);
u4e = zeros(nrElems,3);

for curElem = 1:nrElems
	curGrads = NCgrad4e(:,:,curElem);
	curEdges = ed4e(curElem,:);
	curU = u(curEdges);
    u4e(curElem,:) = curU;
    grad4e(curElem,:) = curU' * curGrads;
end

gradRT0 = zeros(3,2,nrElems);
% assume f is piecewise constant
f4T = f(midPoint4e,p);
for curElem = 1:nrElems
	curGrads = repmat(grad4e(curElem,:),3,1);
	curNodes = n4e(curElem,:);
	midPoint = repmat(midPoint4e(curElem,:),3,1);
	gradRT0(:,:,curElem) = curGrads - f4T(curElem)*(c4n(curNodes,:)-midPoint)/2;
end

%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.level(end).u = u;
p.level(end).u4e = u4e;
p.level(end).grad4e = grad4e;
p.level(end).gradRT0 = gradRT0;