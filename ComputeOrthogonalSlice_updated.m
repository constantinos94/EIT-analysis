function I=ComputeOrthogonalSlice_updated(algo,res,DICOMVolume,S,plane,dis)

M=DICOMVolume.ImageData;                            % copying DICOM images into variable M
X1=size(M,1);                                       % checking for dimensions of dicom data
Y1=size(M,2);
Z1=size(M,3);

% [Xin,Yin,Zin] = meshgrid(1:1:X1, 1:1:Y1,1:1:Z1);    % predicting mesh grid to display data in 3D
% [xq_1,yq_1,zq_1] = meshgrid(1:1:X1, 1:1:Y1,1:res:Z1);   %predicting mesh with pixel dimensions

Vq = M;        
if(plane==1)
    img_xy=Vq(:,:,S);                                       % copying interpolated xy plane at that location
    img_xy=img_xy-min(img_xy(:));                           % normalizing image slice
    img_xy=img_xy/max(img_xy(:));
    [X_xy,Y_xy] = meshgrid(1:size(img_xy,1),1:size(img_xy,2));  % building mesh to plot image in 3D plane
    Z_xy(1:size(X_xy,1),1:size(X_xy,2))=S;
    if(dis==1)
        warp(X_xy,Y_xy,Z_xy,img_xy);                                % plotting image in 3D plane
        hold off
    end
    
    I=img_xy;
end

if(plane==2)
    img_xz=squeeze(Vq(:,S,:));                              % copying interpolated xz plane at that location    
    img_xz=img_xz-min(img_xz(:));                           % normalizing image slice
    img_xz=img_xz/max(img_xz(:));
    [Y_xz,Z_xz] = meshgrid(1:size(img_xz,1),1:size(img_xz,2));  % building mesh to plot image in 3D plane
    X_xz(1:size(Y_xz,1),1:size(Y_xz,2))=S;
    if(dis==1)
        warp(X_xz,Y_xz,Z_xz,img_xz');                           % plotting image in 3D plane
        hold off
    end
    
    I=img_xz';
end

if(plane==3)
    img_yz=squeeze(Vq(S,:,:));                              % copying interpolated yz plane at that location
    img_yz=img_yz-min(img_yz(:));                           % normalizing image slice
    img_yz=img_yz/max(img_yz(:));
    [X_xz,Z_xz] = meshgrid(1:size(img_yz,1),1:size(img_yz,2));  % building mesh to plot image in 3D plane    
    Y_xz(1:size(X_xz,1),1:size(X_xz,2))=S;
    if(dis==1)
        warp(X_xz,Y_xz,Z_xz,img_yz');                           % plotting image in 3D plane
        hold off
    end
    
    I=img_yz';
end

if(dis==1)
    xlabel('X axis (mm)')
    ylabel('Y axis (mm)')
    zlabel('Z axis (mm)')
    axis([1 size(Vq,1) 1 size(Vq,2) 1 size(Vq,3)]);         % applying axis properties
    daspect([1 1 1/res])
    grid on
    drawnow
end

end



