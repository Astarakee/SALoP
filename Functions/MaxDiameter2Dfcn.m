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

function [MaxDiameter,MaxDSlice] = MaxDiameter2Dfcn(Data, ShowResult)

[rows, columns, height] = size(Data);


MaxDiameter = 0;
for tt = 1:size(Data,3)
    binaryImage = imfill(Data(:,:,tt),'holes');
    
    labeledImage = bwlabel(binaryImage);
    % Measure the area
    measurements = regionprops(labeledImage, 'Area');
    
    
    boundaries = bwboundaries(binaryImage);
    numberOfBoundaries = size(boundaries, 1);
    for blobIndex = 1 : numberOfBoundaries
        thisBoundary = boundaries{blobIndex};
        x = thisBoundary(:, 2); % x = columns.
        y = thisBoundary(:, 1); % y = rows.
        
        % Find which two boundary points are farthest from each other.
        maxDistance = -inf;
        for k = 1 : length(x)
            distances = sqrt( (x(k) - x) .^ 2 + (y(k) - y) .^ 2 );
            [thisMaxDistance, indexOfMaxDistance] = max(distances);
            if thisMaxDistance > maxDistance
                maxDistance = thisMaxDistance;
                index1 = k;
                index2 = indexOfMaxDistance;
            end
        end
        
        if MaxDiameter < maxDistance
            MaxDiameter = maxDistance;
            MaxDSlice = tt;
        end
        
        
        if (ShowResult == 1)
            % Find the midpoint of the line.
            xMidPoint = mean([x(index1), x(index2)]);
            yMidPoint = mean([y(index1), y(index2)]);
            longSlope = (y(index1) - y(index2)) / (x(index1) - x(index2));
            if isinf(longSlope) | isnan(longSlope)
                perpendicularSlope = 0;
            else
                perpendicularSlope = -1/longSlope;
            end
            % Use point slope formula (y-ym) = slopedt points
            y1 = perpendicularSlope * (1 - xMidPoint) + yMidPoint;
            y2 = perpendicularSlope * (columns - xMidPoint) + yMidPoint;
            
            % Get the profile perpendicular to the midpoint so we can find out when if first enters and last leaves the object.
            if ~isinf(y1) & ~isinf(y2)
                [cx,cy,c] = improfile(binaryImage,[1, columns], [y1, y2], 1000);
                
                
                % Get rid of NAN's that occur when the line's endpoints go above or below the image.
                c(isnan(c)) = 0;
                firstIndex = find(c, 1, 'first');
                lastIndex = find(c, 1, 'last');
                
                % Compute the distance of that perpendicular width.
                perpendicularWidth = sqrt( (cx(firstIndex) - cx(lastIndex)) .^ 2 + (cy(firstIndex) - cy(lastIndex)) .^ 2 );
                % Get the average perpendicular width.  This will approximately be the area divided by the longest length.
                averageWidth = measurements(blobIndex).Area / maxDistance;
                
                
                hFig = figure(10);
                imshow(binaryImage, []);
                axis on;
                hold on;
                
                % Plot the boundary over the binary image
                plot(x, y, 'y-', 'LineWidth', 3);
                % For this blob, put a line between the points farthest away from each other.
                line([x(index1), x(index2)], [y(index1), y(index2)], 'Color', 'r', 'LineWidth', 3);
                plot(xMidPoint, yMidPoint, 'r*', 'MarkerSize', 15, 'LineWidth', 2);
                % Plot perpendicular line.  Make it green across the whole image but magenta inside the blob.
                line([1, columns], [y1, y2], 'Color', 'g', 'LineWidth', 3);
                line([cx(firstIndex), cx(lastIndex)], [cy(firstIndex), cy(lastIndex)], 'Color', 'm', 'LineWidth', 3);
                
                message = sprintf('The longest line is red.\nPerpendicular to that, at the midpoint, is green.\nMax distance for blob #%d = %.2f\nPerpendicular distance at midpoint = %.2f\nAverage perpendicular width = %.2f (approximately\nArea = %d', ...
                    blobIndex, maxDistance, perpendicularWidth, averageWidth, measurements(blobIndex).Area);
                fprintf('%s\n', message);
                pause;
            end
        end
    end
    
end