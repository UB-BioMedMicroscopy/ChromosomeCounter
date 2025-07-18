
/*
Advanced Optical Microscopy Unit
Scientific and Technological Centers. Cl�nic Campus
University of Barcelona
C/ Casanova 143
Barcelona 08036 
Tel: 34 934037159
Fax: 34 934024484
mail: confomed@ccit.ub.edu
------------------------------------------------
Authors: Gemma Martin, Maria Calvo.
------------------------------------------------

Macro name: 219_CHR_counter_v2.ijm

Date: 06/02/2024

INPUT: Folder with .lif microscopy image files  
OUTPUT:   	- Text files summarizing chromosome counts and comments per image series  
  			-	 ROIs saved in the ROI Manager during processing 

Tested with Fiji/ImageJ version 1.54p

*/


// Set 3D Object Counter options (optional, used if 3D analysis is required)
run("3D OC Options", "volume surface nb_of_obj._voxels nb_of_surf._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value centroid mean_distance_to_surface std_dev_distance_to_surface median_distance_to_surface centre_of_mass bounding_box dots_size=5 font_size=10 redirect_to=none");

// Clean previous results
if(isOpen("Results")){
    IJ.deleteRows(0, nResults);
}

// Open and reset ROI Manager
run("ROI Manager...");
roiManager("reset"); //to delete previous ROIs
IJ.deleteRows(0, nResults); // Double check result table is empty

// Ask user to choose the folder containing input images
dir = getDirectory("Choose images folder");
list=getFileList(dir);

// Create a "Results" subfolder to save outputs
dirRes=dir+"Results"+File.separator;
File.makeDirectory(dirRes);

// Open ROI Manager again to ensure it’s available
run("ROI Manager...");

// Set measurement parameters for future use
run("Set Measurements...", "area mean min shape integrated display redirect=None decimal=5");

// Set basic options for the macro
run("Options...", "iterations=1 count=1 do=Nothing");		

// Set white background (for masks and thresholded images)
setBackgroundColor(255, 255, 255);
				
// Loop over each file in the selected folder
for(i=0;i<list.length;i++){
	
	 // Only process .lif files
	if(endsWith(list[i],".lif")){
		
		// Import all series from the LIF file (composite mode, BioFormats)
		run("Bio-Formats Importer", "open=[" + dir + list[i] + "] autoscale color_mode=Composite open_all_series rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		// Store number of image series
		numseries=nImages;
		// Close everything to avoid clutter
		run("Close All");
		// Prepare path for the output summary file of this .lif
		pathimatge=dirRes+list[i]+"Results.txt";
		// Initialize output file with headers
		File.append("Image \t Nº CHR \t comments", pathimatge);	
		// Process each image series within the .lif file
		for (m=1; m<=numseries; m++) {
			// Reopen specific series
			run("Bio-Formats Importer", "open=[" + dir + list[i] + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+m);
			// Store image title and ID	
			t=getTitle();
			ImageID=getImageID();
			
			// Get image metadata (not used later, but could be useful)
			getPixelSize(unit, pixelWidth, pixelHeight);
			getDimensions(width, height, channels, slices, frames);
			
			// Ask user to select the region of interest (manually)
			setTool("rectangle");
			waitForUser("Select the region and click OK");
			
			// Duplicate the selected region for processing
			run("Duplicate...", " ");
			
			// Subtract background (rolling ball algorithm)
			run("Subtract Background...", "rolling=50");
			title=getTitle();
			
			// Duplicate and apply Gaussian blur for segmentation
			run("Duplicate...", " ");
			run("Gaussian Blur...", "sigma=1");
			run("Find Maxima...", "prominence=180 output=[Segmented Particles]");
			rename("segmented");
			
			// Create binary mask using automatic threshold (Otsu method)
			selectImage(title);
			run("Duplicate...", " ");
			
			setAutoThreshold("Otsu dark");
			setOption("BlackBackground", false);
			run("Convert to Mask");
			rename("mask");
			
			// Combine mask and segmented image using minimum operation
			imageCalculator("Min create", "mask","segmented");
			
			 // Analyze particles to detect chromosomes
			run("Analyze Particles...", "size=0-1000 pixel add");
			
			 // Count ROIs (putative chromosomes)
			nCHR=roiManager("count");
		
			// Show result to the user and allow manual correction
			selectImage(title);
			run("Set... ", "zoom=200");
			roiManager("Show All without labels");
		    
		    waitForUser("Check the results. Counted CHR: "+nCHR);
		    
		    // Re-count in case user deleted/added ROIs
		    nCHR=roiManager("count");
		    
		    roiManager("Show None");
		    roiManager("Show All without labels");
		    
		    // Ask user to confirm or correct the final count and add comments
			nCHR=getString("Counted CHR: "+nCHR, nCHR);
			comments=getString("Comments: ", "none");
			
			// Save the result line to output text file
			File.append(t+"\t"+nCHR+"\t"+comments, pathimatge);	
			
			// Close all windows before next image
			closeImagesWindows();

		}
	}
	
}

// Inform user that the macro has finished processing
waitForUser("Macro has finished");

		
// Function to clean up all open windows and avoid memory overload
function closeImagesWindows(){
	run("Close All");
	if(isOpen("Results")){
		selectWindow("Results");
		run("Close");
	}
	if(isOpen("ROI Manager")){
		selectWindow("ROI Manager");
		run("Close");
	}
	if(isOpen("Threshold")){
		selectWindow("Threshold");
		run("Close");
	}
	if(isOpen("Summary")){
		selectWindow("Summary");
		run("Close");
	}
	if(isOpen("B&C")){
		selectWindow("B&C");
		run("Close");
	}
	if(isOpen("Log")){
		selectWindow("Log");
		run("Close");
	}
}
		
