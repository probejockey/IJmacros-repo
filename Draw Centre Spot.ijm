// Open all files from a source directory
// and save them in a target directory in TIFF format
// Albert Cardona 2007
//
source_dir = getDirectory("Source Directory");
target_dir = getDirectory("Target Directory");
if (File.exists(source_dir) && File.exists(target_dir)) {
    setBatchMode(true);
    list = getFileList(source_dir);
    print("list has " +  list.length);
    for (i=0; i<list.length; i++) {
        if endsWith(list[i], ".bmp") {
            open(source_dir + "/" + list[i]);
        run("Point Tool...", "selection=Yellow cross=White marker=Mediam mark=5 label");
		makePoint(255, 255);
	    saveAs("png", target_dir + "/" + list[i] + ".png");
	    close();
	    showProgress(i, list.length);
        }
    }
}
