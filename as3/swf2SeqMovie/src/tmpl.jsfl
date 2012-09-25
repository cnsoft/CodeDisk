
fl.outputPanel.clear();
var doc;
var lib;
var c;
var fileReg = /(\d+).png/i;
var pathReg = /(.*)\/[^/]*/;
var restult = fl.scriptURI.match(pathReg);
var current_path = restult[1];

fl.trace(current_path);
fl.createDocument();
doc = fl.getDocumentDOM();
lib = doc.library;
lib.newFolder("@export"); 

//import image to library
for ( c=0;c<pngCount;c++){
     doc.importFile(current_path + "/" + c + ".png", true);
}
   
//make class linkages
var frameItems = {};
var outeritems = getOuterItems();
for(i=0;i<outeritems.length;i++)
{
    var info = get_item_info(outeritems[i].name);
    frameItems[info.frame] = outeritems[i]; //cache frame -> item
    outeritems[i].linkageExportForAS = true;
    outeritems[i].linkageExportInFirstFrame = true;
    outeritems[i].linkageBaseClass = "flash.display.BitmapData";
    outeritems[i].linkageIdentifier = "IMG_" + info.frame;
}    
var movieName;
var movieConfig;
for (movieName in movies){
    movieConfig = movies[movieName];
    //create movies in lib
    lib.addNewItem("movie clip",  "@export/" + movieName); 
    lib.editItem( "@export/" + movieName);
    //insert frames in movies
    fl.getDocumentDOM().getTimeline().removeFrames(0,  fl.getDocumentDOM().getTimeline().frameCount-1);
    for(var i = 0; i < movieConfig['frames'].length; i++)
    {
        doc.getTimeline().insertBlankKeyframe();
        item = frameItems[movieConfig['frames'][i]];
        lib.addItemToDocument({x:0, y:0},  item.name);
        if (movieConfig['lables'][i+""] != null){
            doc.getTimeline().layers[0].frames[doc.getTimeline().currentFrame].name = movieConfig['lables'][i];
        }
        var obj = doc.getTimeline().layers[0].frames[doc.getTimeline().currentFrame].elements[0];
        //x, y
        obj.x = movieConfig['x'][i];
        obj.y = movieConfig['y'][i];
    }
}

//make linkages for movies
var exportitems = getExportItems();
var i;
for(i=0;i<exportitems.length;i++)
{
    fl.trace(exportitems[i].name);
    exportitems[i].linkageExportForAS = true;
    exportitems[i].linkageExportInFirstFrame = true;
    exportitems[i].linkageBaseClass = "flash.display.MovieClip";
}  
  
doc.save();    
         
function getOuterItems() {
    var items = lib.items;
    var outeritems = [];
    for(i=0;i<items.length;i++)
    {
       if (items[i].name.indexOf('@') != 0) {
            outeritems.push(items[i]);
       }
    }
    return outeritems;
}
    
function getExportItems() {
    var items = lib.items;
    var outeritems = [];
    for(i=0;i<items.length;i++)
    {
       if (items[i].name != "@export" && items[i].name.indexOf('@export') == 0) {
            outeritems.push(items[i]);
       }
    }
    return outeritems;
}

function get_item_info(name) {
    var info = {};
    var matches = name.match(fileReg);
    info['frame'] = parseInt(matches[1]);
    return info;
}