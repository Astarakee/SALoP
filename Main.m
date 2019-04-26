% --------------Size Aware Longitudinal Pattern (SALoP) -------------------
% -------------------------------------------------------------------------
% DESCRIPTION: 
% This code subdivides a tumor mass into several concentric subregions 
% outwardly. Then for each subregion, it computes its average intensity.
% -------------------------------------------------------------------------
% INPUTS:
% - Preprocessed and segmented tumors in ".mat" fileformat.
% Put your ".mat" files in "./Data" folder and once you run the code
% you are asked to select all the ".mat" files from "./Data" folder.
% The ".mat" file is a tensor(volumetric image) with zero voxel values
% outside of the tumor location and gray values inside the tumors.
%
% - Requested User Input1:  A floating or integer specifying voxel spatial 
% resolution. e.g. 0.8 or 1.2 in millimeter scale.
%
% - Requested User Input2: A floating or integer specifying the radius of
% each of the concentric subregions. In the original paper it was set as
% 0.5 in CM scale.
% -------------------------------------------------------------------------
% OUTPUTS:
%
% - Raw_Results: An Excel file containing "DataName", "Voxel Resolution",
% "Num of the subregions" and "average intensity values at each subregion".
%
% - Padded_Results1: An Excel file containing "DataName" and padded average
%   subregion intensities of each case to make them in equal size by
%   repeating the average intensity of the outermost layers.        
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

clc
clear
close all

% --------------------------- Reading Files -------------------------------
MainFolder = cd ;
str1 = [MainFolder,'/Data'] ;
str2 = [MainFolder,'/Functions'] ;
addpath(genpath(str1)) ;
addpath(genpath(str2)) ;
[FileName,PathName] = uigetfile('*.mat;','Pick a file','multiselect','on');
input_file = fullfile(PathName,FileName);
ShowResult =0;

% ------------------------- Parameters by User ----------------------------
prompt1 = 'What is the voxel spatial resolution? ';
Vox_Res = input(prompt1);    % e.g: 0.8 mm

prompt2 = 'What is the radius of concentric zones in cm? ';
Rad_Zones = input(prompt2);  % original paper: 0.5 cm.

% --------------------------- Parameters ----------------------------------
if iscell(FileName)
    NumData = length(FileName);
elseif FileName == 0
    NumData = 0;
else
    NumData = 1;
end

% -------------- ------------- Processing ----------------------------------
NumDivide = zeros(NumData,1);
PS = ones(NumData,1);
PS = PS*Vox_Res ;
MaxBinNum = 0;
BinIntStruct = struct('DataName','','PixelSize','','SubRegionNum','','BinIntensity','');
for i = 1:NumData
    if NumData == 1
        FilePath = input_file;
    else
        FilePath = input_file{i};
    end
    Data = importdata(FilePath);
    NumDivide(i) = DivNumCalc2fcn(Data,PS(i), Rad_Zones, ShowResult);
    if NumDivide(i) > MaxBinNum
        MaxBinNum = NumDivide(i);
    end
    DMI = DistMapIntensity2(Data,NumDivide(i));
%     if i == 1
%         BinIntensity = zeros(NumData, length(DMI));
%     end
    BinIntStruct(i).DataName = FilePath;
    BinIntStruct(i).PixelSize = PS(i);
    BinIntStruct(i).SubRegionNum = NumDivide(i);
    BinIntStruct(i).BinIntensity = DMI;
end


BinIntensityVec = zeros(NumData,MaxBinNum);
for j = 1:NumData
    ND = BinIntStruct(j).SubRegionNum;
    DMI = BinIntStruct(j).BinIntensity;
    BinIntensityVec(j,1:ND) = DMI;
    BinIntensityVec(j,ND+1:end) = DMI(end);
end


Padded_Results = struct('DataName',{},'BinIntensity_Padded',{});
for ind = 1:NumData
    if NumData == 1
        FilePath = input_file;
    else
        FilePath = input_file{ind};
    end
    Padded_Results(ind).DataName = FilePath;
    Padded_Results(ind).BinIntensity_Padded = BinIntensityVec(ind,:);
end


writetable(struct2table(BinIntStruct),'Raw_Results.xlsx');
writetable(struct2table(Padded_Results),'Padded_Results.xlsx');

