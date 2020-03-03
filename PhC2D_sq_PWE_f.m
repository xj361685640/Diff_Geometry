function[E,f0]=PhC2D_sq_PWE_f(x,y,Gx,Gy,k,HHH,nmodes,TE,TM)

%********************************************************************************
%********************************* Constants ************************************
%********************************************************************************

c=2.99792458e8;

%********************************************************************************
%************** Interpolation on a grid that have 2^N points ********************
%********************************************************************************

Nx=length(x);
Ny=length(y);

NGx=length(Gx);
NGy=length(Gy);
NG=NGx*NGy;

%********************************************************************************
%*************************** Building Hamiltonien *******************************
%********************************************************************************

[GXX,GYY]=meshgrid(Gx,Gy);
GXX=GXX(:);
GYY=GYY(:);

%************************************ TE ****************************************

if TE==1
    GkXX = ( GXX + k(1) )*( GXX + k(1) )'; % Gk(i,j) = (G(i) + k)*(G(j) + k)
    GkYY = ( GYY + k(2) )*( GYY + k(2) )';
    Gk=GkXX+GkYY;
end

%************************************ TM ****************************************

if TM==1
    Gk1 = sqrt( ( GXX + k(1) ) .^2 + ( GYY + k(2) ) .^2 );
    Gk2 = sqrt( ( GXX + k(1) )'.^2 + ( GYY + k(2) )'.^2 );
    Gk=Gk1*Gk2;
end

%********************************************************************************

HH=reshape(Gk,[NGy,NGx,NGy,NGx]);

H=HH.*HHH;
H=reshape(H,NG,NG); 

%********************************************************************************
%**************************** Solving Hamiltonian *******************************
%********************************************************************************

[psik,k0] = eig(H);   %%** eigen values are ordered

f0 = sqrt(diag(k0)) ; %%* actually it is w0
%lambda= 2*pi ./ sqrt(diag(k0)) * 1e6  ;

f0=f0(1:nmodes);
psik = psik(:,1:nmodes);

%********************************************************************************
%******************* Transforming & Scaling the waves functions *****************
%********************************************************************************
E =zeros(Nx,Ny, nmodes); 
for j=1:nmodes
    
    PSI = reshape(psik(:,j),[NGy,NGx]);
    PSI = invFFT2D(PSI,Ny,Nx);
    E(:,:,j) = PSI / max(PSI(:));
end

end



%********************************************************************************
%************************************* END **************************************
%********************************************************************************

function [Vxy] = invFFT2D(Vk2D,Ny,Nx)

Nkx=length(Vk2D(1,:));
Nky=length(Vk2D(:,1));

Nx1=Nx/2-floor(Nkx/2);
Nx2=Nx/2+ceil(Nkx/2);
Ny1=Ny/2-floor(Nky/2);
Ny2=Ny/2+ceil(Nky/2);

Vk2D00=zeros(Ny,Nx);
Vk2D00( Ny1+1:Ny2 , Nx1+1:Nx2)=Vk2D;
Vxy=ifft2(ifftshift(Vk2D00));

end

% function [Ex,Ey,Ez,Hx,Hy,Hz] = rfields(omega,HHH,GkXX,GkYY,k,psi,Ny,Nx,u)
% N=Ny*Nx;
% hx=psi(1:N/2,u); hy=psi((N/2+1):2*N,u); 
% hz=-(1/k(u))*(GkXX*hx+GkYY*hy);
% ex=-(1/omega)*HHH*(GkYY*hz-k(u)*hy); 
% ey=-(1/omega)*HHH*(k(u)*hx-GkXX*hz); 
% ez=-(1/omega)*HHH*(GkXX*hy-GkYY*hx); 
% 
% ex=reshape(ex,Ny,Nx); ey=reshape(ey,Ny,Nx); ez=reshape(ez,Ny,Nx); 
% hx=reshape(hx,Ny,Nx); hy=reshape(hy,Ny,Nx); hz=reshape(hz,Nx,Nx);
% Ex=(N)*ifft2(ifftshift(ex')); 
% Ey=(N)*ifft2(ifftshift(ey'));
% Ez=(N)*ifft2(ifftshift(ez')); 
% 
% Hx=(N)*ifft2(ifftshift(hx')); 
% Hy=(N)*ifft2(ifftshift(hy')); 
% Hz=(N)*ifft2(ifftshift(hz'));
% end
