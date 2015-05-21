macro "Plot Points" {
// Plot Points ? Glenn Poirier
// Inputs a calibrated image file (see stage calibrate) and a csv file of consisting of a comment and X, Y Z coordiantes for each point
// Does not save created images.

// Use at your own risk no guarantees or warrantees implied. If it screws things up tough!
setBatchMode(true);

inx=newArray(1,2,3);
iny=newArray(1,2,3);
currXY=newArray(1,2);
xypix=newArray(1,2);
currstg=newArray(1,2,3);
var stgx=newArray(1,2,3);
var stgy=newArray(1,2,3);
var stgz=newArray(1,2,3);
var calcoeffs=newArray(0,1,2,3);

	
      shift=1;
      ctrl=2; 
      rightButton=4;
      alt=8;
      leftButton=16;
      insideROI = 32; // requires 1.42i or later
      x2=-1; y2=-1; z2=-1; flags2=-1;

ts_Z = 0;

      
//Get image

open();

run("Original Scale");
setOption("DisablePopupMenu", true);
//Get image info

inWidth = getWidth();
inHeight = getHeight();
//print("input width = "+inWidth+" "+inHeight);
inName = getInfo("image.filename");
inDir = getInfo("image.directory");
run("RGB Color");
//check for existing calibration
//prevcal = calCheck(inName,inDir);
//print("prevcal="+prevcal);

//if(prevcal) {
	calcoeffs = readCal(inName,inDir);
//} 

crossWidth=2;
crossSize=10;
dotSize=25;
addComment=false;
dot=false;
commentFont=21;

// main body of macro

Dialog.create(" Data Sets ");
	Dialog.addSlider("Number of Data Sets to Be plotted:", 1, 10, 1);
	Dialog.addCheckbox("Add Legend?", false);
	Dialog.addCheckbox("autosave PNG",true);
Dialog.show();
appendix=Dialog.getCheckbox();
autosave=Dialog.getCheckbox();
datasets=Dialog.getNumber();

for (k=0; k<datasets; k++) {

	Dialog.create("Plot Options");
  		Dialog.addChoice("Colour:", newArray("Yellow", "Red", "Green", "Blue", "White"));
  		Dialog.addChoice("Shape:", newArray("Dot", "Cross"));
		Dialog.addSlider("Cross Width:", 1, 10, crossWidth);
  		Dialog.addSlider("Cross Size:", 4, 30, crossSize);
  		Dialog.addSlider("Dot Size:", 4, 30, dotSize);
  		Dialog.addCheckbox("Append Comment", addComment);
  		Dialog.addSlider("Comment Font Size Size:", 4, 30, commentFont);
	Dialog.show();
	colour=Dialog.getChoice();
	if(Dialog.getChoice()== "Dot") {dot=true;}
	crossWidth=Dialog.getNumber();
	crossSize=Dialog.getNumber();
	dotSize=Dialog.getNumber();
	addComment=Dialog.getCheckbox();
	commentFont=Dialog.getNumber();
	//setFont("SansSerif",commentFont, "antialiased");
	setFont("SansSerif",commentFont,"antialiased");

	pointTable = getPointTable();

	// for (k=0; k<4; k++) print(pointTable[k]);
	PTLength = pointTable.length;


	for (i=8; i<PTLength; i=i+2) {
		quote="\"";
		tempLine = split(pointTable[i]);
		number=tempLine[0];
		comment  = split(pointTable[i],quote);
		
		templine = substring(pointTable[i],27);
		line=split(templine);
		//line = split(pointTable[i],",");
		//print(" line is "+templine);
		print("comment is "+comment[1] + "numnber is "+ number);
		comment[1] = replace(comment[1],"   ","");
		print("comment is "+comment[1] + "numnber is "+ number);
		xypix[0]= (parseFloat(line[1])-parseFloat(calcoeffs[0]))/parseFloat(calcoeffs[1]);
		xypix[1]= (parseFloat(line[2])-parseFloat(calcoeffs[2]))/parseFloat(calcoeffs[3]);
		//print("xypix[0] = "+xypix[0]+"xypix[1] = "+ xypix[1]);
		if(dot) {
			drawDot(xypix[0],xypix[1],dotSize,colour);
			fillOval(xypix[0],xypix[1],dotSize,dotSize);
			
		} else {	
			drawCross(xypix[0],xypix[1],crossSize,crossWidth,colour);
		}
		//if(addComment) drawString(line[0], xypix[0]+crossSize+3,xypix[1]);
		if(addComment) drawString(comment[1], xypix[0]+crossSize+3,xypix[1]);


		//print ("i = " +i+" " +line[0]+" "+line[1]);

	}


    


	//output =  exec("help");
	//print ("k = "+k+" datasets = "+datasets);
	
}

if (autosave) {
 saveAs("png", inDir+substring(inName,0, lengthOf(inName)-4)+"-ann");
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
 }
 

 function drawCrossO(x,y,size, lineWidth) {
 	//showMessage("drawcross","drawcross");
	//drows a hatchmark wher the point has been selected
	//size is length of bars linewidth is the width
 	
 		setColor(0,0,255);
 		setLineWidth(lineWidth);
 		Overlay.remove;
 		
 		xp = x+size;
 		xm = x-size;
 		yp = y+size;
 		ym = y-size;
 		Overlay.drawLine(x,yp,x,ym);
 		Overlay.drawLine(xm,y,xp,y);
 		Overlay.show;
 }


function doCal() {

 // Do a straight line fit

 //fit x points
  Fit.doFit("Straight Line", inx, stgx);
  //print(" for x a="+d2s(Fit.p(0),6)+", b="+d2s(Fit.p(1),6));

  xa=d2s(Fit.p(0),6);
  xb=d2s(Fit.p(1),6);

  //Fit Y points
  Fit.doFit("Straight Line", iny, stgy);
  //print("for y a="+d2s(Fit.p(0),6)+", b="+d2s(Fit.p(1),6));

  ya=d2s(Fit.p(0),6);
  yb=d2s(Fit.p(1),6);

  var calcoeffs=newArray(xa,xb,ya,yb);

  //write coefficients to calibration file
  temp = File.delete(inDir+File.nameWithoutExtension+".cal");
  cf = File.open(inDir+File.nameWithoutExtension+".cal");
  for (k=0; k<4; k++) print(cf, calcoeffs[k]);
  File.close(cf);

  return calcoeffs;

}





function calCheck(image, path){

	// if there is aprevious calibration for the loaded image, ask the user if it should be used or updated
	
	keep = 0;
	calfilename = File.nameWithoutExtension+".cal";
	if(File.exists(path+calfilename)) {
		//Dialog.create("Preexisting Calibration")
		//Dialog.addMessage("A calibration already exixts for this image! \n Do you want to keep it or do a new calibration? \n");
		//keep = Dialog.addCheckbox("Keep", true);
		//Dialog.addCheckbox("Redo", false);
		//Dialog.show()
		//keep = Dialog.getCheckbox();
		keep = getBoolean("A calibration already exixts for this image! \n Do you want to keep it( Click Yes) or do a new calibration (Click No)? \n");
		if(keep!=1) redo=true;
	}
	return keep;
}


function readCal(image, path){
	calfilename = File.nameWithoutExtension+".cal";
	cf = File.openAsString(path+calfilename);
	coeffs =newArray(1,2,3,4);
	lines=split(cf,"\n");
	for (k=0; k<4; k++) {
		//print("lines k = "+k+" "+lines[k]);
		coeffs[k] =lines[k];
	}
  	//File.close(cf);
  	//lines = calcoeffs;
  	return coeffs;
}


function getXYpix(cstg,calib) {
	xypix=newArray(1,2);
	for(i=0;i<4;i++) print("cstg["+i+"] = "cstg[i]);
	//xypix[0]= (cstg[0]-calib[0])/calib[1];
	//xypix[1]= (cstg[1]-calib[2])/calib[3];
	//return xypix;
	print("in getXYpix");
	xypix[0] = 5;
	xypix[1] = 6;
	return xypix;
}
function getPointTable() {
	PTfile = File.openDialog("open Point Table");
	pt = File.openAsString(PTfile);
	pt = split(pt,"\n");
	return pt;





}


}
