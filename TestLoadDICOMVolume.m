% Simple test scipt for LoadDICOMVolume

% First test using default setting (all of the images in a folder)
V = LoadDICOMVolume();

fprintf('Voxel dimensions: %.3f x %.3f x %.3f mm \n', V.VoxelDimensions);

% Display volume slices in sequence
for n = 1:size(V.ImageData,3)
    I = squeeze(V.ImageData(:,:,n));
    imshow(I,[]);
    title(num2str(n));
    pause(0.1)
      % Wait 1 second
end

% Now test using the range z = 34.8 to 60.1 mm

V = LoadDICOMVolume([34.8, 60.1]);

fprintf('Voxel dimensions: %.3f x %.3f x %.3f mm \n', V.VoxelDimensions);

% Display volume slices in sequence
for n = 1:size(V.ImageData,3)
    I = squeeze(V.ImageData(:,:,n));
    imshow(I,[]);
    title(num2str(n));
    pause(0.1)
         % Wait 1 second
end