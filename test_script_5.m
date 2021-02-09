clear all
close all
clc


DICOMFolder=uigetdir('select directory contains DICOM files');      % asking uder to select the director for DICOM files
DICOMVolume = LoadDICOMVolume([1 200], DICOMFolder);                % calling function to load volume of dicom files in the folder
disp(' ')

gamma_x=2;
gamma_y=2;
gamma_z=2;

voxel_dimentions=DICOMVolume.VoxelDimensions;                       % extracting voxel dimensions
dim=[min(voxel_dimentions) max(voxel_dimentions) max(voxel_dimentions)*4];  % defining pixel dimentions for slicing
voxel_dimentions=DICOMVolume.VoxelDimensions;                               % extracting voxel dimensions
algo='linear';                                                              % defining interpolation methods to run using loop

for plane=1:3
        I=ComputeOrthogonalSlice_updated(algo,1,DICOMVolume,100,plane,0);
       
        I_blur=BlurSlices(I,gamma_x,gamma_y,gamma_z,plane);
        figure
        subplot(1,2,1)
        imshow(I,[]);
        title('Raw slice')
        subplot(1,2,2)
        imshow(I_blur,[]);
        title('Gaussian')
        drawnow
end

