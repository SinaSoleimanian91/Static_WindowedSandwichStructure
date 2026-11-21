clear all
clc

%% units
msg = {'Units used in this code', '', ...
    'Lengths (thicknesses, plate size, radii Rx, Ry): mm', ...
    'Young''s modulus and stiffness: MPa (N/mm^2)', ...
    'Pressure q0: MPa (N/mm^2), set inside the script', ...
    'Deflection w: mm'};
uiwait(msgbox(msg, 'Units', 'help'));  


h1=input('sandwich core thickness (e.g. 5)=');  %central layer
h2=input('sandwich lower thickness (e.g. 1)=');  % upper  skin
h3=input('sandwich upper thickness (e.g. 1)=');  % upper skin
a=input('length (e.g. 900)=');
b=input('length (e.g. 450)=');

% (A0,D0 outside the windows, Aw,Dw inside), so the Galerkin integrals are
% evaluated in closed form over the plate and over the window rectangles.
% Three-layer sandwich, windows through ALL layers (glass):
%   outside the windows: core = GFRP orthogrid ribs, lower/upper layers = aluminium orthogrid ribs
%   inside the windows : glass in all three layers
% Assumes Q16=Q26=0 (orthotropic core, isotropic skins and glass).

%% Ply engineering properties 
%% core material
% Rib material: GFRP (core). Units: MPa
E1=36.04e3;%25.2e3;%
E2=9.03e3;%7.5e3;%
nu12=0.28;%0.32;%
nu21=nu12*E2/E1;
G12=2.85e3;%2.4e3;%
% Filler material: glass (window pane, in all three layers), isotropic. Units: MPa
E1f=70e3;                 % Young's modulus of glass (typically 63e3-73e3 MPa)
nu12f=0.22;               % Poisson's ratio of glass
G12f=0.5*E1f/(1+nu12f);   % shear modulus of an isotropic material (about 28.7e3 MPa)

%% skin material (lower and upper layers): aluminium ribs, isotropic. Units: MPa
% (previous values: E1p=36.04e3; E2p=9.03e3; nu12p=0.28; G12p=2.85e3)
E1p=70e3;                 % Young's modulus of aluminium (typically 69e3-73e3 MPa)
E2p=70e3;
nu12p=0.33;               % Poisson's ratio of aluminium
nu21p=nu12p*E2p/E1p;
G12p=E1p/(2*(1+nu12p));   % shear modulus of an isotropic material (about 26.3e3 MPa)

%% Q matrix 
denom=1-nu12*nu21;
Q11 =E1/denom;
Q12 =nu12*E2/denom;
Q22 =E2/denom;
Q66 =G12;

denomp=1-nu12p*nu21p;
Q11p =E1p/denomp;
Q12p =nu12p*E2p/denomp;
Q22p =E2p/denomp;
Q66p =G12p;

denomf=1-nu12f*nu12f;
Q11f =E1f/denomf;
Q12f =nu12f*E1f/denomf;
Q22f =E1f/denomf;
Q66f =G12f;

Qfill=[Q11f Q12f 0;Q12f Q22f 0;0 0 Q66f];
Q0      =[Q11 Q12 0;Q12 Q22 0;0 0 Q66];
Q90     =Q0;
Qnode=Q0;
Qp=[Q11p Q12p 0;Q12p Q22p 0;0 0 Q66p];

%% Window layout: nx-by-ny rectangular array of windows (nx may differ from ny)
per=input('Window area as fraction of plate area (e.g. 0.1) = ');
nx =input('Number of windows in x-direction, mx (e.g. 3)=  ');
ny =input('Number of windows in y-direction, ny (e.g. 1) = ');
asp=1;                              % window aspect ratio cy/cx (1 = square windows)

cx=sqrt(per*a*b/(nx*ny*asp));       % window size in x  (nx*ny*cx*cy = per*a*b)
cy=asp*cx;                          % window size in y
if nx*cx>=a || ny*cy>=b
    error('Windows do not fit in the plate: reduce void percentage or change nx, ny.');
end
gap_x=(a-nx*cx)/(nx+1);             % equal spacing, also to the plate edges
gap_y=(b-ny*cy)/(ny+1);
xc=gap_x+0.5*cx+(0:nx-1)*(gap_x+cx);   % window centres in x
yc=gap_y+0.5*cy+(0:ny-1)*(gap_y+cy);   % window centres in y
x1=xc-0.5*cx; x2=xc+0.5*cx;            % window edges in x
y1=yc-0.5*cy; y2=yc+0.5*cy;            % window edges in y

%% Shallow-shell curvature (Donnell-type). Flat plate: Rx=Ry=Inf
% w positive = away from the centre of curvature; kx=1/Rx, ky=1/Ry.
% Positive q0 acts in the -w direction (towards the centre of curvature if kx,ky>0).
Rx=input('Radius of curvature Rx (e.g. Inf) = ');
Ry=input('Radius of curvature Ry (e.g. 5000) = ');
kx=1/Rx; ky=1/Ry;
if max(a*abs(kx),b*abs(ky))/8>0.2     % rise/span > 1/5: classical shallow-shell limit
    warning('Rise/span > 1/5: shallow-shell assumption may not be valid.');
end

%% Laminated approach (B coupling neglected; B=0 anyway for h2=h3)
zbar(1)=-0.5*(h1+h2);
zbar(2)=0;
zbar(3)=0.5*(h1+h3);
Ask=Qp*h2+Qp*h3;
Dsk=Qp*(h2*zbar(1)^2+h2^3/12)+Qp*(h3*zbar(3)^2+h3^3/12);
A0=Q0*h1+Ask;    D0=Q0*(h1*zbar(2)^2+h1^3/12)+Dsk;       % outside the windows: GFRP core + Al layers
% inside the windows: all three layers are glass (one glass pane of thickness h1+h2+h3)
Aw=Qfill*(h1+h2+h3);
Dw=Qfill*((h1*zbar(2)^2+h1^3/12)+(h2*zbar(1)^2+h2^3/12)+(h3*zbar(3)^2+h3^3/12));
dA=Aw-A0; dD=Dw-D0;

%% Modal amplitudes (Navier-type, one (m,n) pair at a time)
q0=input('Load (e.g. 0.1) =');
sh=13;                               % number of modes in each direction
Wc=zeros(sh,sh);
tic
for ii=1:2:sh                        % uniform load projects only onto odd m,n
    for jj=1:2:sh
        al=ii*pi/a; be=jj*pi/b;
        [Pss,Pcc]=rectInt(al,be,0,a,0,b);        % whole plate
        [Qss,Qcc]=rectInt(al,be,x1,x2,y1,y2);    % all windows together
        % integrals of the piecewise-constant stiffness times the mode products
        A11s=A0(1,1)*Pss+dA(1,1)*Qss;  A12s=A0(1,2)*Pss+dA(1,2)*Qss;  A22s=A0(2,2)*Pss+dA(2,2)*Qss;
        A66c=A0(3,3)*Pcc+dA(3,3)*Qcc;
        D11s=D0(1,1)*Pss+dD(1,1)*Qss;  D12s=D0(1,2)*Pss+dD(1,2)*Qss;  D22s=D0(2,2)*Pss+dD(2,2)*Qss;
        D66c=D0(3,3)*Pcc+dD(3,3)*Qcc;
        k11=-(A11s*al^2+A66c*be^2);
        k12=-(A12s+A66c)*al*be;                  % k21=k12
        k22=-(A66c*al^2+A22s*be^2);
        k31=al*(kx*A11s+ky*A12s);                % k13=k31 (curvature coupling)
        k32=be*(kx*A12s+ky*A22s);                % k23=k32
        k33=-(D11s*al^4+2*D12s*al^2*be^2+D22s*be^4+4*D66c*al^2*be^2) ...
            -(kx^2*A11s+2*kx*ky*A12s+ky^2*A22s);
        K=[k11 k12 k31; k12 k22 k32; k31 k32 k33];
        Lmn=q0*a*b*(1-cos(ii*pi))*(1-cos(jj*pi))/(ii*jj*pi^2);
        sol=K\[0;0;Lmn];
        Wc(ii,jj)=sol(3);                        % w amplitude
    end
end
fprintf('Stiffness and modal amplitudes done in %.3f s\n',toc);

% Deflection at the plate centre
xx=a/2; yy=b/2;
w_center=0;
for ii=1:2:sh
    for jj=1:2:sh
        w_center=w_center+Wc(ii,jj)*sin(ii*pi*xx/a)*sin(jj*pi*yy/b);
    end
end
w_center;

%% Deformation field and plots
xv=linspace(0,a,301); yv=linspace(0,b,301);
[X,Y]=meshgrid(xv,yv);
Wfull=zeros(size(X));
for ii=1:2:sh
    for jj=1:2:sh
        Wfull=Wfull+Wc(ii,jj)*sin(ii*pi*X/a).*sin(jj*pi*Y/b);
    end
end

% windows are glass-filled (not through holes): the field is shown everywhere, windows only outlined
Wp=Wfull;

% Curved undeformed geometry (crown at the centre; +z = away from the centre of curvature)
z0fun=@(X,Y) -((X-a/2).^2*kx+(Y-b/2).^2*ky)/2;
Z0=z0fun(X,Y);

% Plot the deformation (calculated magnitude)
sf=1;
Z=Z0+sf*Wp;

figure('Color','w','Position',[100 100 720 520])
surf(X,Y,Z,abs(Wp),'EdgeColor','none'); hold on     % colour = deflection magnitude |w|
for ii=1:nx
    for jj=1:ny
        xe=[linspace(x1(ii),x2(ii),30), x2(ii)*ones(1,30), linspace(x2(ii),x1(ii),30), x1(ii)*ones(1,30)];
        ye=[y1(jj)*ones(1,30), linspace(y1(jj),y2(jj),30), y2(jj)*ones(1,30), linspace(y2(jj),y1(jj),30)];
        ze=z0fun(xe,ye)+sf*interp2(X,Y,Wfull,xe,ye);
        plot3(xe,ye,ze,'k','LineWidth',1.5);
    end
end
cb=colorbar; ylabel(cb,'|w|'); colormap(parula); view(0,90); axis tight; pbaspect([1 b/a 0.4])
xlabel('x'); ylabel('y'); zlabel('z')
title('Curved plate with actual deflection (no exaggeration)')



%% Local function: closed-form integrals over a set of windows (Cartesian grid of rectangles)
% Pss = int sin^2(al x) sin^2(be y),  Pcc = int cos^2(al x) cos^2(be y)
function [Pss,Pcc]=rectInt(al,be,xa,xb,ya,yb)
Fss=@(t,k) t/2-sin(2*k*t)/(4*k);
Fcc=@(t,k) t/2+sin(2*k*t)/(4*k);
Pss=sum(Fss(xb,al)-Fss(xa,al))*sum(Fss(yb,be)-Fss(ya,be));
Pcc=sum(Fcc(xb,al)-Fcc(xa,al))*sum(Fcc(yb,be)-Fcc(ya,be));
end
