function val = funcHandleWeightElems(x,y,parts,curLvl,p)

% Copyright 2007 Joscha Gedicke, Lena Noack
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

%% Input
u_h    = p.statics.u_h;

%% Residuum
curU_h = permute(u_h(x,y,parts,curLvl,p),[3 1 2]); 
curU_P1  = getU_h4e(x,y,parts,curLvl,p)';           
residuum = (curU_P1-curU_h)*ones(size(curU_h,2),1);

%% Output
val(1,:,:) = (residuum.^2)';

%% Function Handles
function u_h = getU_h4e(x,y,parts,lvl,p)
%uh = p.level(lvl).u4e;
%curU = uh(parts);
%u = repmat(curU,length(x),1);
u = p.level(lvl).P2u4e(x,y,parts,lvl,p);
basisU = getDisplacementBasis4e(x,y,parts,lvl,p);

u_h = sum((u * basisU')',2);
%%
function basisU = getDisplacementBasis4e(x,y,parts,lvl,p)
basisU = P2Basis4e(x,y,parts,lvl,p);%*...
%    [ 1 0 0 -2  0 -2 
%      0 1 0 -2 -2  0
%      0 0 1  0 -2 -2
%      0 0 0  4  0  0
%      0 0 0  0  4  0
%      0 0 0  0  0  4 ]';

%%
function basisU = P2Basis4e(x,y,curElem,lvl,p)

n4e = p.level(lvl).geom.n4e;
c4n = p.level(lvl).geom.c4n;
area4e = p.level(lvl).enum.area4e;

nodes = n4e(curElem,:);
coords = c4n(nodes,:);
area = area4e(curElem);

P1 = coords(1,:);
P2 = coords(2,:);
P3 = coords(3,:);

x = x';
y = y';

b1 = 1/2/area*( (P2(2)-P3(2))*x + (P3(1)-P2(1))*y + P2(1)*P3(2)-P3(1)*P2(2) );
b2 = 1/2/area*( (P3(2)-P1(2))*x + (P1(1)-P3(1))*y + P3(1)*P1(2)-P1(1)*P3(2) );
b3 = 1/2/area*( (P1(2)-P2(2))*x + (P2(1)-P1(1))*y + P1(1)*P2(2)-P2(1)*P1(2) );

basisU = [b1;
          b2;
          b3;
          b1.*b2;
          b2.*b3;
          b1.*b3]';