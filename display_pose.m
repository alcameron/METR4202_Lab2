function display_pose(extrinsics, intrinsics)
%DISPLAY_POSE graphically displays the position of the camera
%
%   Uses the given extrinsic matrix(es) to plot the location of the camera
%   with the given intrinsics relative to the caltag target.
%

f = figure(2);
clf;
hold on;

colors = 'brgkcm';
nx = 1280; ny = 1024;
alpha_c = intrinsics.alpha_c;
fc = intrinsics.fc;
cc = intrinsics.cc;
dX = 24.5;
IP = 2*dX*[1 -alpha_c 0;0 1 0;0 0 1]*[1/fc(1) 0 0;0 1/fc(2) 0;0 0 1]*[1 0 -cc(1);0 1 -cc(2);0 0 1]*[0 nx-1 nx-1 0 0 ; 0 0 ny-1 ny-1 0;1 1 1 1 1];
BASE = 2*(.9)*dX*([0 1 0 0 0 0;0 0 0 1 0 0;0 0 0 0 0 1]);
IP = reshape([IP;BASE(:,1)*ones(1,5);IP],3,15);
POS = [[7*dX;0;0] [0;7*dX;0] [-dX;0;6*dX] [-dX;-dX;-dX] [0;0;-dX]];
YYx = 0:dX:6*dX;
YYx = [YYx;YYx;YYx;YYx;YYx];
YYy = (0:dX:4*dX)';
YYy = [YYy YYy YYy YYy YYy YYy YYy];
YYz = zeros(5,7);

for kk = 1:1:size(extrinsics,3),
    R_kk = extrinsics(1:3,1:3,kk);
    Tc_kk = extrinsics(1:3,4,kk);
    BASEk = R_kk'*(BASE - Tc_kk * ones(1,6));
    IPk = R_kk'*(IP - Tc_kk * ones(1,15));
    POSk = R_kk'*(POS - Tc_kk * ones(1,5));
    figure(f);
    p1 = struct('vertices',IPk','faces',[1 4 2;2 4 7;2 7 10;2 10 1]);
    h1 = patch(p1);
    set(h1,'facecolor',[52 217 160]/255,'EdgeColor', 'r');
    p2 = struct('vertices',IPk','faces',[1 10 7;7 4 1]);
    h2 = patch(p2);
    set(h2,'facecolor',[247 239 7]/255,'EdgeColor', 'none');
    plot3(BASEk(1,:),BASEk(2,:),BASEk(3,:),'b-','linewidth',1');
    plot3(IPk(1,:),IPk(2,:),IPk(3,:),'r-','linewidth',1);
    text(POSk(1,5),POSk(2,5),POSk(3,5),num2str(kk),'fontsize',10,'color','k','FontWeight','bold');
    hhh= mesh(YYx,YYy,YYz);
    set(hhh,'edgecolor',colors(rem(kk-1,6)+1),'linewidth',1); %,'facecolor','none');
end;

figure(f);rotate3d on;
axis('equal');
title('Extrinsic parameters (world-centered)');
xlabel('X_{world}')
ylabel('Y_{world}')
zlabel('Z_{world}')
view(50,20);
axis vis3d;
axis tight;
grid on;
plot3(3*dX*[1 0 0 0 0],3*dX*[0 0 1 0 0],3*dX*[0 0 0 0 1],'r-','linewidth',3);
hold off;
set(f,'color',[1 1 1]);

set(f,'Name','3D','NumberTitle','off');