%% Notes
% Po wcześniejszym zmniejszeniu rozdzielczości łatwiej jest
% wyodrębnić obszar -> imresize
% Następnie można byłoby wykonać podstawowe operacje morfologiczne jak np.
% dylatacje i erozje, żeby pozbyć się luk i ładnie wysegmentować obszar
%% Inicjalizacja
clc, clear, close


%% Progowanie i binaryzacja
I2 = PROGOWANIE(I, 150);
%I2 = BINARYZACJA(I, 150, 'dolna');

%%
subplot(121)
imshow(I2);
subplot(122)
Iwyj = WYPELNIENIE(I2);
imshow(I);
%% %%%%%%%%%%%%  Notes %%%%%%%%%%%%%%
% funkcja strel
% doc strel
% fudge dactor - współczynnik korygujący

% W przypadku słabo widocznego obszaru można dodać coś, żeby np. zwiększyć
% kontrast lub coś, żeby poprawić jasność obszaru, żeby móc go lepiej
% wysegmentować

[~,threshold] = edge(I2,'sobel');
fudgeFactor = 0.5;
BWs = edge(I2,'sobel',threshold * fudgeFactor);

se90 = strel('line',3,90);
se0 = strel('line',3,0);
%%
BWsdil = imdilate(BWs,[se90 se0]);
imshow(BWsdil)
title('Dilated Gradient Mask')
%%
BWdfill = imfill(BWsdil,'holes');
imshow(BWdfill)
title('Binary Image with Filled Holes')
%%
BWnobord = imclearborder(BWdfill,8);
imshow(BWnobord)
title('Cleared Border Image')
%%
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
imshow(BWfinal)
title('Segmented Image');
%%
imshow(labeloverlay(I,BWfinal))
title('Mask Over Original Image')
%% - Spróbować zrobić operacje otwarcia i zamknięcia, 
% po to żeby pozbyć się luk i spróbować dobrze wykonać maskę
BWoutline = bwperim(BWfinal);
Segout = I; 
Segout(BWoutline) = 0;
imshow(Segout)
title('Outlined Original Image')

% [centers, radii] = imfindcircles(BWfinal,[1 10]);
% figure
% imshow(I)
% hold on
% viscircles(centers, radii,'EdgeColor','b');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMULACJA DZIAŁANIA SKRYPTÓW Z GUI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB/0103_fundus.JPG';
image = imread(path);
%[H,W] = size(image); % 1424x2144

% Zmiana rozdzielczości
I = imresize(image,[512 512]); % (1) 712x1072 (2) 356x536

% K = imadjust(I, [0.2 0.3 0; 0.6 0.7 1], []);
% figure;
% subplot(121)
% imshow(I)
% subplot(122)
% imshow(K)
%% 
I2 = rgb2gray(I);
level = graythresh(I2);

subplot(151);
imshow(I2), title("Skala szarości - zwykły rgb2gray");

% subplot(132);
% imshow(I_2);

[R,G,B] = imsplit(I);

grayImage = rgb2gray(cat(3, R, .5*double(G), zeros(512)));
grayImage = uint8(grayImage);

subplot(152);
imshow(grayImage), title("Skala szarości - zabawa z kanałami");

aaa = .9*double(R);
fun = @(x) median(x(:));
B = nlfilter(uint8(aaa),[3 3],fun); 
subplot(153);
imshow(B), title("Zabawa z kanałami vol 2")

I_wyj = BINARYZACJA(I, WYZNACZ_PROG(I), 0);
% ------------------------------------------------------------------------
% level*1000 powoduje ze prog jest dobierany automatycznie, ale czasem
% moze zajsc koniecznosc dostosowania jeszcze lepszego progu, dlatego mozna
% zrobic tak, ze bedzie liczony z automatu, ale jak bedzie wola dobrania
% lepszego progu to zaznaczamy checkboxa i dostosowujemy dla siebie. Jako
% zapisywanie do pliku mozna zrobic zapisanie maski otrzymanej oraz
% otrzymanego wyniku zlokalizowanego OD (Optic Disc)

% Jako podgląd można wyświetlić zdjęcie przetworzone już do rozdz. 512x512
% i dopiero w nastepnych zdjeciach operowac juz na takim egzemplarzu
I_kont = KONTUR(I_wyj, 'sobel', 0.5);
I_segm = SEGMENTACJA_OD(I_kont, 'diamond');
subplot(154);
imshow(I_segm), title("Maska");
%% Wyznaczanie CENTROIDU punktu centralnego
bw_centr = regionprops(I_segm, 'centroid');
bw_box = regionprops(I_segm, 'BoundingBox');
centroids = cat(1, bw_centr.Centroid);
boundings = cat(1, bw_box.BoundingBox);
%% Wyznaczanie granic
B = bwboundaries(imread('/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT/0103_fundus_GT.jpg'));
subplot(155);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imshow(I), title('Zlokalizowane granice OD');
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 1)
   plot(centroids(:,1),centroids(:,2),'b*', 'LineWidth', 0.5)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Metoda z określaniem maski - aktywny kontur
imshow(I_segm);
r = drawrectangle;
mask = createMask(r);
bw = activecontour(I_segm,mask,200,'edge');
imshow(BW), title("Active contour with drawrectangle");
hold on;
visboundaries(bw,'Color','r'); 
%% seryjne obliczanie progu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path = "/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB/";
info = dir(path);
elemslist = natsort({info(:).name});
elemslist(ismember(elemslist,{'.','..','.DS_Store'}))=[];
prog = ones(length(elemslist), 1);
for i = 1 : length(elemslist)
    I = imread(path+elemslist{i});
    prog(i) = WYZNACZ_PROG(I);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
path = "/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB/001_fundus.jpg";
[a,b,c] = fileparts(path);
disp(a);
disp(b);
disp(c);

%% Obliczanie powierzchni wysegmentowanej powierzchni maski
% Determine the connected components:
% CC = bwconncomp(BW, conn);
% 
% Compute the area of each component:
% S = regionprops(CC, 'Area');
% 
% Remove small objects:
% L = labelmatrix(CC);
% BW2 = ismember(L, find([S.Area] >= P));

%%
% a = regionprops('table', I_segm, 'basic');
%% Poprawianie ręczne masek - dodać jako nową funkcjonalność
imgNum = '01';
path = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageDB/';
imageName = cat(2, imgNum, '_fundus.jpg');
try    
    I = imread(cat(2, path, imageName));
catch
    disp('There was an error')
end
%imshow(I)
% roi = drawellipse();
%%
savePath = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT/';
GTImageName = cat(2, imgNum, '_fundus_GT.jpg');
mask = createMask(roi);
imwrite(mask, cat(2, savePath, GTImageName));
clc,clear,close

%% Test
% data = rand(140, 4);
% c = cell(140, 4);
% for i = 1:140
%     for j = 1:4
%         c{i,j} = data(i,j);
%     end
% end
p1 = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/ImageMASKS';
p2 = '/Users/wiktorkalaga/Documents/Zasoby do inżynierki/Projekt Inżynierski/MasksGT';
POROWNAJ_MASKI(p1, p2, 'folder');