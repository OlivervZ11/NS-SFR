# Natural Scene Derived Spatial Frequency Response – MATLAB Code
By Oliver van Zwanenberg, Sophie Triantaphillidou, Alexandra Psarrou and Robin B. Jenkin
School of Computer Science and Engineering, The University of Westminster, UK 

# Introduction
The Natural Scene derived Spatial Frequency Response (NS-SFR) framework automatically extracts suitable step-edges from natural pictorial scenes and processes these edges via the slanted edge algorithm. This data is then used to estimate the system e-SFR (measured using the BSI ISO12233). This MATLAB code provides both parts of this proposed methodology and a MATLAB app to plot the results.

For further detail, please see:

O. van Zwanenberg, S. Triantaphillidou, R. B. Jenkin, and A. Psarrou, “Estimation of ISO12233 Edge Spatial Frequency Response from Natural Scene Derived Step-Edge Data” Journal of Imaging Science and Technology (JIST), Symposium Electronic Imaging (EI), 2022. 

O. van Zwanenberg, S. Triantaphillidou, R. B. Jenkin, and A. Psarrou, “Analysis of Natural Scene Derived Spatial Frequency Responses for Estimating Camera ISO12233 Slanted-Edge Performance” Journal of Imaging Science and Technology (JIST), Symposium Electronic Imaging (EI), 2022.  

O. van Zwanenberg, S. Triantaphillidou, R. B. Jenkin, and A. Psarrou, “Natural Scene Derived Camera Edge Spatial Frequency Response for Autonomous Vision Systems” IS&T/IoP London Imaging Meeting, 2021.  

O. van Zwanenberg, S. Triantaphillidou, R. B. Jenkin, and A. Psarrou, “Camera System Performance Derived from Natural Scenes” IS&T International Symposium on Electronic Imaging: Image Quality and System Performance XVII: Displaying, Processing, Hardcopy, and Applications, 2020.

O. van Zwanenberg, S. Triantaphillidou, R. B. Jenkin, and A. Psarrou, “Edge Detection Techniques for Quantifying Spatial Imaging System Performance and Image Quality”, IEEE: New Trends in Image Restoration and Enhancement (NTIRE) workshop, in conjunction with Conference on Computer Vision and Pattern Recognition (CVPR), 2019.

# Requirements
MATLAB and the following MATLAB Toolboxes:
•	Image Processing Toolbox
•	Parallel Computing Toolbox
•	Statistics and Machine Learning Toolbox

# SFRMAT4
Sfrmat4 was written by P. D. Burns and is available at [1]. Throughout the provided MATLAB code, ‘sfrmat4.m’ is used to measure the e-SFR via the slanted edge method. Minor adjustments were made to the code to output edge angle, contrast and whether clipping is present. Also, error flags are placed in the code to catch and deselect unsuitable natural scene step-edges. 

# Guide
* 1. Part 1 – The NS-SFR extraction: *

Running ‘Pt1_NSSFR_Extraction.m’ isolates step edges from a dataset of images. Before running the code, ensure the image dataset is stored in a folder and that all images are taken with the same camera system, lens, and aperture. 

When initialising the code, you will first be prompted to state whether the dataset is either RAW or TIFF image format (see Figure 1). The TIFF format is a standard .tif file, whilst the RAW must be a .dng. The provided DNG image reader (imreadDNG.m) is based on reading a converted Nikon NEF RAW file [2]; therefore, the DNG image reader may need to be modified depending on the camera model used to capture the dataset.





