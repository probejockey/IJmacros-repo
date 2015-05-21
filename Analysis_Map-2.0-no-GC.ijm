//Copyright Glenn Poirier (2013)
//Not responsible for any lost data - If you screw up don't come crying to me
//
//Given a directory containing analysis location images (BMP's) and one or more text files containing stage conditions (text output files from the 
// summary program, this script annotates the location images with the applicable analyses (commnet or number)
//The script produces TIFF files and will overwrite previous files without asking (the original BMP's are preserved)
//contact glennpoirier@gmail.com with questions or suggestions
//
//V1.00 August 9th, 2013
//V1.01 August 15th, 2013 - Added ability to use a dot as a marker
//V1.1 Dec 16, 2013 save as PNG
//V1.2 Jan 06, 2013, add scalebar

//print("\\Clear");
dot=false;
setBatchMode(true);
match=false;

//get bmp files in a directory

bmps = getBMPList();

//Get an array with all the stage positions and calibration factors for each image
iprs = getIprList(bmps);


//for(i=0; i<iprs.length; i++) {
//	if(iprs[i]!=0) print("iprs "+i+ " "+iprs[i]);
//}


//Open Position Data
Dialog.create(" Data Sets ");
	Dialog.addSlider("Number of Data Sets to Be plotted:", 1, 10, 1);
	Dialog.addCheckbox("Add Legend?", true);
	Dialog.addCheckbox("Add Scalebar?", true);
	file_types = newArray("Tiff","PNG");
	Dialog.addRadioButtonGroup("File type: ", file_types,1,2, "Tiff");  
Dialog.show();

datasets=Dialog.getNumber();
legend=Dialog.getCheckbox();
scalebar=Dialog.getCheckbox();
ftype=Dialog.getRadioButton();
if (ftype == file_types[0]){ 
	ftype = "tif";
}  else { 
	ftype="png";
	run("Input/Output...", "jpeg=100 gif=-1 file=.xls");
}
//print("filetype is " + ftype);


// k loop run once for each point file
for (k=0; k<datasets; k++) {

	
	Dialog.create("Plot Options");
  		Dialog.addChoice("Colour:", newArray("Red", "Green", "Blue", "Yellow", "White"));
  		markers = newArray("Cross","Dot");
  		Dialog.addRadioButtonGroup("Marker Type:", markers, 1, 2, "Cross");
		Dialog.addSlider("Cross Width or Dot Size:", 1, 10, 4);
  		Dialog.addSlider("Cross Size:", 4, 30, 11);
  		Dialog.addCheckbox("Append Comment", false);
  		items = newArray("Number", "Comment", "Both");
  		Dialog.addRadioButtonGroup("Comment Type:", items, 3, 1, "Comment");
  		Dialog.addSlider("Comment Font Size Size:", 4, 30, 18);
  		Dialog.addString("Label for this set of points:","");
	Dialog.show();
	colour=Dialog.getChoice();
	markerType=Dialog.getRadioButton();
	crossWidth=Dialog.getNumber();
	crossSize=Dialog.getNumber();
	addComment=Dialog.getCheckbox();
	labelType=Dialog.getRadioButton();
	commentFont=Dialog.getNumber();
	appString=Dialog.getString();
	setFont("SansSerif",commentFont, "antialiased");

	//print("comment type is "+labelType);
	pointTable = getTextfile(" ");

	// for (k=0; k<4; k++) print(pointTable[k]);
	PTLength = pointTable.length;
	//print("number of points is "+ PTLength);


	//run the l loop  one for each image file
	for (l=0; l<iprs.length;l++) {
		if(iprs[l]!=0) {
			//print("in iprs loop l = "+l);
			caldat=split(iprs[l],",");
			Ox = parseFloat(caldat[1])+(640*parseFloat(caldat[0]))/1000;
			Oy = parseFloat(caldat[2])-(480*parseFloat(caldat[0]))/1000;
			Mx = parseFloat(caldat[1])-(640*parseFloat(caldat[0]))/1000;
			My = parseFloat(caldat[2])+(480*parseFloat(caldat[0]))/1000;
			
			//print("cal dat ="+caldat[);
			//print("min and max Ox = "+Ox+" Oy = "+Oy+"Mx = "+Mx+" My = "+My);
			
			//open the bmp file, if a tiff with the same name exists open that instead
			imgName = replace(bmps[l],".bmp","."+ ftype);
			//print("tiffNmae = "+ tiffName);
			if (File.exists(imgName)) {
					open (imgName);
			} else {
				open(bmps[l]);
			}
			run("RGB Color");
			if (scalebar) {
				imgWidth = 1280*caldat[0];
				logScale = log(imgWidth)/log(10);	
				barWidth = pow(10,floor(logScale-1));
				if(barWidth < imgWidth/15) {
					barWidth = barWidth * 5;
				}
				if(barWidth > imgWidth/2) {
					barWidth = barWidth/2;
				}
				//print("barWidth ="+barWidth+" imgWidth = "+imgWidth+"logscale = "+logScale);
				run("Set Scale...", "distance=1 known="+caldat[0]+" pixel=1 unit=um");
				run("Scale Bar...", "width="+barWidth+" height=5 font=18 color=White background=None location=[Lower Left] bold");
			}
			
			//run the m loop once for each point in point table
			for(m=8;m<PTLength;m=m+2){
				//print("in stage loop m = "+m+" l = "+l);
				//print("point table item "+m+" is "+pointTable[m]);
				quote="\"";
				tempLine = split(pointTable[m]);
				number=tempLine[0];
				comment  = split(pointTable[m],quote);
				templine = substring(pointTable[m],27);
				line=split(templine);
				x=parseFloat(line[1]);
				y=parseFloat(line[2]);
				
				if(((x < Ox)&&(x>Mx)) && ((y>Oy)&&(y<My))) {
					match = true;
					//print("match! bmp is "+bmps[l]);
					//print(comment[1] +  " x = "+line[1]+" y= "+line[2]+ " m = "+ m);
					//waitForUser("hit enter");
					xpix = (Ox-x)*1000/parseFloat(caldat[0]);
					ypix = (y-Oy)*1000/parseFloat(caldat[0]);
					//print("xpix = "+xpix+" ypix = "+ypix);
					if(markerType=="Dot") {
						drawDot(xpix-crossSize/2,ypix-crossSize/2,crossSize,colour);
						fillOval(xpix-crossSize/2,ypix-crossSize/2,crossSize,crossSize);
			
					} else {	
						drawCross(xpix,ypix,crossSize,crossWidth,colour);
					}
						if(addComment){
							if(labelType == "Comment") drawString(comment[1], xpix+crossSize+3,ypix);
							if(labelType == "Number") drawString(number, xpix+crossSize+3,ypix);
							if(labelType == "Both") drawString(number+" "+comment[1], xpix+crossSize+3,ypix);
						}
						
						if(legend) drawString(appString,20,20+(20*k));

				}
				
				
					
			}
		}
		if(match) {
			//print(File.nameWithoutExtension+".tif");
			//waitForUser("hit enter");
			if(File.exists(File.nameWithoutExtension+"."+ftype)) {
				//print("duplicate tif");
				//waitForUser("hit enter");
				//newfile  = File.nameWithoutExtension+"a.bmp";
				saveAs(ftype,newfile);
			} else  saveAs(ftype,bmps[l]);
			}
		//if(match) {save(bmps[l]);}
		match = false;
	}
	
	 run("Close All");
	 //run("Collect Garbage");
}


function getTextfile(inFile) {
	if (inFile == " ") {
		PTfile = File.openDialog("Choose File");
	} else {
		//print ("inFile = "+inFile);
		PTfile=inFile; 
	}
	pt = File.openAsString(PTfile);
	pt = split(pt,"\n");
	return pt;





}

function getBMPList() {
	bmpFiles = newArray(600);
	j=0;
	dir = getDirectory("Select Directory containing location images");
	dirListing = getFileList(dir);
	//print("directory is"+ dir);
	for(i=0; i<dirListing.length; i++) {
		if((endsWith(dirListing[i],".bmp")) && (!endsWith(dirListing[i],"_pnu.bmp"))) {
			//print("file is "+dir+dirListing[i]+" i = "+i);
			bmpFiles[j] = dir+dirListing[i];
			j++;
		}
	
	}
	return bmpFiles;
}



function getCal(image, path){

	
	data=newArray(1,2,3);
	
	iprfilename = File.nameWithoutExtension+".ipr";
	if(File.exists(path+iprfilename)) {
		iprfile=path+iprfilename;
		pt = getTextfile(iprfile);
		line2 = split(pt[2]);
		data[0] = line2[1];
		line5 = split(pt[4]);
		data[1] = line5[1];
		data[2] = line5[2];
	
	}
	return data;
}

function getIprList(bmpfiles) {
	iprlist = newArray(600);
	iprdata = newArray(600);
	for(i=0; i<bmpfiles.length; i++) {
		iprlist[i]=replace(bmpfiles[i],"bmp","ipr");
		if(iprlist[i]!=0) {
			//print("ipr file "+i+" is "+iprlist[i]);
			ipr=getTextfile(iprlist[i]);
			line2 = split(ipr[2]);
			cal = line2[1];
			line5 = split(ipr[4]);
			x = line5[1];
			y = line5[2];
			iprdata[i] = cal+","+x+","+y;
		}
	}
	
	return iprdata;
}

 function drawCross(x,y,size, lineWidth, lineCol) {
 	//showMessage("drawcross","drawcross");
	//drows a hatchmark wher the point has been selected
	//size is length of bars linewidth is the width
 	
 		if (lineCol == "Red") setColor(255,0,0);
 		if (lineCol == "Green") setColor(0,255,0);
 		if (lineCol == "Blue") setColor(0,0,255);
		if (lineCol == "Yellow") setColor(255,255,0);
 		if (lineCol == "White") setColor(255,255,255);
 		
 		setLineWidth(lineWidth);
 		xp = x+size;
 		xm = x-size;
 		yp = y+size;
 		ym = y-size;
 		drawLine(x,yp,x,ym);
 		drawLine(xm,y,xp,y);
 }

   function drawDot(x,y,size, dotCol) {
 	//showMessage("drawcross","drawcross");
	//drows a hatchmark wher the point has been selected
	//size is length of bars linewidth is the width
 	
 		if (dotCol == "Red") setColor(255,0,0);
 		if (dotCol == "Green") setColor(0,255,0);
 		if (dotCol == "Blue") setColor(0,0,255);
 		if (dotCol == "Yellow") setColor(255,255,0);
 		if (dotCol == "White") setColor(255,255,255);
 		
 		
 		
 		drawOval(x,y,size,size);
 		fillOval(x,y,size,size);
 }

