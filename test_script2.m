clear all
close all
clc


DICOMFolder=uigetdir('select directory contains DICOM files');      % asking uder to select the director for DICOM files
DICOMVolume = LoadDICOMVolume([1 200], DICOMFolder);                % calling function to load volume of dicom files in the folder
disp(' ')

voxel_dimentions=DICOMVolume.VoxelDimensions;                       % extracting voxel dimensions
dim=[min(voxel_dimentions) max(voxel_dimentions) max(voxel_dimentions)*4];  % defining pixel dimentions for slicing
algo={'linear','cubic','spline'};                             % defining interpolation methods to run using loop
for i=1:length(algo)                                                % loop to run for all interpolation methods
    for j=1:length(dim)                                             % loop to run for all pixel dimensions
        disp(strcat('computing for:','interpolation:[',algo{i},'] pixel dimensions:[',num2str(dim(j)),'x',num2str(dim(j)),']'))
        ComputeOrthogonalSlice(algo{i},dim(j),DICOMVolume)          % calling function to slice and show in figure
    end
end