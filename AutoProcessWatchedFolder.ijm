//User Settings
dir1 = getDirectory("Choose Source Directory ");
list = getFileList(dir1);

Dialog.create("INIT");

Dialog.addMessage("Please Configure Running Mode:");
Dialog.addCheckbox("background", false);
//Dialog.addCheckbox("calibrate", false);
Dialog.addCheckbox("Plot FVB", false);
Dialog.addNumber("Contrast Gradient", 1);

Dialog.show();
B = Dialog.getCheckbox();
//C = Dialog.getCheckbox();
P = Dialog.getCheckbox();
G = Dialog.getNumber();


cutoff = floor(256/G);


if (list.length == 0){
	print("Empty folder selected, waiting for image... ");	
	while((list.length == 0) && (isOpen("Log"))){
		wait(1000);
		list = getFileList(dir1);		
		}	
}
else{
	print("folder contains " + list.length + " files" );
};

if(!B){
	print("No Background will be used");
	bkg = 0;
} else {
	bkg = getBack(dir1);
	if((list.length == 1) && ( list[0] == bkg)){
	print("No Images other than background. Awaiting image creation... ");	
	while((list.length == 1) && (isOpen("Log"))){
		wait(1000);
		list = getFileList(dir1);		
		}	
	}
}	

close("*");
list = getFileList(dir1);		

indexOffset = 1; 
if (list[list.length - indexOffset] == bkg){ // background file is naed such that it appears at the end of the list
		indexOffset = 2;
	}
	
open(list[list.length - indexOffset]);
		
tr = 5;
while( (selectionType() < 0) && (tr > 0) && (isOpen("Log")) ){
	tr = tr-1;
	waitForUser("Select ROI then hit ´ok´");
}
if(tr == 0){
	print("No ROI selected");
	x = 1;
	y = 1;
	getDimensions(width, height);;
	}
else{
	getSelectionBounds(x, y, width, height);
	}
	
processImage(cutoff, G, x, y, width, height, bkg);
if(P){
	plotProfilesFromImage();
}
while(isOpen("Log")){
     newList = getFileList(dir1);
     if(newList.length > list.length){
     	print("New file found: updating");
		openNextImage(newList[newList.length - indexOffset]);
		processImage(cutoff, G, x, y, width, height, bkg);
		if(P){
			plotProfilesFromImage();
		}
		};
 	 wait(3000);
   	 list = newList;
    };

function openNextImage(name){
	close("*");
	open(name);
	};

function processImage(cut,grad,x, y, width, height, back){
	makeRectangle(x, y, width, height);
	run("To Selection");
	resetMinAndMax();
	if(!(back == 0)){
		if(isOpen(back)){
			close(back);	
			}
		curID = getImageID();
		open(back);
		backID = getImageID();
		imageCalculator("subtract", curID, backID);
		close(back);
		}
	r = newArray(256);
	g = newArray(256);
	b = newArray(256);
	for(i=0;i<256;i++){
		r[i] = i;
		g[i] = i;
		b[i] = i;
	}
	setLut(r,g,b);
	run("Fire");
	run("Apply LUT");
	getLut(r,g,b);
	r2 = newArray(256);
	g2 = newArray(256);
	b2 = newArray(256);
	for(i=0;i<cut;i++){
		sample = floor(grad*i);
		
		r2[i] = r[sample];
		g2[i] = g[sample];
		b2[i] = b[sample];

		if(256-i > cut){
			r2[255 - i] = 256;
			g2[255 - i] = 256;
			b2[255 - i] = 256;
			}
		}
	setLut(r2,g2,b2);
}

function plotProfilesFromImage(){
	close("Plot *");
	run("Plot Profile");
}

function getBack(dir){
  flist = getFileList(dir);
  guess = flist[0];
  msg = "please enter a file for background or ´none´ (without quotes) to skip using a background ";
  back = getString(msg, guess);
  if( back == "none" ){
  		return 0;
  	}
  else {
		open(back);
		close();
		return back;
  }
}

    