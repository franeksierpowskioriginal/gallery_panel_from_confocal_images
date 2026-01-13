macro "ImageRepresentify" {

#@ File (label="Select Input Directory with czi files", style="directory") dir
#@ File (label="Select Output Directory", style="directory") outdir
#@ String (visibility=MESSAGE, value="Check the channel number in the original image", required=false) msg1
#@ String (label="Number of red channel", min=1, max=5, value=1) red_number_raw
#@ String (label="Number of green channel", min=1, max=5, value=1) green_number_raw
#@ String (label="Number of cyan channel", min=1, max=5, value=1) cyan_number_raw
#@ String (label="Number of yellow channel", min=1, max=5, value=1) yellow_number_raw
#@ Integer (label="Number of montage combinations", style="spinner", min=0, max=100, stepSize=1) montage_number
#@ Boolean (label="Save files in seperate folders for each sample", value = true, persist = false) create_new_folders

// Define arrays to store settings for each montage
is_red_merged = newArray(montage_number);
is_green_merged = newArray(montage_number);
is_yellow_merged = newArray(montage_number);
is_cyan_merged = newArray(montage_number);

is_red = newArray(montage_number);
is_green = newArray(montage_number);
is_yellow = newArray(montage_number);
is_cyan = newArray(montage_number);
is_merged = newArray(montage_number);

order_red = newArray(montage_number);
order_green = newArray(montage_number);
order_yellow = newArray(montage_number);
order_cyan = newArray(montage_number);
order_merged = newArray(montage_number);

for (i = 0; i < montage_number; i++) {
    Dialog.create("Montage Settings for Combination " + (i+1));
    Dialog.addMessage("Select channels to be merged");
    Dialog.addCheckbox("Red", true);
    Dialog.addCheckbox("Green", true);
    Dialog.addCheckbox("Yellow", true);
    Dialog.addCheckbox("Cyan", true);
    
    Dialog.addMessage("Select channels for the representative image");
    Dialog.addCheckbox("Red", true);
    Dialog.addCheckbox("Green", true);
    Dialog.addCheckbox("Yellow", true);
    Dialog.addCheckbox("Cyan", true);
    Dialog.addCheckbox("Merged", true);
    
    Dialog.addMessage("Channels' order in the montage (leave 0 if the channel is not supposed to be on the montage)");
    Dialog.addSlider("Order Red", 0, 5, 0);
    Dialog.addSlider("Order Green", 0, 5, 0);
    Dialog.addSlider("Order Yellow", 0, 5, 0);
    Dialog.addSlider("Order Cyan", 0, 5, 0);
    Dialog.addSlider("Order Merged", 0, 5, 0);
    
    Dialog.show();
    
    // Save the values uniquely for each montage
    is_red_merged[i] = Dialog.getCheckbox();
    is_green_merged[i] = Dialog.getCheckbox();
    is_yellow_merged[i] = Dialog.getCheckbox();
    is_cyan_merged[i] = Dialog.getCheckbox();
    
    is_red[i] = Dialog.getCheckbox();
    is_green[i] = Dialog.getCheckbox();
    is_yellow[i] = Dialog.getCheckbox();
    is_cyan[i] = Dialog.getCheckbox();
    is_merged[i] = Dialog.getCheckbox();
    
    order_red[i] = Dialog.getNumber();
    order_green[i] = Dialog.getNumber();
    order_yellow[i] = Dialog.getNumber();
    order_cyan[i] = Dialog.getNumber();
    order_merged[i] = Dialog.getNumber();
}

list = getFileList(dir);

// Channel numbers conversion

red_number = "-000"+red_number_raw;
green_number = "-000"+green_number_raw;
yellow_number = "-000"+yellow_number_raw;
cyan_number = "-000"+cyan_number_raw;

//It counts how many images will be on the montage

number_of_images_on_montage  = newArray(montage_number);

for (i = 0; i < montage_number; i++) {
	which_channels_on_image = newArray(is_red[i], is_green[i], is_yellow[i], is_cyan[i], is_merged[i]);
	for (n = 0; n < which_channels_on_image.length; n++) {
		if(which_channels_on_image[n]) number_of_images_on_montage[i]++;
	};
};


number_of_the_biggest_montage = getPositionOfHighestValue(number_of_images_on_montage);



//make sortedValues and order_of_channels arrays
sortedValues = newArray(montage_number * 5);
order_of_channels = newArray(montage_number * 5);


// Assign values to the simulated 2D array
for (i = 0; i < montage_number; i++) {
        j = 0;
        index = getIndex(i, j, 5);
        order_of_channels[index] = order_red[i];
        j = 1;
        index = getIndex(i, j, 5);
        order_of_channels[index] = order_green[i];
        j = 2;
        index = getIndex(i, j, 5);
        order_of_channels[index] = order_yellow[i];
        j = 3;
        index = getIndex(i, j, 5);
        order_of_channels[index] = order_cyan[i];
        j = 4;
        index = getIndex(i, j, 5);
        order_of_channels[index] = order_merged[i];
}

for (i = 0; i < montage_number; i++) {
order = newArray(order_red[i], order_green[i], order_yellow[i], order_cyan[i], order_merged[i]);
sortValues = Array.copy(order);
Array.sort(sortValues);
	for (j = 0; j < sortValues.length; j++) {
		index = getIndex(i, j, 5);
        sortedValues[index] = sortValues[j];
	}
}

open_red = atLeastOneTrue(is_red);
open_green = atLeastOneTrue(is_green);
open_yellow = atLeastOneTrue(is_yellow);
open_cyan = atLeastOneTrue(is_cyan);

for (i = 0; i < list.length; i++){
	processImage(dir,list[i]);
};

function atLeastOneTrue(array) {
    for (i = 0; i < array.length; i++) {
        if (array[i]) {
            return true;
        }
    }
    return false;
}

function getPositionOfHighestValue(array) {
    // Initialize variables to track the highest value and its position
    maxVal = 0;
    maxPos = 0;
    
    // Loop through the array to find the highest value and its position
    for (i = 0; i < array.length; i++) {
        if (array[i] > maxVal) {
            maxVal = array[i];
            maxPos = i;
        }
    }
    
    // Return the position of the highest value
    return maxPos;
}



function getIndex(row, col, numCols) {
    return row * numCols + col;
}



function processImage(dir, image){
	
	if(create_new_folders){ 
		name = File.getNameWithoutExtension(dir+"\\"+list[i]);
		folder2 = outdir + "\\" + name;
		File.makeDirectory(folder2);
	} else{
		folder2=outdir;
		}
	
	open(dir+"\\"+list[i]);
	name = File.getNameWithoutExtension(dir+"\\"+list[i]);
	waitForUser("Check, if you want to cut in z.");
	choice = getBoolean("Do you want to cut the slices?"); 
	if (choice == true) {
    	startSlice = getNumber("Start slice:", 1);
    	stopSlice = getNumber("Stop slice:", nSlices/4);
    	run("Z Project...", "start="+ startSlice +" stop="+ stopSlice +" projection=[Max Intensity]");
	} else {
    	run("Z Project...", "projection=[Max Intensity]");
	}
	waitForUser("Crop the image if needed.");
	run("Stack to Images");
	red = "MAX_"+name+red_number;
	green = "MAX_"+name+green_number;
	yellow = "MAX_"+name+yellow_number;
	cyan = "MAX_"+name+cyan_number;
	
	//Improving images by a user
	if(open_red) {
		selectWindow(red);
		run("Red");
		waitForUser("Manually adjust the brightness and contrast of the red channel");
	}
	
	if(open_green) {
		selectWindow(green);
		run("Green");
		waitForUser("Manually adjust the brightness and contrast of the green channel");
	}
	
	if(open_yellow) {
		selectWindow(yellow);
		run("Yellow");
		waitForUser("Manually adjust the brightness and contrast of the yellow channel");
	}
	
	if(open_cyan) {
		selectWindow(cyan);
		setCyan();
		waitForUser("Manually adjust the brightness and contrast of the cyan channel");
	}
	
	
	
	//Merging selected images
	for (i = 0; i < montage_number; i++) {
	merge_red = "";
	merge_green = "";
	merge_cyan = "";
	merge_yellow = "";
	if(is_red_merged[i]) merge_red = "c1=&red ";
	if(is_green_merged[i]) merge_green = "c2=&green ";
	if(is_yellow_merged[i]) merge_yellow = "c7=&yellow ";
	if(is_cyan_merged[i]) merge_cyan = "c5=&cyan "; 
	run("Merge Channels...", merge_red+merge_green+merge_yellow+merge_cyan+"create keep");
	run("Flatten");
	saveAs("Tiff", folder2+"\\"+name+"_Composite_"+i+".tif");
	saveAs("PNG", folder2+"\\"+name+"_Composite_"+i+".png");
	close();
	}
	
	//Saving the files
	if(open_red){
	selectWindow(red);
	saveAs("Tiff", folder2+"\\"+name+red_number+".tif");
	saveAs("PNG", folder2+"\\"+name+red_number+".png");
	}
	if(open_green){
	selectWindow(green);
	saveAs("Tiff", folder2+"\\"+name+green_number+".tif");
	saveAs("PNG", folder2+"\\"+name+green_number+".png");
	}
	if(open_cyan){
	selectWindow(cyan);
	saveAs("Tiff", folder2+"\\"+name+cyan_number+".tif");
	saveAs("PNG", folder2+"\\"+name+cyan_number+".png");
	}
	if(open_yellow){
	selectWindow(yellow);
	saveAs("Tiff", folder2+"\\"+name+yellow_number+".tif");
	saveAs("PNG", folder2+"\\"+name+yellow_number+".png");
	}
	run("Close All");
	scale_width = getNumber("Width of the scale bare [um]:", 20);
	
	//Opening the images for the montage
	for (i = 0; i < montage_number; i++) {
		for (j = 0; j < 5; j++){
			index = getIndex(i, j, 5);
			index2 = getIndex(i, 0, 5);
			if_red = sortedValues[index] == order_of_channels[index2];
			
			index2 = getIndex(i, 1, 5);
			if_green = sortedValues[index] == order_of_channels[index2];
			
			index2 = getIndex(i, 2, 5);
			if_yellow = sortedValues[index] == order_of_channels[index2];
			
			index2 = getIndex(i, 3, 5);
			if_cyan = sortedValues[index] == order_of_channels[index2];
			
			index2 = getIndex(i, 4, 5);
			if_merged = sortedValues[index] == order_of_channels[index2];
			
			if(if_red && is_red[i]) open(folder2+"\\"+name+red_number+".tif");
			if(if_green && is_green[i]) open(folder2+"\\"+name+green_number+".tif");
			if(if_yellow && is_yellow[i])open(folder2+"\\"+name+yellow_number+".tif");
			if(if_cyan && is_cyan[i]) open(folder2+"\\"+name+cyan_number+".tif");
			if(if_merged && is_merged[i]) open(folder2+"\\"+name+"_Composite_"+i+".tif");
		}
			run("Images to Stack", "use");
			counter = number_of_images_on_montage[i];
			run("Make Montage...", "columns=&counter rows=1 scale=1");
			run("Scale Bar...", "width=" + scale_width + " height=25 thickness=10 font=56 color=White background=None location=[Lower Right] horizontal bold overlay");
			run("Flatten");
			saveAs("Tiff", folder2+"\\"+name+"-montage_"+i+".tif");
			saveAs("PNG", folder2+"\\"+name+"-montage_"+i+".png");
			run("Close All");
	}
}


function setCyan() {
    reds = newArray(256); 
	greens = newArray(0,0,1,1,2,3,3,4,5,5,6,6,7,8,8,9,10,10,11,11,12,13,13,14,15,15,16,16,17,18,18,19,20,20,21,22,22,23,23,24,25,25,26,27,27,28,28,29,30,30,31,32,32,33,33,34,35,35,36,37,37,38,38,39,40,40,41,42,42,43,44,44,45,45,46,47,47,48,49,49,50,50,51,52,52,53,54,54,55,55,56,57,57,58,59,59,60,61,61,62,62,63,64,64,65,66,66,67,67,68,69,69,70,71,71,72,72,73,74,74,75,76,76,77,77,78,79,79,80,81,81,82,83,83,84,84,85,86,86,87,88,88,89,89,90,91,91,92,93,93,94,94,95,96,96,97,98,98,99,99,100,101,101,102,103,103,104,105,105,106,106,107,108,108,109,110,110,111,111,112,113,113,114,115,115,116,116,117,118,118,119,120,120,121,122,122,123,123,124,125,125,126,127,127,128,128,129,130,130,131,132,132,133,133,134,135,135,136,137,137,138,138,139,140,140,141,142,142,143,144,144,145,145,146,147,147,148,149,149,150,150,151,152,152,153,154,154,155,155,156,157,157,158,159,159,160);
	blues = newArray(0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254);

    setLut(reds, greens, blues);
}
}
