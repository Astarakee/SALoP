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
% 



function BinIntensity = DistMapIntensity2(Data,NumDivide)
% This funciton calculates the average intensity inside arbitrary number of regions
% by using a distance map inside the target tumors.
% Inputs:
% Data: 3D matrix; background set to zero with gray values inside the target
% NumDivide: the number of desired sub-regions
% Output:
% BinIntensity: the average intensity inside each subregion.

Im = zeros(size(Data));
Im(Data == 0) = 1;

DistMap = bwdist(Im); % finding the distances from the target borders
MaxDist = max(DistMap(:));
DistMap = double(DistMap./MaxDist); % normalizing the distances
Distances = unique(DistMap(:));
Distances(1) = []; % remove the background values(0)

Ncount = histc(DistMap(:), Distances); % number of each pixel with specific distance
L = length(Ncount);
Div = floor(L/NumDivide);
MeanIntensity = zeros(L,1);
for i = 1:L                       % Calculating average intensity for each distance
    SumIntensity = mean(Data(DistMap == Distances(i)));
    MeanIntensity(i) = SumIntensity;
end

% Grouping the distances(avergaes) based on the number of sub-regions
BinIntensity = zeros(NumDivide,1);
for j = 1:max(1,NumDivide)
    if j ~= max(1,NumDivide)
        Bins = MeanIntensity(((j-1)*Div)+1:Div*j);
    else
        Bins = MeanIntensity(((j-1)*Div)+1:end);
    end
    BinIntensity(j) = sum(Bins)/length(Bins);
end



