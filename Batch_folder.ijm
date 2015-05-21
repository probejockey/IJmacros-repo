
// "BatchProcessFolders"
//
// This macro batch processes all the files in a folder and any
// subfolders in that folder. In this example, it runs the Subtract
// Background command of TIFF files. For other kinds of processing,
// edit the processFile() function at the end of this macro.

macro "batch process folder scale and make movie"{
 requires("1.33s");
  dir = getDirectory("Choose an Input Directory ");
  print ("input from " + dir)
  
  outdir  = getDirectory("Choose an Output Directory ");

//Open Position Data
Dialog.create(" Magnification ");
	Dialog.addSlider("Image Magnification:", 40, 10000, 10);
Dialog.show();

mag=Dialog.getNumber();
imagewidth = pow(mag, -1) * 120000;
print ("imagewidth = " + imagewidth);
wait(3000);

  
  print ("output from " + outdir)
  setBatchMode(true);
  count = 0;
  countFiles(dir);
  print("there are " + count+ "files");
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
      if (endsWith(list[i], ".bmp")) {
      print("file is " + list[i]);
          open(dir+list[i]);
   	//print(list[i]);
    setColor("Black");
	drawOval(252,252,6,6);
	makeLine(1, 193, 512, 191);
    run("Set Scale...", "known=["+ imagewidth + " ] unit=um");
    setTool("wand");
    run("Scale Bar...", "width=20 height=4 font=14 color=White background=Black location=[Lower Left] bold");
	save(outdir+list[i]);
    close(list[i]);

    //setTool("line");



 }


}
          
     }
 }} 