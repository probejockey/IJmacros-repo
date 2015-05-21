// Stage Calibrate � Glenn Poirier
// Transforms clicks on an image of a sample holder to stage coordiantes for the JEOL 8230
// USes the anlang program to move and read stage coordinates
// Requires batch programs  stage_read3.bat  and movestage2.bat the script expects to find them in the root of the C: drive but you can change this
// Use at your own risk no guarantees or warrantees implied. If it screws things up tough!


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

//check for existing calibration
prevcal = calCheck(inName,inDir);
//print("prevcal="+prevcal);

if(prevcal) {
	calcoeffs = readCal(inName,inDir);
} else {





// Instructions
  showMessage("Instructions", "<html>"
     +"<h1>Point Selection</h1>"
     +"<ul>"
     +"<li>Move stage to a recognizeable point</u>"
     +"<li>Alt right-click corresponding point on image"
     +"<li>Try to be as accurate as possible"
     +"</ul>");



     
setOption("DisablePopupMenu", true);

i = 0;
do {
	point = false;
	while (!point) {
		getCursorLoc(x, y, z, flags);
          	if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
             	 s = " ";
             	 if (flags&leftButton!=0) s = s + "<left>";
             	 if (flags&rightButton!=0) s = s + "<right>";
              	if (flags&shift!=0) s = s + "<shift>";
              	if (flags&ctrl!=0) s = s + "<ctrl> ";
             	 if (flags&alt!=0) s = s + "<alt>";
             	 if (flags&insideROI!=0) s = s + "<inside>";
             	 if (flags&alt!=0 && flags&rightButton!=0) { 
             	 	//showMessage("Success", "alt-right click");
             	 	//print(x+" "+y+" "+z+" "+flags + "" + s);
             	 	point = true;
             	 }
             	 
              	startTime = getTime();
          }
          x2=x; y2=y; z2=z; flags2=flags;
          wait(10);
      	}

      	//showMessage("Message", "Out of cursorloc loop "+x+" "+y+" "+z+" "+flags + "" + s);
      	inx[i]=x2; iny[i]=y2;
      	drawCross(x2,y2,20,2);
      	tempstg = readStage();
		stgx[i] = tempstg[0];
		stgy[i] = tempstg[1];
		stgz[i] = tempstg[2];
      
		



	
	
	//print( "i = " + i);


	i++;

	} while (i < 3);

	//for (i=0; i<3;i++) print("x = " +inx[i]+" y = "+iny[i]);
	//for (i=0; i<3;i++) print("x = " +stgx[i]+" y = "+stgy[i]);
	//stgcal = doCal();
	calcoeffs = doCal();

}

// main body of macro

notdone = true;
showMessage("Instructions", "<html>"
     +"<h1>Point Selection</h1>"
     +"<ul>"
     +"<li>Left-click to move stage to selected point</u>"
     +"<li>Shift key draws temporary mark at current position</u>"
     +"<li>Alt right-click to quit"
     +"</ul>");
	 z_ts=0;
do {
	//listen for clicks on image
	getCursorLoc(x, y, z, flags);
	if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {
        s = " ";
        if (flags&leftButton!=0) {
        	s = s + "<left>";
        	moveStage(x,y, calcoeffs);
        	drawCross(x,y,25,15);
        	if(z_ts!=1) {
			ts_Z = setZts();
			z_ts =1;
		}
        }
	if (flags&alt!=0 && flags&rightButton!=0) {
	notdone = false;
	}
	if (isKeyDown("shift")) {
		currstg = readStage();
		//print("curr stage x ="+currstg[0]);
		//print("curr stage y ="+currstg[1]);
		//for(i=0;i<4;i++) print("calcoeffs = "+ calcoeffs[i]);
		xypix[0]= (parseFloat(currstg[0])-parseFloat(calcoeffs[0]))/parseFloat(calcoeffs[1]);
		xypix[1]= (parseFloat(currstg[1])-parseFloat(calcoeffs[2]))/parseFloat(calcoeffs[3]);
		//print("in pos loop");
		//print("x= "+xypix[0]+ "y= "+xypix[1]);
		drawCrossO(xypix[0],xypix[1],70,20);
		setKeyDown("none"); 
			
	}
		
		
    }	
	
} while (notdone);


//output =  exec("help");
//print (output)

 function drawCross(x,y,size, lineWidth) {
 	//showMessage("drawcross","drawcross");
	//drows a hatchmark wher the point has been selected
	//size is length of bars linewidth is the width
 	
 		setColor(255,255,0);
 		setLineWidth(lineWidth);
 		xp = x+size;
 		xm = x-size;
 		yp = y+size;
 		ym = y-size;
 		drawLine(x,yp,x,ym);
 		drawLine(xm,y,xp,y);
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

function readStage() {
	//tmpstg[0] = j*10;
	//tmpstg[1] = j*10;
	//eout = exec("cmd" ,"/c", "dir");
	//print (eout);
	//eout = exec("cmd" ,"/c", "/b", "start",  "C:\\stage_read3.bat");
	tmpstg = newArray(1,2,3);
	eout = exec("C:\\stage_read3.bat");
	//print (eout);
	xpos=indexOf(eout, "x=");
	tmpstg[0]=substring(eout,xpos+2,xpos+10);
	ypos=indexOf(eout, "y=");
	tmpstg[1]=substring(eout,ypos+2,ypos+10);
	zpos=indexOf(eout, "z=");
	tmpstg[2]=substring(eout,zpos+2,zpos+9);
	//print("xval = "+tmpstg[0]+" yval = "+tmpstg[1]+" zval = "+tmpstg[2]);

	// strip trailing junk
	if(matches(tmpstg[0],".*y.*")) {
		//print("junk on the end");
		tmpstg[0] = substring(tmpstg[0], 0,7);
	}
	if(matches(tmpstg[1],".*z.*")) {
		//print("junk on the end");
		tmpstg[1] = substring(tmpstg[1], 0,7);
	}
	if(matches(tmpstg[2],".*z.*")) {
		//print("junk on the end");
		tmpstg[2] = substring(tmpstg[2], 0,7);
	}
	//nodig = matches(tmpstg[0],"[^0-9]");
	//print("nondigits = "+nodig);
	//print("in readstage");
	//for(i=0; i<3; i++) print(tmpstg[i]);
	return tmpstg;
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



function moveStage(xmov,ymov,calib) {
	//showMessage("movestage","movestage");
	//calculates stage coordinates for clicked point and moves stage

	stgxmm = xmov*calib[1]+calib[0];
  	stgymm = ymov*calib[3]+calib[2];
  	//print("ymov = "+ymov+" , xmov = "+xmov);
  	//for(i=0; i<4; i++) print ("calib["+i+"] = "+calib[i]);
  	if(stgz[0] == 1) {
  		if(ts_Z! = 0){ stgzmm=parseFloat(ts_Z); 
  		} else { stgzmm = 10.30;}
  	}else {
  		stgzmm = stgz[0];
  	}

  	//print("stage x ="+stgxmm+" stage y ="+stgymm+" stage z = "+stgzmm);
  	//delete previous coordinate file
  	temp = File.delete("c:\\jeol service\\EPMA Service\\move.anl"); 
  	f = File.open("c:\\jeol service\\EPMA Service\\move.anl");

  	//write new coordinates file
  	mvstring="xm_cmd(\"stg_posit\", XMSET, "+stgxmm+", "+stgymm+", "+stgzmm+");";
	//print ("***"+mvstring+"***");
  	print(f, mvstring);
	File.close(f);
	
	mout = exec("C:\\movestage2.bat");
	//print (mout);

  	
	
}

function calCheck(image, path){

	// if there is aprevious calibration for the loaded image, ask the user if it should be used or updated
	
	keep = false;
	calfilename = File.nameWithoutExtension+".cal";
	if(File.exists(path+calfilename)) {
		Dialog.create("Preexisting Calibration")
		Dialog.addMessage("A calibration already exixts for this image! \n Do you want to keep it or do a new calibration? \n");
		keep = Dialog.addCheckbox("Keep", true);
		Dialog.addCheckbox("Redo", false);
		Dialog.show()
		keep = Dialog.getCheckbox();
		if(keep!=true) redo=true;
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
function setZts() {
	Dialog.create("Adjust Stage Focus")
		Dialog.addMessage("Do you want to adjust the Z position of the stage? \n Further moves will use this Z \n Set Z focus and click OK");
		keep = Dialog.addCheckbox("Adjust", true);
		//Dialog.addCheckbox("Don't Adjust", false);
		Dialog.show()
		adjust = Dialog.getCheckbox();
		temp = readStage();
		if(adjust) ts_Z = temp[2];

		//print("adjust = "+adjust+"Z = "+ts_Z);
		return ts_Z;
		
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
