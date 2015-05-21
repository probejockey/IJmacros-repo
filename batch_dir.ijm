dir=getDirectory("Choose a Directory");
processedDir=dir + "\Processed\\";
File.makeDirectory(processedDir);

//loop through your file list and after you open each file
imgName=getTitle();

run("Point Tool...", "selection=Yellow cross=White marker=Mediam mark=5 label");
makePoint(255, 255);
saveAs("PNG", processedDir+ imgName); 