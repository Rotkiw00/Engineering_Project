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

imgDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB_128';
imds = imageDatastore(imgDir);

pxDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT_128';
classNames = ["opticDisk", "background"];
labelIDs = [255 0];
pxds = pixelLabelDatastore(pxDir, classNames, labelIDs);

% C = cell(900,1); for i = 1:900
%     BW = readimage(pxds,i); BW = logical(BW); segArray =
%     repmat("background",size(BW)); segArray(BW) = "opticDisk";
%     segmentLabels = categorical(segArray); C{i} = segmentLabels;
% end

I = readimage(imds,11);
BW_ = readimage(pxds, 11);
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
numFilters = 256; %256
filterSize = 3;
numClasses = 2;
netLayers = [
    imageInputLayer([128 128 3])
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
imgDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB_128';
imds = imageDatastore(imgDir);

pxDir = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT_128';
classNames = ["opticDisk", "background"];
labelIDs = [255 0];
pxds = pixelLabelDatastore(pxDir, classNames, labelIDs);

opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',50, ...
    'MiniBatchSize',60, ...
    'Plots','training-progress');

%'ExecutionEnvironment', 'parallel'

trainingData = combine(imds, pxds);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Train created network
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
net = trainNetwork(trainingData, netLayers, opts);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Save trained network
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save net;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Sprawdzenie 'net'
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
testImage = imread('/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB_128/0309_fundus.png');
imshow(testImage);
C = semanticseg(testImage,net);
B = labeloverlay(testImage, C, 'IncludedLabels', "opticDisk", 'Transparency', 0.5);
R = imresize(B, 4, 'nearest');
imshow(R)