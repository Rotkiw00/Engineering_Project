% Skrypt na brudno w celu przetestowania i sprawdzenia deep learning
% Semantic Segmentation, maskrcnn itp
clc, clear, close
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test - rysowanie granic 
BW = imread('/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT/01_fundus_GT.png');
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

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Semantic Segmentation with Deep Learning
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imgDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB';
imds = imageDatastore(imgDir);

pxDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT';
classNames = ["opticDisk", "background"];
labelIDs = [255 0];
pxds = pixelLabelDatastore(pxDir, classNames, labelIDs);

% C = cell(900,1); for i = 1:900
%     BW = readimage(pxds,i); BW = logical(BW); segArray =
%     repmat("background",size(BW)); segArray(BW) = "opticDisk";
%     segmentLabels = categorical(segArray); C{i} = segmentLabels;
% end

I = readimage(imds,5);
BW_ = readimage(pxds, 5);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% wyświetlanie - test
subplot(121)
imshow(I), title('Original Image')
B = labeloverlay(I,BW_, 'IncludedLabels', "opticDisk", 'Transparency', 0.5);
subplot(122);
imshow(B), title('Overlayed Image with label of OD')
%% sprawdzenie
buildingMask = BW_ == 'opticDisk';
figure
imshowpair(I, buildingMask,'montage')
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Creating a SSN ~ network
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numFilters = 512;
filterSize = 3;
numClasses = 2;
netLayers = [
    imageInputLayer([512 512 3])
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    convolution2dLayer(1,numClasses);
    softmaxLayer()
    pixelClassificationLayer()
    ];
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Initialize and combine training data
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imgDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB';
imds = imageDatastore(imgDir);

pxDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT';
classNames = ["opticDisk", "background"];
labelIDs = [255 0];
pxds = pixelLabelDatastore(pxDir, classNames, labelIDs);

opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',10, ...
    'MiniBatchSize',10, ...
    'ExecutionEnvironment', 'parallel', ...
    'Plots', 'training-progress');

trainingData = combine(imds, pxds);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Train created network
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
net = trainNetwork(trainingData, netLayers, opts);