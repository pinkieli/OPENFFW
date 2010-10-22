function p = ODRTgetUhFuncs(p)
% author: David Guenther 

p.statics.u_h = @getU_h;
p.statics.Au_h = @getAu_h;
p.statics.gradAu_h = @getGradAu_h;
p.statics.I2u_h = @getI2u_h;
p.statics.gradI2u_h = @getGradI2u_h;

%% supply u_h
function u_h = getU_h(x,y,curElem,lvl,p)

u = p.level(lvl).u4e;
curU = u(curElem);
u_h = repmat(curU,length(x),1);

%% supply Au_{h}
function Auh = getAu_h(x,y,curElem,lvl,p)

Auh4n = p.level(lvl).Auh;
n4e = p.level(lvl).geom.n4e;

basisP1 = getP1basis(x,y,curElem,lvl,p);

Auh = Auh4n(n4e(curElem,:),1)'*basisP1;

%% supply grad Au_{h}
function gradAuh = getGradAu_h(x,y,curElem,lvl,p)

Auh4n = p.level(lvl).Auh;
n4e = p.level(lvl).geom.n4e;

gradBasisP1 = getGradP1basis(x,y,curElem,lvl,p);

Auh = Auh4n(n4e(curElem,:),1)';

gradAuh = squeeze(matMul(repmat(Auh,[1 1 length(x)]),gradBasisP1))';

%% supply I^2(Au_h)
function I2Auh = getI2u_h(x,y,curElem,lvl,p)

n4e = p.level(lvl).geom.n4e;
c4n = p.level(lvl).geom.c4n;

ed4e = p.level(lvl).enum.ed4e;
midPoint4ed = p.level(lvl).enum.midPoint4ed;

coords = [c4n(n4e(curElem,:),:);
          midPoint4ed(ed4e(curElem,:),:)];

Auh = p.statics.Au_h;
evalAuh = Auh(coords(:,1),coords(:,2),curElem,lvl,p);

basisP2 = p.statics.basisP2;
evalBasisP2 = basisP2(x,y,curElem,lvl,p);

I2Auh = (evalAuh * evalBasisP2)';

%% supply grad I^2(Au_h)
function gradI2uh = getGradI2u_h(x,y,curElem,lvl,p)

n4e = p.level(lvl).geom.n4e;
c4n = p.level(lvl).geom.c4n;

ed4e = p.level(lvl).enum.ed4e;
midPoint4ed = p.level(lvl).enum.midPoint4ed;

Auh = p.statics.Au_h;
gradBasisP2 = p.statics.gradBasisP2;

coords = [c4n(n4e(curElem,:),:);
          midPoint4ed(ed4e(curElem,:),:)];
      
evalAuh = Auh(coords(:,1),coords(:,2),curElem,lvl,p);

evalGradBasisP2 = gradBasisP2(x,y,curElem,lvl,p);

evalAuh = repmat(evalAuh',[1 1 length(x)]);

gradI2uh = squeeze(matMul(evalAuh,evalGradBasisP2));
