# SALoP
This repository contains an implementation of Size Aware Longitudinal Pattern (SALoP) that introduced in https://doi.org/10.1016/j.ejmp.2019.03.024 .
As describe in the paper, the purpose of SALoP feature set has been to design a quantitative physiologically meaningful feature set to capute tumor characteristics from
medical images. This feature set could be used for the prediction of early tumor response to the treatment. 
This feature set partitions a solid tumor mass into separate concentric subregions and for each of the subregions, it computes the average 
intensity inside that subregion.
Run the code as follows:
1) Put all the tensor of segmented tumors (zero background and gray values inside the tumor region) as a ".mat" file in "./Data" folder.
2) Run Main.m and set two requested parameters: a) a floating or integer value for voxel resolution and b) a floating or integer value for 
the desired radius of concentric subregions (in the original paper it was set to 0.5 cm).
