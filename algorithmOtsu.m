% SMALL TEST IMAGE  :  'C:\Users\Master\Documents\MyWork\ProgIOPics\pic4x4\4x4png1.png'
% LENA TEST IMAGE   : 'C:\Users\Master\Documents\MyWork\ProgIOPics\lcnt24.png'
% 0. read image from file
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
imgHight=imgDimentions(1,1);
imgWidth=imgDimentions(1,2);
totalPixelNumber=imgWidth*imgHight;

% 1. make image grayscale
imgGS=img;
for i=1:1:imgHight 
    for j=1:1:imgWidth 
        gray=img(i,j,1)*.2126+img(i,j,2)*.7152+img(i,j,3)*.0722;
        gray=floor(gray); % округление до целых. отбрасываем дробный хвост
        imgGS(i,j,1)=gray; imgGS(i,j,2)=gray; imgGS(i,j,3)=gray;
    end
end;

% 2. get intensity histogram
aIntensityHistogram=zeros(1, 256);
pixelIntensity=0;
for i=1:1:imgHight 
    for j=1:1:imgWidth 
        pixelIntensity=imgGS(i,j);
        aIntensityHistogram(pixelIntensity+1)=aIntensityHistogram(pixelIntensity+1)+1;
    end
end;

% 3. get threshold level of binarization
sum=0; %summarized intensity of considered grayscale image
for i=1:1:256
    sum=sum+i*aIntensityHistogram(i);
end
sumB=0; % суммарная яркость множества набираемых пикселей
sumF=0; % суммарная яркость уменьшаемого множества пикселей
mB=0; % средняя яркость пикселя в набираемом множестве
mF=0; % средняя яркость пикселя в уменьшаемом множестве
wB=0; % количество пикселей в набираемом множестве 
wF=0; % количество пикселей в уменьшаемом множестве 
varianceBetween=0;
varianceMax=0;
thresholdLevel=0;

for i=1:1:256
    wB=wB+aIntensityHistogram(i);
    if (wB==0) 
        continue;
    end
    wF=totalPixelNumber-wB;
    if(wF==0)
        break;
    end;
    sumB=sumB+i*aIntensityHistogram(i);
    sumF=sum-sumB;
    mB=sumB/wB;
    mF=sumF/wF;
    varianceBetween= wB*wF*((mB-mF)*(mB-mF));
    if (varianceBetween>varianceMax)
        varianceMax=varianceBetween; 
        thresholdLevel=i;
    end;
end;


% 4. binarization
imgBW=imgGS;
for i=1:1:imgHight
    for j=1:1:imgWidth
        if( imgGS(i,j,1)<=thresholdLevel )
            imgBW(i,j,1)=0; imgBW(i,j,2)=0; imgBW(i,j,3)=0;
        elseif( imgGS(i,j,1)>thresholdLevel )
            imgBW(i,j,1)=256; imgBW(i,j,2)=256; imgBW(i,j,3)=256;
        end;
    end;
end;

imshow(imgBW)

% 5.изменить название
splitedString = strsplit(fileName,'.');
fileTitle=char(splitedString(1));
fileNameNew=strcat(fileTitle,'_Otsu',num2str(thresholdLevel),'.png'); % fileExtension
pathToFileNew=fullfile(pathToFolder,fileNameNew);
% -- и сохранить в туже папку
imwrite(imgBW, pathToFileNew);

