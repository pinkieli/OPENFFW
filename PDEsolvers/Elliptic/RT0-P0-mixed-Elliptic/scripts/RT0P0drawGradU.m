function p = RT0P0drawGradU(p,lvl)
% draw piecewise linear vector field with default parameters:
% drawInfo = true
% localRes = 5
% drawStreamslice = true

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


if(nargin < 2 || isempty(lvl))
	lvl = p.level(end).level;
end

%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set graphic options from structure p
drawInfo = loadField('p.params.output.drawGradU','drawInfo',p,true);
localRes = loadField('p.params.output.drawGradU','localRes',p,5);
drawStreamslice = loadField('p.params.output.drawGradU','drawStreamslice',p,true);

% load geometry
n4e = p.level(lvl).geom.n4e;
c4n = p.level(lvl).geom.c4n;

% load gradients
grad = p.level(lvl).grad;

% load enumerated data
nrElems = p.level(lvl).nrElems;
nrDoF = p.level(lvl).nrDoF;
area4e = p.level(lvl).enum.area4e;

%% drawGradU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
normRes = localRes*10;

if(nrElems > 50)
	warning('This may take forever. Please try a smaller level')
	pause
end

hold on;
coordX = reshape(c4n(n4e',1),3,nrElems);
coordY = reshape(c4n(n4e',2),3,nrElems);
normGrad = squeeze((grad(:,1,:).^2 + grad(:,2,:).^2).^(1/2));
patch(coordX,coordY,zeros(size(coordX)),normGrad);

if(drawStreamslice)
    for curElem = 1:nrElems
        curU = grad(:,1,curElem);
        curV = grad(:,2,curElem);
        curArea = area4e(curElem);
        curNodes = n4e(curElem,:);
        coordX = c4n(curNodes,1);
        coordY = c4n(curNodes,2);
        minX = min(coordX);
        minY = min(coordY);
        maxX = max(coordX);
        maxY = max(coordY);

        diam = sqrt(curArea);
        XI = minX:diam/localRes:maxX;
        YI = minY:diam/localRes:maxY;

        UI=tri2grid([coordX,coordY]',[1,2,3,1]' ,...
            [curU;curU;curU],XI,YI' );
        VI=tri2grid([coordX,coordY]',[1,2,3,1]' ,...
            [curV;curV;curV],XI,YI' );

        % Draw Streamlines
        handle = streamslice(XI,YI,UI,VI);
        set(handle,'Color','black');
    end
end

hold off

if(drawInfo)
	xlabel(sprintf('Nr of degrees of freedom: %g',nrDoF));
	title('Gradient of P0-RT0 Solution');
end