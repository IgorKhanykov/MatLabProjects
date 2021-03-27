function varargout = methodArifin(varargin)
% METHODARIFIN MATLAB code for methodArifin.fig
%      METHODARIFIN, by itself, creates a new METHODARIFIN or raises the existing
%      singleton*.
%
%      H = METHODARIFIN returns the handle to a new METHODARIFIN or the handle to
%      the existing singleton*.
%
%      METHODARIFIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in METHODARIFIN.M with the given input arguments.
%
%      METHODARIFIN('Property','Value',...) creates a new METHODARIFIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before methodArifin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to methodArifin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help methodArifin

% Last Modified by GUIDE v2.5 23-May-2019 17:11:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @methodArifin_OpeningFcn, ...
                   'gui_OutputFcn',  @methodArifin_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before methodArifin is made visible.
function methodArifin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to methodArifin (see VARARGIN)

% Choose default command line output for methodArifin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes methodArifin wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = methodArifin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Select_Pushbutton.
function Select_Pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% 0] ИСХОДНЫЕ данные
% -- выбрать изображение 
[fileName, pathToFolder]=uigetfile({'*.png'},'Select png-image...');
if isequal(fileName,0) 
    return; 
end;
pathToFile=fullfile(pathToFolder, fileName);
img=imread(pathToFile);

% -- создать пустую папку по адресу выбранного изображения для вывода результатов
splitedString = strsplit(fileName,'.');
fileTitle=char(splitedString(1));
pathToFolderNew=fullfile(pathToFolder,fileTitle);
mkdir(pathToFolderNew);

imgDimentions=size(img);        %get image dimentions
imgHight=imgDimentions(1);
imgWidth=imgDimentions(2);

% --  получить гистограмму яркостей
aFrequences=zeros(1,256);         % set empty intensity histogram
% convert color image to grayscale and get intensity histogram
for i=1:1:imgDimentions(1,1) % loop in rows
    for j=1:1:imgDimentions(1,2) % loop in coloms
        pixel.compRed=img(i,j,1); % get components
        pixel.compGreen=img(i,j,2);
        pixel.compBlue=img(i,j,3); 
        
        gray =  pixel.compRed * .2126 + pixel.compGreen * .7152 + pixel.compBlue * .0722;
        img(i,j,1)=gray;
        img(i,j,2)=gray;
        img(i,j,3)=gray;
        gray=floor(gray); % округление до целых. обрасываем дробный хвост
%         if(gray<0 || gray>255) gray 
%         end;
        aFrequences(1,gray)=aFrequences(1,gray)+1; %
    end;
end;
imgGS=img;
% imshow(imgGS);
% plot(1:1:256, aFrequences);






t=2;                % t задает число различных уровней серого в конечном разбиении, 2<=t<K, max{K}=256
% aIntensitities=  [100,101,102,103,104,105,106,107,108,109,110]; % шкала яркостей
% aFrequences=    [3,1,4,8,10,5,0,0,15,3,1];          % гистограмма частот яркостей
aIntensitities=zeros(1,256);
for i=1:1:256
    aIntensitities(i)=i;
end;
numberOfPixelsTotal=sum(aFrequences);               % всего пикселей в изображении
aProbabilities= aFrequences./numberOfPixelsTotal;   % вероятность этой яркости 
aClusters=zeros(1, size(aIntensitities,2) );      % пустой массив кластеров [1,2,3,4,5,6,7,8,9,10,11]; %[1,1,1,2,2,3,4,5,6,7,8];

% 1] ФОРМИРОВАНИЕ БАЗОВОГО МАССИВА из гистограммы яркостей исключением пустых классов-столбцов
%-- сосчитать число baseLength ненулевых яркостей 
baseLength=0;
for i=1:1:size(aFrequences,2)
    if (aFrequences(i)==0) continue; else baseLength=baseLength+1; end;
end;
% -- создать пустой базовый массив aBase длины baseLength.
aBase=zeros(11,baseLength);
% -- записать в б.м. ненулевые стоблцы гистограммы яркости
n=1;
for i=1:1:size(aIntensitities,2)
   if (aFrequences(i)==0) continue; 
   % записать 1.ярокости, 2.частоты, 3.кластеры
   else aBase(1,n)=aIntensitities(1,i); aBase(2,n)=aFrequences(1,i); aBase(3,n)=n; aBase(4,n)=aProbabilities(i); n=n+1; 
   end;
end;
K=n-1;        % K задает число различных уровней серого в исходном наборе, K>t

% -- запись первого разбиения в папку
fileNameNew=strcat(num2str(K),'.png');
pathToFileNew=fullfile(pathToFolderNew, fileNameNew);
imwrite(img, pathToFileNew);

% 2] ЗАПОЛНЕНИЕ БАЗОВОГО МАССИВА
% Для первых двух кластеров рассчет prob, m, M, sigma и Dist 
consideredCluster=2;
%1. сосчитать верятность и 2.плотность вероятности пикселей входящих в кластер i
%3. сосчитать среднее значение кластера mi
[prob1, probDensity]=probabilityDensity(aBase, consideredCluster-1);
m1=probDensity/ prob1;
aBase(5,consideredCluster-1)=prob1;
aBase(6,consideredCluster-1)=m1; 

[prob2, probDensity]=probabilityDensity(aBase, consideredCluster);
m2=probDensity/ prob2;
aBase(5,consideredCluster)=prob2;
aBase(6,consideredCluster)=m2;

%5. inter-class variance
sigma2_inter=prob1*prob2/((prob1+prob2)*(prob1+prob2))*(m1-m2)*(m1-m2);
aBase(7,consideredCluster)=sigma2_inter;

%4. среднее обоих кластеров
M=(prob1*m1 + prob2*m2)/(prob1+prob2);
aBase(8,consideredCluster)=M;

%6. слогаемое сумма: consideredCluster<size(aBase,2)
summa=0; 
summa=probabilityDensityOfLeastSquareIntensity(aBase, M, consideredCluster);
aBase(9,consideredCluster)=summa;

%7. intra-class variance
sigma2_intra=summa/(prob1+prob2);
aBase(10,consideredCluster)=sigma2_intra;

%8.расстояния между кластерами
Dist=sigma2_inter*sigma2_intra;
aBase(11,consideredCluster)=Dist;

% Для оставшегося базового массива расчет prob, m, M, sigma и Dist в цикле, определение Dist(i-1,i)=min
DistMin=Dist; %39786732894291535047752038041559739510060813980024082; %?правомерно ли так?
clusterWithMinDist=2;
for consideredCluster=3:1:size(aBase,2)

    %извлечь ранее вычисленные значения среднего по кластеру m1, вероятности prob1
    prob1=aBase(5,consideredCluster-1);   
    m1=aBase(6,consideredCluster-1);

    % сосчитать новые значения prob2, m2, M, Sigmas, Dist и запомнить их значения
    [prob2, probDensity]=probabilityDensity(aBase, consideredCluster);
    m2=probDensity/ prob2;
    aBase(5,consideredCluster)=prob2;
    aBase(6,consideredCluster)=m2;
    
    sigma2_inter=prob1*prob2/((prob1+prob2)*(prob1+prob2))*(m1-m2)*(m1-m2);
    aBase(7,consideredCluster)=sigma2_inter;

    M=(prob1*m1 + prob2*m2)/(prob1+prob2);
    aBase(8,consideredCluster)=M;
    
    summa=0; 
    summa=probabilityDensityOfLeastSquareIntensity(aBase, M, consideredCluster);
    aBase(9,consideredCluster)=summa;
    
    sigma2_intra=summa/(prob1+prob2);
    aBase(10,consideredCluster)=sigma2_intra;
    
    Dist=sigma2_inter*sigma2_intra;
    aBase(11,consideredCluster)=Dist;

    % запоминанание минимального расстояния и пары кластеров
    if (Dist<DistMin)
        DistMin=Dist;
        clusterWithMinDist=consideredCluster;
    end;
end;

% 3] ОБЪЕДИНЕНИЕ КЛАСТЕРОВ
for L=K:-1:t+1
    %-- 1)_перенумерация кластеров правее объединяемых
    for m=1:1:size(aBase,2)
        if(aBase(3,m)==clusterWithMinDist) break; end;
    end;
    for i=m:1:size(aBase,2)
        aBase(3,i)=aBase(3,i)-1;
    end;
    clusterMerged=clusterWithMinDist-1;
    % -- 2) пересчет prob2, m2 для укрупн. кластера clusterMerged
    [prob2, probDensity]=probabilityDensity(aBase, clusterMerged);
     m2=probDensity/ prob2;
    % -- 3) запись значений prob2, m2 во все клетки, относящиеся к укрупн. кластеру clusterMerged
    for i=1:1:size(aBase,2)
        if (aBase(3,i)== clusterMerged) aBase(5,i)=prob2; aBase(6,i)=m2; end;
        if (aBase(3,i)> clusterMerged) break; end;
    end;
    % -- для пары кластреров (i-1, i) расчет 4)sigma2_inter  и 6)M
    for i=2:1:size(aBase,2)
        if(aBase(3,i)==clusterMerged)
            prob1=aBase(5,i-1);     m1=aBase(6,i-1);  
            prob2=aBase(5,i);       m2=aBase(6,i);
            sigma2_inter=prob1*prob2/((prob1+prob2)*(prob1+prob2))*(m1-m2)*(m1-m2);
            aBase(7,i)=sigma2_inter;

            M=(prob1*m1 + prob2*m2)/(prob1+prob2);
            aBase(8,i)=M;
            break;
        end;
    end;
    % -- скопировали 5) sigma2_inter и 7) M в ячейки aBase укруп.кластера i
    for m=i:1:size(aBase,2)
        if(aBase(3,m)==clusterMerged) 
            aBase(7,m)=sigma2_inter; aBase(8,m)=M; 
        else break; 
        end;
    end;

    % -- для пары (i,i+1) расчет и запись sigma2_inter, M, 
    for i=2:1:size(aBase,2)
        if( (aBase(3,i-1)==clusterMerged) && (aBase(3,i)==clusterMerged+1)) 
            prob1=aBase(5,i-1);     m1=aBase(6,i-1);
            prob2=aBase(5,i);       m2=aBase(6,i);
            sigma2_inter=prob1*prob2/((prob1+prob2)*(prob1+prob2))*(m1-m2)*(m1-m2);
            aBase(7,i)=sigma2_inter;

            M=(prob1*m1 + prob2*m2)/(prob1+prob2);
            aBase(8,i)=M;
            break;
        end;
    end
    % -- скопировали   sigma2_inter и M в ячейки aBase кластера i+1
    for m=i:1:size(aBase,2)
        if(aBase(3,m)==clusterMerged+1) 
            aBase(7,m)=sigma2_inter;  aBase(8,m)=M; 
        else break;
        end;
    end;
    
    % -- для пары (i-1,i) рассчитать summa 
    for i=2:1:size(aBase,2) %get M for summa
        if (aBase(3,i)==clusterMerged) M=aBase(8,i); break; end;
    end;
    summa=probabilityDensityOfLeastSquareIntensity(aBase, M, clusterMerged);
    % -- скопировать summa для яркостей укрупненного кластера
    for m=i:1:size(aBase,2)
        if(aBase(3,m)==clusterMerged) 
            aBase(9,m)=summa; 
        else break;
        end;
    end;
    
    % -- для пары (i,i+1) пересчитать summa 
    for i=2:1:size(aBase,2) %get M for summa
        if (aBase(3,i)==clusterMerged+1) M=aBase(8,i); break; end;
    end;
    summa=probabilityDensityOfLeastSquareIntensity(aBase, M, clusterMerged+1);
    % -- скопировать summa для яркостей кластера i+1
    for m=i:1:size(aBase,2)
        if(aBase(3,m)==clusterMerged+1) 
            aBase(9,m)=summa; 
        else break;
        end;
    end;
    
    % -- для пары (i-1,i) рассчитать sigma2_intra
    for i=2:1:size(aBase,2) %get M for summa
        if (aBase(3,i)==clusterMerged) summa=aBase(9,i); break; end;
    end;
    for i=2:1:size(aBase,2)
        if(aBase(3,i)==clusterMerged)
            prob1=aBase(5,i-1);     prob2=aBase(5,i);
            sigma2_intra=summa/(prob1+prob2);   aBase(10,i)=sigma2_intra;
            break;
        end;
    end;
    % -- скопировать sigma2_intra для яркостей укрупненного кластера
    for m=i:1:size(aBase,2)
        if(aBase(3,m)==clusterMerged) 
            aBase(10,m)=sigma2_intra;
        else break; 
        end;
    end;
    
    % -- для пары (i,i+1) пересчитать sigma2_intra 
    for i=2:1:size(aBase,2) %get M for summa
        if (aBase(3,i)==clusterMerged+1) summa=aBase(9,i); break; end;
    end;
    for i=1:1:size(aBase,2)-1
        if( (aBase(3,i)==clusterMerged) && (aBase(3,i+1)==clusterMerged+1) )
            prob1=aBase(5,i);                   prob2=aBase(5,i+1);
            sigma2_intra=summa/(prob1+prob2);   aBase(10,i+1)=sigma2_intra;
            break;
        end;
    end;
    % -- скопировать sigma2_intra для яркостей кластера i+1
    for m=i+1:1:size(aBase,2)
        if(aBase(3,m)==clusterMerged+1) 
            aBase(10,m)=sigma2_intra; 
        else break; 
        end;
    end;
    
    % -- сосчитать Dist и выбрать Dist(i,i-1)=min
    DistMin=39786732894291535047752038041559739510060813980024082;
    for i=2:1:size(aBase,2)
        Dist=aBase(7,i)*aBase(10,i);
        aBase(11,i)=Dist;
        if(Dist>0) 
            if (Dist<DistMin)  % запоминанание минимального расстояния и пары кластеров
                DistMin=Dist;
                clusterWithMinDist=aBase(3,i);
            end;
        end;
    end;
    % -- код формирования разбиения изображения по базовому массиву
    imgPartition=imgGS;
    for i=1:1:imgHight
        for j=1:1:imgWidth
            grayOld=imgGS(i,j);
            for m=1:1:baseLength 
                if(aBase(1,m)==grayOld) 
                    grayNew=aBase(6,m); break; 
                end;
            end;
            imgPartition(i,j,1)=grayNew;
            imgPartition(i,j,2)=grayNew;
            imgPartition(i,j,3)=grayNew;
        end;
    end;

    % -- запись очередного разбиения в папку
    fileNameNew=strcat(num2str(L-1),'.png');
    pathToFileNew=fullfile(pathToFolderNew, fileNameNew);
    imwrite(imgPartition, pathToFileNew);
end; %End of for L=K:-1:t+1

% -- генерация последнего разбиения в 1 кластер 
for m=1:1:baseLength
    if(aBase(3,m)==2)
        grayNew=aBase(8,m);
        break;
    end;
end;
for i=1:1:imgHight
    for j=1:1:imgWidth
        imgPartition(i,j,1)=grayNew;
        imgPartition(i,j,2)=grayNew;
        imgPartition(i,j,3)=grayNew;
    end;
end;
% -- запись последнего разбиения в 1 кластер в папку
fileNameNew=strcat(num2str(1),'.png');
pathToFileNew=fullfile(pathToFolderNew, fileNameNew);
imwrite(imgPartition, pathToFileNew);
