function DICOMVolume = LoadDICOMVolume(z_range, ~)
% LoadDICOMVolume: A function to load a volume from a 3D DICOM
% slices
%
% DICOMVolume = LoadDICOMVolume(z_range, DICOMfolder)
%
% INPUTS:
%   z_range (double vector-array) - a two element vector containing the start 
%     and end slice positions (in mm) in the form [z_min, z_max]
%   DICOMFolder (string) [OPTIONAL] - the location to the folder where the
%     DICOM (.dcm) files are stored
%
% OUTPUTS:
%   DICOMVolume (struct) - a structure with two fields:
%       ImageData (a 3D matrix-array containing the image intensity values) and
%       VoxelDimensions (a three element vector containing the voxel dimensions in mm, for the y, 
%           x and z directions)
%   If an error is encountered, ImageData and VoxelDimensions contain empty
%       arrays
%
% FUNCTION DEPENDENCIES:
%   None
%
% AUTHOR:
%   Anonymous 2017-18; Modified by Dean Barratt 2018

% Initially define DICOMVolume so that both  fields contain empty arrays to ensure that the  function
% returns this if an error is generated as part of the error checking steps below 

DICOMVolume = struct('ImageData', [], 'VoxelDimensions', []);  


% If the DICOMfolder is not provided as an input argument, ask the user to
% select the folder in which the DICOM files are stored
if nargin < 2
    DICOMfolder = uigetdir('~', 'Select Folder');
end

% Check to see if a folder was selected or the cancel button was pressed
if DICOMfolder == 0
    msgbox('Please specify the folder containing the 3D DICOM image', 'Error', 'Error');
    return;
end

% Create a list of all of names of the DICOM files with a .dcm extension using the dir function.
% The files are stores in an M-by-1 structure array where M is the number of files (image slices) 
DICOMfilenames = dir(fullfile(DICOMfolder, '*.dcm'));
M = length(DICOMfilenames);  % Number of DICOM files (image slices)

% Display an error and return if no DICOM files have been detected in the specified folder 
if isempty(DICOMfilenames)
    msgbox('Please select a folder which contains DICOM files', 'Error', 'Error');
    return;
end

% For each DICOM file in the list, access the header information (i.e. metadata) to calculate the
% corresponding image slice position along the z-axis (i.e. axis orthogonal to the slice plane)

[U, V, P] = deal(zeros(3, M));   % U, V, and P are 3-by-M matrix-arrays to store the u,v, and p vectors
                                             % from the DICOM information
                                             % (see lecture notes) 
                                             
                   % info is an 1-by-M struct array that stores the header information for each .dcm file
                                              % (This is used later to rescale the pixel/voxel intensities)

for i = 1:M
    
    fprintf('Loading information for DICOM slice: %s \n' , DICOMfilenames(i).name);
    filepath = fullfile(DICOMfolder, DICOMfilenames(i).name);
    info(i) = dicominfo(filepath);                                                  % Load header information and store in array info
                                                                                             % info is an 1-by-M struct array that stores the header information for each .dcm file
                                                                                             % (This is used later to rescale the pixel/voxel intensities)
                                                            
    U(:, i) = info(i).ImageOrientationPatient(1:3);
    V(:, i) = info(i).ImageOrientationPatient(4:6);
    P(:, i) = info(i).ImagePositionPatient;
    
end

Z = dot(P, cross(U, V), 1);  % Calculate all of the z positions in one operation and store in Z (Z is a 1-by-M matrix-array)

% Now check to see if the range of Z values provided are valid for the selected
% DICOM image volume.


min_z = min(Z); max_z = max(Z);                          % Minimum and maximum calculated z values

if (nargin == 0) | isempty(z_range)                    % If no range of values are specified as inputs then use the full range of z
    z_range = [min_z,  max_z];
end

z_min = z_range(1); z_max = z_range(2);         % Minimum and maximum z values specified by user (or default values)

if (z_min < min_z) | (z_max > max_z)               % If the specified values of z_min and z_max are outside the full range [min_z, max_z]
                                                                      % then return after displaying an error message
    msgbox(sprintf('Range of Z values provided are invalid for the selected data set.\nZ values must be between %.2f and %.2f.',...
        [min_z max_z]), 'Error', 'Error');
    return;
end

% Sort the z values stored in Z
[sortedZ, sort_index] = sort(Z);   % index now stores how the indices of the z values in Z are re-ordered when sorted in ascending order

% Check for non-uniform slice spacing in the z-direction (i.e. the distance between consecutive z values is not constant)
if ~isempty( find(diff(diff( sortedZ )) > 0.001) )   % True if the slice spacing is not uniform within a tolerance of 0.001 mm
                                                                       % (i.e. the difference in the distances between consecutive slices can differ by no more than
                                                                       % 0.001).
                                                                       % A simpler solution is to check if these distances are exactly the same. However,
                                                                       % as explained in the lectures, small numerical errors should be taken into acount

        % Display a warning if non-uniform slice spacing is detected
        msgbox(sprint('The spacing between slices is non-uniform. \n The mean slice spacing will be used'), 'Warning', 'warn');                                   
end

if length(sortedZ) > 1
    voxdim_z = mean(diff(sortedZ));   % Calculate voxel dimension in the z direction if there are 2 or more slice
                                                     % Note: here the mean value is calculated, which is equal to inter-slice spacing for
                                                     % uniformly spaced slices.          
else
    voxdim_z = 0;                             % Set voxel dimension to zero if there is only one slice (i.e. a 2D image)
end
    
i_zsort_range = find(sortedZ >=z_min) : find(sortedZ<=z_max, 1, 'last'); % Indices of sorted z positions that lie within the specified range, z_range = [z_min, z_max] 

% Create the output structure (assuming that the within-plane pixel slicing is the same for all slices, which should be the case)

DICOMVolume.VoxelDimensions = [info(1).PixelSpacing(1), info(1).PixelSpacing(2), voxdim_z];   % Set voxel dimensions
DICOMVolume.ImageData = zeros(info(1).Height, info(1).Width, length(i_zsort_range) );  % Initialise ImageData to zeros

k = 1;  % k is a counter that corresponds to the third dimension index for DICOMVolume. Initialise to 1 for the first DICOM slice.
for i = i_zsort_range
    fprintf( 'Loading DICOM slice: %s at position z = %.3f mm \n' , DICOMfilenames(sort_index(i)).name, sortedZ(i) );
    I = dicomread(info(sort_index(i)));     % Read DICOM image data     
    
    % Calculate the original pixel values using rescaling (see lecture notes)
    DICOMVolume.ImageData(:,:,k) = info(sort_index(i)).RescaleSlope*double(I) + info(sort_index(i)).RescaleIntercept;
    k = k+1;   % Increase counter by one for next slice
end

end