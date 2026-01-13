# gallery_panel_from_confocal_images
The ImageJ macro batch-processes CZI files (Zeiss format) from confocal microscopy experiments, creating publication-ready montages that combine multiple fluorescence channels (red, green, cyan and yellow) and their merged composites.

The macro takes: 
1) an input directory containing CZI files,
2) an output directory in which the processed images will be saved,
3) channel numbers (to be checked before running the macro),
4) the number of montage layouts.

For each montage, the user can then decide which channels to merge and which to display individually, as well as the order of the images in the panel. The macro includes manual brightness/contrast adjustment, Z-slice and XY cropping per image as interactive steps. This macro significantly reduces processing time while maintaining researcher control over brightness, contrast and Z-projection.


