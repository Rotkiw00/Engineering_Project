% Skrypt na brudno w celu przetestowania i sprawdzenia deep learning
% Semantic Segmentation, maskrcnn itp
clc, clear, close
%% Test - rysowanie granic 
BW = imread('/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT/01_fundus_GT.jpg');
imshow(BW)
[labeledImage, numRegions] = bwlabel(BW);
props = regionprops(labeledImage, 'BoundingBox');
hold on;
% Plot the bounding box around each region.
for k = 1 : numRegions
    thisBB = props(k).BoundingBox;
    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
  'EdgeColor','r','LineWidth',2 )
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Semantic Segmentation with Deep Learning
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imgDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB';
pxDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT';

imds = imageDatastore(imgDir);
pxds = imageDatastore(pxDir);

I = readimage(imds,40);
subplot(121)
imshow(I), title('Original Image')

% trzeba ustawić etykiety dla każdej maski, więc trzeba to przeprowadzić w
% pętli
BW = readimage(pxds,40);
BW = logical(BW);
%Create categorical labels based on the image contents.
stringArray = repmat("table",size(BW));
stringArray(BW) = "opticDisk";
categoricalSegmentation = categorical(stringArray);

%Fuse the categorical segmentation with the original image. 
%Display the fused image.
B = labeloverlay(I,categoricalSegmentation);
subplot(122);
imshow(B), title('Overlayed Image with label of OD')