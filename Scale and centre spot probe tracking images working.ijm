 
// "BatchProcessFolders" 
// 
// This macro batch processes all the files in a folder and any 
// subfolders in that folder. In this example, it runs the Subtract 
// Background command of TIFF files. For other kinds of processing, 
// edit the processFile() function at the end of this macro. 
 
macro "batch process folder add centre marks and add scale"{ 
 requires("1.33s"); 
  dir = getDirectory("Choose an Input Directory "); 
  //print ("input from " + dir)
  
  outdir  = getDirectory("Choose an Output Directory ");

//Open Position Data
Dialog.create(" Options");
Dialog.addCheckbox(" Analysis Marker", true);
Dialog.addCheckbox("Scale", true);
Dialog.addCheckbox("Magnification", false);
items = newArray("File name ", "Comment");
Dialog.addRadioButtonGroup("Label", items, 1, 2 , "comment");
   
   
Dialog.show();

mark = Dialog.getCheckbox();
scale = Dialog.getCheckbox();
label = Dialog.getRadioButton();
magnification = Dialog.getCheckbox()

  
//print ("output from " + outdir)
setBatchMode(true); 
count = 0; 
countFiles(dir); 
  //print("there are " + count+ "files");
  n = 0; 
  processFile(dir); 
  //print(count+" files processed"); 
 
  function countFiles(dir) { 
     list = getFileList(dir); 
     for (i=0; i<list.length; i++) { 
         if (endsWith(list[i], "/")) 
             countFiles(""+dir+list[i]); 
         else 
             count++; 
             
     } 
 } 
 
  function processFiles(dir) { 
     list = getFileList(dir); 
     for (i=0; i<list.length; i++) { 
         if (endsWith(list[i], "/")) 
             processFiles(""+dir+list[i]); 
         else { 
            showProgress(n++, count); 
            path = dir+list[i]; 
            processFile(path); 
            print(" n = "+n+" I = "+i);
         } 
     } 
 } 
 
 function processFile(path) { 
 	print(path)
 	list = getFileList(path);
 	for (i=0; i<list.length; i++) {
 		print(list[i]);
 	}
	for (i=0; i<list.length; i++) {
      if (endsWith(list[i], ".bmp")) { 
      print("file is " + list[i]);
          open(dir+list[i]); 
    	//print(list[i]);
    m = getMag(list[i],path);
    comm = getComment(path);	
    //print("mag is " + m);
    setColor("Black");
    if (mark) {
   	 	h = getHeight();
    	setColor("Black");
		drawOval(h/2,h/2,6,6);
    }
    if(scale) {	
		makeLine(1, 193, 512, 191);
		imagewidth = pow(m, -1) * 120000;
    	run("Set Scale...", "known=["+ imagewidth + " ] unit=um");
    	setTool("wand");
    	run("Scale Bar...", "width=20 height=4 font=14 color=White background=Black location=[Lower Left] bold");
    }
    if (label == "File name") {
    	setFont("Arial", 18, "antiliased");
    	text = File.nameWithoutExtension;
    	drawString(text, 10,40, "white");
    }
    if (label == "Comment") {
    	setFont("Arial", 18, "antiliased");
    	drawString(comm, 10,40, "white");
    }
    
     if (magnification) {
    	setFont("Arial", 18, "antiliased");
    	l = getStringWidth(text);
    	//text = File.nameWithoutExtension;
    	drawString(m+"x", l+20,40, "white");
    }
	save(outdir+list[i]);
    close(list[i]);
    showProgress(i/list.length);

    //setTool("line");



 }

 

 
} 
          
}
function getMag(image, path){

	
	
	
	magfilename = File.nameWithoutExtension+".txt";
	if(File.exists(path+magfilename)) {
		magfile=path+magfilename;
		pt = getTextfile(magfile);
		line2 = split(pt[1]);
		mag = line2[1];
	}
	return mag;
}


function getComment(path) {
  
  wtfile  = File.openAsString(path+"1.wt");
  file = split(wtfile,"\n");
  line6 = split(file[5],";");
  return line6[2];

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
   
      
 }} 