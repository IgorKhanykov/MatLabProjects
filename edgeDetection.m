
% 1) read image from file
[fileName, pathToFolder, filterIndex]=uigetfile({'*.png';'*.bmp'},'Select png-image...');
pathToFile=fullfile(pathToFolder, fileName);
if( size(pathToFile,2)==3)
    msgbox('Empty pathToFile');
    return;
end;

splitedString = strsplit(fileName,'.');
splitedStringLength=length(splitedString);
fileExtension=char(splitedString(splitedStringLength));

img=imread(pathToFile,fileExtension);

imgDimentions=size(img);
imgNumOfRows=imgDimentions(1,1);
imgNumOfCols=imgDimentions(1,2);
img2d=zeros(imgNumOfRows,imgNumOfCols);
for i=1:1:imgNumOfRows
    for j=1:1:imgNumOfCols
        img2d(i,j)=img(i,j,1);
    end;
end;

%imshow(img2d);
% 2) detect edges
imgEdged=edge(img2d, 'Canny');
%[BW,thresh] = edge(img2d,'canny');

%imgEdged=edge(img2d, 'Canny', [0.1,0.4]);
imshow(imgEdged);

% 3) изменить название и сохранить imgEdged в туже папку
splitedString = strsplit(fileName,'_');
splitedStringLength=length(splitedString);
fileTitle=char(splitedString(1));
fileNameNew=strcat(fileTitle,'canny','.png'); % fileExtension
pathToFileNew=fullfile(pathToFolder,fileNameNew);
imwrite(imgEdged, pathToFileNew);

% 4) выделить границы на исходном изображении
imgBordered=img;
for i=1:1:imgNumOfRows
    for j=1:1:imgNumOfCols
        if (imgEdged(i,j)==1)
            imgBordered(i,j,1)=0;
            imgBordered(i,j,2)=255;
            imgBordered(i,j,3)=255;
        end;
    end;
end;
imshow(imgBordered);

% 5) изменить название и сохранить imgBordered в туже папку
%splitedString = strsplit(fileName,'_');
%fileTitle=char(splitedString(1));
fileNameNew=strcat(fileTitle,'cannyBordered','.png'); % fileExtension
pathToFileNew=fullfile(pathToFolder,fileNameNew);
imwrite(imgBordered, pathToFileNew);





