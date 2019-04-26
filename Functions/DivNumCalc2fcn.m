% --------------Size Aware Longitudinal Pattern (SALoP) -------------------
% -------------------------------------------------------------------------
% DESCRIPTION: 
% This code subdivides a tumor mass into several concentric subregions 
% outwardly. Then for each subregion, it computes its average intensity.
% -------------------------------------------------------------------------
% INPUTS:
% - Preprocessed and segmented tumors in .mat fileformat.
% Put your .mat files in "./Data" folder and once you run the code
% you are asked to select all the .mat files from "./Data" folder.
% The .mat file is a tensor(volumetric image) with zero voxel values
% outside of the tumor locations. i
% - Requested User Input1:  A floating or integer specifying voxel spatial 
% resolution. e.g. 0.8 or 1.2 in millimeter scale.
% - Requested User Input2: A floating or integer specifying the radius of
% each of the concentric subregions. In the original paper it was set as
% 0.5 in CM scale.
% -------------------------------------------------------------------------
% OUTPUTS:
% - Raw_Results: An Excel file containing "DataName", "Voxel Resolution",
% "Num of the subregions" and "average intensity values at each subregion".
% - Padded_Results1: An Excel file containing "DataName" and padded average
% subregion intensities of each case to make them in equal size by
% repeating the average intensity of the outermost layers.        
% -------------------------------------------------------------------------
% AUTHOR: 
%  - Mehdi Astaraki <mehast@kth.se>
% -------------------------------------------------------------------------
% HISTORY:
% - Creation: July 2018
% - Revision: XXX
% -------------------------------------------------------------------------
% STATEMENT:
% This code contains a part of my recent study which is about imaging 
% biomarkers for cancer treatment outcome assessment.
% 
% This code is a free software: you can redistribute it and in case of
% academic publication it is expected to refer to our study:
%   "Early survival prediction in non-small cell lung cancer from PET/CT
%    images using an intra-tumor partitioning method"   
%   "https://doi.org/10.1016/j.ejmp.2019.03.024"
%
% -------------------------------------------------------------------------

function [NumDivide,DataBin] = DivNumCalc2fcn(DataOrig, PS, Rad_Zones, ShowResult)

DataBin = zeros(size(DataOrig));

% Data = DataOrig;

Data = (imbinarize(DataOrig));

ShowMaxDistSlices = 0;
[MaxDiameter, MaxDSlice] = MaxDiameter2Dfcn(Data, ShowMaxDistSlices);


Data = bwdist(~Data);
DMax = max(Data(:));
DMin = min(Data(:));

Rad_Zones = 10*Rad_Zones ;       % Converting from cm scale to mm.
Rad_Zones = -Rad_Zones ;         % Vectoring the elements decrementally.
DScale = (PS*MaxDiameter/2):Rad_Zones:0;
if (DScale(end) ~= 0)
    DScale(end+1) = 0;
end

NumDivide = length(DScale) - 1;
for i = 1:NumDivide
    ds1 = DScale(i);
    ds2 = DScale(i+1);
    DataBin((Data <= ds1) & (Data > ds2)) = i;
end
% DataBin(Data == DScale(end)) = NumDivide;
if ShowResult == 1
    figure(1)
    DataCon = cat(2,Data,DataBin);
    imshow3D(DataCon);
    pause;
end

% fv = isosurface(data,.5);
% p1 = patch(fv,'FaceColor','red','EdgeColor','none');
% view(3)
% daspect([1,1,1])
% axis tight
% camlight
% camlight(-80,-10)
% lighting gouraud