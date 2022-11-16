clear, close, clc
%% Initialize and prepare
% path = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/1000images';
path = pwd; 
info = dir(path);
elemslist = {info(:).name};
elemslist(ismember(elemslist,{'.','..','.DS_Store'}))=[];
%% Print names of folders
for i=1 : length(elemslist)
    fprintf('Folder #%d. Name: %s\n', i, elemslist{i});
end
%% Create new directory and copy images from subdirectories to new one
path = "/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski";
if ~isfolder("/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB/")
    mkdir(path, "ImageDB");
    for i=1 : length(elemslist)
        copyfile(elemslist{i}, path+"/ImageDB");
    end
else
    disp("Folder już istnieje. Operacja jest niepotrzebna.")
end
%% Rename name of images
path = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB/';
files = dir(path);
filesname = { files(:).name };
filesname(ismember(filesname, {'.','..', '.DS_Store'})) = [];
for file = 1 : length(filesname)
  newName = fullfile(path, sprintf( '0%d_fundus.JPG', file ) );
  try
      movefile( fullfile(path, filesname{ file }), newName );    
  catch
      warning("Problem with using function movefile. Cannot copy or move a file or directory onto itself.")
  end
end
%% Change images resolution and save them
path = "/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB/";
info = dir(path);
elemslist = {info(:).name};
elemslist(ismember(elemslist,{'.','..','.DS_Store'}))=[];
for i = 1 : length(elemslist)
    filename = elemslist{i};
    I_curr = imread(path+filename);
    I_new = imresize(I_curr, [512 512]);
    imwrite(I_new, path+filename);
end