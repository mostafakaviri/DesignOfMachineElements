%prompt 
% this script finds the values for minimum thickness of the stepped shaft
% variables --------------------------------definition
%T-------------------------------------Shaft torque (N.mm)
% N------------------------------------- rotational speed (rpm)
% dg--------------------------------------gear diameter(mm)
% fg-------------------------------------  gear force (N)
% conf------------------------------- component configuration on the shaft
% dis---------------------------------distance between components (mm)
%fb-------------------------------------bearing force (N)
% M_y------------------------------bending moment along Y axis(N.mm)
% M_z------------------------------bending moment along Z axis(N.mm)
% M_total------------------------------total bending moment (N.mm)
%TT--------------------------------------torque on the shaft (N.mm)
%S_ut------------------------------------ultimate strength(MPa)
%S_y---------------------------------------yield strength
%d-------------------------------------------minimum shaft diameter
%inertia---------------------------------surface inertia of the shaft
%area---------------------------------------area of the sahft cross section
%mass--------------------------------------mass of the shaft
%Csp---------------------------------------critical speed in rpm
%delta--------------------------------------deflection under load
%teta_left-----------------------------------slope on left bearing
%teta_right---------------------------------slope on right bearing
%---------------------------------------------------------------------------
%prompt user to enter known variables
T=input('please enter Torque transmitted by the shaft in (KW); if non known []');
dg1=input('please enter the diameter of the gear 1 on the shaft in in>>');
%prompt user of the calculated forces of the elements
fg1=input('please enter [fx, fy, fz] of the gear 1 in lb>>');
%prompt user to find bearing forces
display('for finding bearing forces we need to find distances between elements on the shaft');
%display('we start from the left end of the shaft and calculate distance to the right');
%conf=input('if count from the left end how elements are mounted relatively? example [1, 2, 3, 2] means pulley=1, then a bearing=2, then a gear=3 and then a bearing=2 again');
dis=input('please enter distance vector as [from the left: distance between elements 1 and 2, distance between elements 2 and 3....] in inches');
display('we use static equilibrium condition to find bearing load')
fb1=input('please enter [fx fy fz] for first bearing in lbf>>');
fb2=input('please enter [fx fy fz] for second bearing in lbf>>');
%prompt user for endurance limit
S_ut=input('please enter ultimate strength of  shaft material (Mpa)>>');
S_y=input('please enter yield strength of  shaft material (MPa)>>');
dis=[0,dis];
len=sum(dis);
%prompt user for computing moments
x1=[dis(1,1):0.1:dis(1,2)];
x2=[dis(1,2):0.1:(dis(1,2)+dis(1,3))];
M_y1=fb1(1,3)*x1;
M_y2=fb1(1,3)*x2+fg1(1,3)*(x2-x1(end));
M_z1=fb1(1,2)*x1;
M_z2=fb1(1,2)*x2+fg1(1,2)*(x2-x1(end));
figure()
plot(x1, M_y1, x2, M_y2);
title('y-axis bending moment distribution')
xlabel('shaft length (mm)');
ylabel('moment (N.mm)');
figure()
plot(x1, M_z1, x2, M_z2);
title('z-axis bending moment distribution')
xlabel('shaft length (mm)');
ylabel('moment (N.mm)');
%prompt computing total moment
M_total1=sqrt(M_y1.^2+M_z1.^2);
M_total2=sqrt(M_y2.^2+M_z2.^2);
figure()
plot(x1, M_total1, x2, M_total2);
title('Total bending moment distribution')
xlabel('shaft length (mm)');
ylabel('moment (N.mm)');
TT1=T+zeros (size(x1));
TT2=T+zeros (size(x2));
figure()
plot(x1, TT1, 'p', x2, TT2, 'p');
title(' torsion moment distribution')
xlabel('shaft length (mm)');
ylabel('moment (N.mm)');
%prompt calculating endurance limit
%surface factoe Ka is computed assuming machined shaft
Ka=2.7*S_ut^(-0.265);
%size factor is used with initial guess of diameter 40 mm
din=40/25.4;
Kb=0.91*din^(-0.157);
%reliability of 90%
Ke=0.897;
Se=Ka*Kb*Ke*0.5*S_ut;
%stress concentration factor and critical locations
display('the maximum bending moment is>>')
M_max= max([M_total1, M_total2]);
display('Based on the total bending diagram, is there a stress concentration casue in vecinity of maximum bending moment?');
ss1=input('is there a step near the maximum bending, if yes enter 1, if no enter 0');
if ss1==1
    %this code assumes r/d=0.02 and 
    Kf1=1+0.8*(1.7);
    Kfs1=1+0.8*(1.2);
else
    Kf1=1;
    Kfs1=1;
end
ss2=input('is there a keyseat near the maximum bending, if yes enter 1, if no enter 0');
if ss2==1
    %this code assumes r/d=0.02 and 
    Kf2=1+0.8*(1.14);
    Kfs2=1+0.8*(2);
else
    Kf2=1;
    Kfs2=1;
end
nd=input('please enter safety factor (recommended factor is 1)>>');
display('this code assumes complete reversible bending moment and continious power transmission')
dmin1=(16*nd/pi*(2*Kf1*M_max/(Se)+sqrt(3)*Kfs1*T/(S_ut)))^(1/3);
dmin2=(16*nd/pi*(2*Kf2*M_max/(Se)+sqrt(3)*Kfs2*T/(S_ut)))^(1/3);
d=max(dmin1,dmin2);
display('the minimum required diameter of the shaft in gear 2 position is>>')
d=max(dmin1,dmin2);
%prompt user of maximum deflection and slopes at bearings
inertia=3.14*d^4/64;
delta=sqrt(fg1(1,3)^2+fg1(1,2)^2)*dis(1,3)*dis(1,2)*(len^2-dis(1,3)^2-dis(1,2)^2)/(6*210000*inertia*len)
teta_left=dis(1,3)*(len^2-dis(1,3)^2)/(6*210000*inertia*len)
teta_right=dis(1,2)*(len^2-dis(1,2)^2)/(6*210000*inertia*len)
%prompt user for critical speed in rpm
area=3.14*(d/1000)^2/4;
mass=area*len*7.80;
Csp=(3140/len)^2*sqrt(0.21*inertia/mass)*30/6.28
