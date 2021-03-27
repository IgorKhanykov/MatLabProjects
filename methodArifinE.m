tic;
% 0] загрузить и подготовить изображение
% -- 0.1) считать выбранное изображение 
[fileName, pathToFolder]=uigetfile({'*.png'},'Select png-image...');
pathToFile=fullfile(pathToFolder, fileName);
if( size(pathToFile,2)==3)
    msgbox('Empty pathToFile');
    return;
end;
%img=imread('C:\Users\Master\Documents\MyWork\ProgIOPics\pic4x4\4x4png1','png');
img=imread(pathToFile);

% -- 0.2) создать пустую папку по адресу выбранного изображения
splitedString = strsplit(fileName,'.');
fileTitle=char(splitedString(1));
pathToFolderNew=fullfile(pathToFolder,fileTitle);
mkdir(pathToFolderNew);

% -- 0.3) перевести выбранное цветное изображение в оттенки серого
imgGS=img;
imgNumOfRows=size(img,1);
imgNumOfCols=size(img,2);
for i=1:1:imgNumOfRows
    for j=1:1:imgNumOfCols
        gray=0.299*img(i,j,1) + 0.587*img(i,j,2) + 0.114*img(i,j,3);
        imgGS(i,j,1)=gray; 
        imgGS(i,j,2)=gray; 
        imgGS(i,j,3)=gray; 
    end;
end;

% 1] создать базовые массивы.
% -- 1.1. создать массив яркостей
%aIntensities=   [100,101,102,103,104,105,106,107,108,109,110]; % шкала яркостей
%iIntensitiesLength=size(aIntensities,2);          % всего яркостей
aIntensities=zeros(1,256);
for i=1:1:256
    aIntensities(i)=i-1;
end;
iIntensitiesLength=256;

% -- 1.2. создать массив частот
%aFrequences=    [0,1,4,8,10,5,0,0,15,3,0];          % гистограмма частот яркостей
aFrequences=zeros(1,256);
for i=1:1:imgNumOfRows
    for j=1:1:imgNumOfCols
        iIntensity=imgGS(i,j,1);
        aFrequences(iIntensity+1)=aFrequences(iIntensity+1)+1;
    end;
end;
% -- пересчитать количество не "0-ых" яркостей
iIntensitiesNumOfNonEmpty=0;
for i=1:1:iIntensitiesLength
    if(aFrequences(i)~=0)
        iIntensitiesNumOfNonEmpty=iIntensitiesNumOfNonEmpty+1;
    end;
end;

% -- создать пустой массив кластеров
aClusters=zeros(1,iIntensitiesLength);
% -- 1.3.перенумеровать кластеры. одна яркость - один кластер, но "0-ые" яркости не образуют кластер
if(aFrequences(1)==0)
    aClusters(1)=1;
    k=1;
    for i=2:1:iIntensitiesLength
        if(aFrequences(i)==0)
            aClusters(i)=aClusters(i-1);
        else
            aClusters(i)=k;
            k=k+1;
        end;
    end;
else
    k=1;
    for i=1:1:iIntensitiesLength
        if(aFrequences(i)==0)
            aClusters(i)=aClusters(i-1);
        else
            aClusters(i)=k;
            k=k+1;
        end;
    end;
end;
iNumberOfClustersTotal=k-1;   % число кластеров
iNumberOfClustersLeft=iNumberOfClustersTotal;
if(iNumberOfClustersTotal==1)
    msgbox('1.3. число кластеров=1: Blank image');
    return;
end;
% -- создать пустой массив, хранящий число пикселей в каждом кластере
aNumberOfPixelsInClusters=zeros(1,iIntensitiesLength);
% -- 1.4. сосчитать и проставить число пикселей в каждом кластере.
iClusterToConsider=1;
iSumOfPixelsInCluster=0;
for i=1:1:iIntensitiesLength
    if(i<iIntensitiesLength &&  aClusters(i)==iClusterToConsider && aClusters(i+1)==iClusterToConsider)
        bFlag=true;
        j=i;
        while(bFlag==true && j<=iIntensitiesLength) % просуммировать пиксели по кластеру
            iSumOfPixelsInCluster=iSumOfPixelsInCluster+aFrequences(j);
            if(j==iIntensitiesLength)
                bFlag=false;
                continue;
            end;
            if(aClusters(j)~=aClusters(j+1))
                bFlag=false;
            end;
            j=j+1;
        end;
        bFlag=true;
        j=i;
        while(bFlag==true && j<=iIntensitiesLength) % прописать сумму пикселей в кластере в колонке каждой яркости
            aNumberOfPixelsInClusters(j)=iSumOfPixelsInCluster;
            if(j==iIntensitiesLength)
                bFlag=false;
                continue;
            end;
            if(aClusters(j)~=aClusters(j+1))
                bFlag=false;
            end;
            j=j+1;
        end;
        iSumOfPixelsInCluster=0;
        iClusterToConsider=iClusterToConsider+1;
    end;
    if(i<iIntensitiesLength && aClusters(i)==iClusterToConsider && aClusters(i+1)==iClusterToConsider+1)
        aNumberOfPixelsInClusters(i)=aFrequences(i);
        iClusterToConsider=iClusterToConsider+1;
    end;
    if(i==iIntensitiesLength && aClusters(i)==iClusterToConsider && aClusters(i-1)==iClusterToConsider-1)
        aNumberOfPixelsInClusters(i)=aFrequences(i);
    end;
end;
% -- создать пустой массив средних яркостей по кластерам
aMeanIntensitiesByClusters=zeros(1, iIntensitiesLength);
% -- 1.5.сосчитать и проставить среднюю яркость в каждом кластере
for i=1:1:iIntensitiesLength
    % если первая яркость оказалась "0-ой", то заполняем значением следующей не "0-ой"
    if(i==1 && aFrequences(i)==0)
        bFlag=true;
        j=i;
        while(bFlag==true)
            if(j==iIntensitiesLength+1)
                msgbox('1.5.: Blank image');
                return;
            end;
            if(aClusters(j)==1 && aFrequences(j)~=0)
                aMeanIntensitiesByClusters(i)=aIntensities(j);
                bFlag=false;
            end;
            j=j+1;
        end;
    end;
    % если очередная не "0-ая" яркость, то записать текущее значение
    if(aFrequences(i)~=0)
        aMeanIntensitiesByClusters(i)=aIntensities(i);
    end;
    % если очередная яркость оказывается "0-ой", то скопировать от предыдущей 
    if(i>1 && aFrequences(i)==0)
        aMeanIntensitiesByClusters(i)=aMeanIntensitiesByClusters(i-1);
    end;
end;
% -- создать пустой массив значений сум.кв.отклонения по каждому кластеру
adE=zeros(1,iIntensitiesLength);
% -- 1.6. сосчитать приращение сум.кв.отклонения dE
for i=1:1:iIntensitiesLength
    if(aClusters(i)==1)
        adE(i)=-1;
    end;
    if(aClusters(i)~=1 && aFrequences(i)~=0)
        n1=aNumberOfPixelsInClusters(i-1); 
        n2=aNumberOfPixelsInClusters(i);
        I1=aMeanIntensitiesByClusters(i-1); 
        I2=aMeanIntensitiesByClusters(i);
        adE(i)=n1*n2/(n1+n2)*(I1-I2)^2;
    end;
    if(aClusters(i)~=1 && aFrequences(i)==0)
        adE(i)=adE(i-1);
    end;
end;

% -- сохранить первое разбиение в созданную папку
fileNameNew=strcat(num2str(iIntensitiesNumOfNonEmpty),'_',num2str(0.0000),'.png');
pathToFileNew=fullfile(pathToFolderNew, fileNameNew);
imwrite(imgGS, pathToFileNew);

% -- сум.кв.откл.первого разбиения
iEtotal=0;
% -- найти пару кластеров, сопровождаемую минимальным приращеним сум.кв.откл.
idEmin=999999999999999; 
iPairMindE=0;
for i=1:1:iIntensitiesLength
    if(adE(i)~=-1 && adE(i)<idEmin)
        idEmin=adE(i);
        iPairMindE=aClusters(i);
    end;
end;

%-- пустой массив Сигм
aSigmaValue=zeros(1, iIntensitiesNumOfNonEmpty);
aSigmaIndex=zeros(1, iIntensitiesNumOfNonEmpty);
aSigmaIndex(iIntensitiesNumOfNonEmpty)=iIntensitiesNumOfNonEmpty-1;
aEValue=zeros(1, iIntensitiesNumOfNonEmpty);
aEIndex=zeros(1, iIntensitiesNumOfNonEmpty);
aEIndex(iIntensitiesNumOfNonEmpty)=iIntensitiesNumOfNonEmpty-1;

% 2] итеративное объединение пар кластеров.
for k=iIntensitiesNumOfNonEmpty:-1:2
    if(iPairMindE==0)
        msgbox('2] no more clusters to unite: iPairMindE==0');
        return;
    end;
    % -- 2.1) и 2.2)
    for i=1:1:iIntensitiesLength
        % -- 2.1) объединение яркостей в один кластер
        if(aClusters(i)==iPairMindE)
            aClusters(i)=aClusters(i)-1;
        end;
        % -- 2.2) перенумерация всех послед. кл-ров
        if(aClusters(i)>iPairMindE)
            aClusters(i)=aClusters(i)-1;
        end;
    end;
    iClusterUnited=iPairMindE-1;
    iNumberOfClustersLeft=iNumberOfClustersLeft-1;
    % -- сум.кв.откл.очередного разбиения
    iEtotal=iEtotal+idEmin;

    % -- 2.3) подсчет числа пикс. n в укруп.кл.
    iSumOfPixelsInCluster=0;
    for i=1:1:iIntensitiesLength
        if(aClusters(i)==iClusterUnited)
            iSumOfPixelsInCluster=iSumOfPixelsInCluster+aFrequences(i);
        end;
         if(aClusters(i)>iClusterUnited)
             break;
         end;
    end;
    % -- 2.4) запись значения n во все клетки укруп.кл.
    for i=1:1:iIntensitiesLength
        if(aClusters(i)==iClusterUnited)
            aNumberOfPixelsInClusters(i)=iSumOfPixelsInCluster;
        end;
        if(aClusters(i)>iClusterUnited)
             break;
         end;
    end;
    % -- 2.5) расчет знач.средн.ярк. I в укрупн.кл. 
    iIntensitySummarized=0;
    for i=1:1:iIntensitiesLength
        if(aClusters(i)==iClusterUnited)
            iIntensitySummarized=iIntensitySummarized+aIntensities(i)*aFrequences(i);
        end;
        if(aClusters(i)>iClusterUnited)
             break;
         end;
    end; 
    iMeanIntensityInCluster=iIntensitySummarized/iSumOfPixelsInCluster;
    % -- 2.6) запись значения I во все клетки укрупн.кл.
    for i=1:1:iIntensitiesLength
        if(aClusters(i)==iClusterUnited)
            aMeanIntensitiesByClusters(i)=iMeanIntensityInCluster;
        end;
        if(aClusters(i)>iClusterUnited)
             break;
         end;
    end;     
    % -- 2.7) (ПРОПУСК: первый кл.) расчет dE для пары пред.-тек.кл. 
    if(iClusterUnited>1)
        for i=2:1:iIntensitiesLength
            if(aClusters(i-1)==aClusters(i) && aClusters(i)==iClusterUnited)
                break;
            end;
            if(aClusters(i)==iClusterUnited)
                n1=aNumberOfPixelsInClusters(i-1); 
                n2=aNumberOfPixelsInClusters(i);
                I1=aMeanIntensitiesByClusters(i-1); 
                I2=aMeanIntensitiesByClusters(i);
                idE=n1*n2/(n1+n2)*(I1-I2)^2;
            end;
        end;
    else
        idE=-1;
    end;
    % -- 2.8) запись значения dE в ячейки тек.кл.: либо контрольного зн.dE=-1, либо рассчетного 
    for i=1:1:iIntensitiesLength
        if(aClusters(i)==iClusterUnited)
            adE(i)=idE;
        end;
        if(aClusters(i)>iClusterUnited)
            break;
        end;
    end;
    % -- 2.9) расчет dE для пары тек.-след.кл. 
    if(iClusterUnited+1<=iNumberOfClustersLeft)
        for i=2:1:iIntensitiesLength
            if((aClusters(i-1)==iClusterUnited+1) && (aClusters(i)==iClusterUnited+1))
                break;
            end;
            if((aClusters(i-1)==iClusterUnited+1) && (aClusters(i)>iClusterUnited+1))
                break;
            end;
            if(aClusters(i)==iClusterUnited+1)
                n1=aNumberOfPixelsInClusters(i-1); 
                n2=aNumberOfPixelsInClusters(i);
                I1=aMeanIntensitiesByClusters(i-1); 
                I2=aMeanIntensitiesByClusters(i);
                idE=n1*n2/(n1+n2)*(I1-I2)^2;
            end;
        end;
    end;
    % -- 2.10) запись значения dE во все клетки след.кл.
    if(iClusterUnited+1<=iNumberOfClustersLeft)
        for i=1:1:iIntensitiesLength
            if(aClusters(i)==iClusterUnited+1)
                adE(i)=idE;
            end;
            if(aClusters(i)>iClusterUnited+1)
                break;
            end;
        end;
    end;
    
    if(iNumberOfClustersLeft<11)
        % вывод очередного разбиения в память
        % -- сгенерировать разбиение на кластеры
        imgPartition=imgGS;
        grayNew=0;
        for i=1:1:imgNumOfRows
            for j=1:1:imgNumOfCols
                grayOld=imgGS(i,j,1);
                grayNew=aMeanIntensitiesByClusters(1,grayOld+1);
                %for m=1:1:iIntensitiesLength 
                %    if(aIntensities(1,m)==grayOld) 
                %        grayNew=aMeanIntensitiesByClusters(1,m); 
                %        break; 
                %    end;
                %end;
                imgPartition(i,j,1)=grayNew;
                imgPartition(i,j,2)=grayNew;
                imgPartition(i,j,3)=grayNew;
            end;
        end;
    end;
    
    iSigma=sqrt(iEtotal/imgNumOfRows/imgNumOfCols);
    % -- записть iSigma в массив для вывода графика на экран
    aSigmaValue(k-1)=iSigma;
    aSigmaIndex(iIntensitiesNumOfNonEmpty-k+1)=iIntensitiesNumOfNonEmpty-k;
    aEValue(k-1)=iEtotal;
    aEIndex(iIntensitiesNumOfNonEmpty-k+1)=iIntensitiesNumOfNonEmpty-k;
    
    if(iNumberOfClustersLeft<11)
        % -- записать изображение в созданную папку
        fileNameNew=strcat(num2str(iNumberOfClustersLeft),'_',num2str(iSigma),'.png');
        pathToFileNew=fullfile(pathToFolderNew, fileNameNew);
        imwrite(imgPartition, pathToFileNew);
    end;
    % -- 2.11) выбор пары dE=min>0
    idEmin=999999999999999999999999999999999999999999999999999999999999999999999999999; 
    iPairMindE=0;
    for i=1:1:iIntensitiesLength
        if(adE(i)~=-1 && adE(i)<idEmin)
            idEmin=adE(i);
            iPairMindE=aClusters(i);
        end;
    end;

end;%for k=iIntensitiesNumOfNonEmpty:-1:2
toc
% графики Сигма(k), E(k)
plot(aSigmaValue);%aEValue
% для изображений из оттенков серого о.д.з. Сигма [0,127.5] 