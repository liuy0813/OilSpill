function [xlim1,xlim2,ylim1,ylim2,Northx,Northy...
    Xratio,Yratio,BarRatio,ZSx0,ZSy0,ZSang,...
    CZx0,CZy0,CZang,NBx0,NBy0,NBang,mmoffset,...
    xxofftmp,ratiotmp,BarRatiox,ParticalNo]=xylim(ZoneArea,casename)
%
% 从excel文件中读取各个case图片的范围
%
[num,txt,raw]=xlsread(ZoneArea);
[ll kk]=size(raw);
casetmp={};
for ii=1:ll
    casetmp{ii}=raw(ii,1);
    if strcmp(casename,cell2mat(casetmp{ii}))
        break;
    end
end
xlim1=cell2mat(raw(ii,2));xlim2=cell2mat(raw(ii,3));
ylim1=cell2mat(raw(ii,4));ylim2=cell2mat(raw(ii,5));
Northx=cell2mat(raw(ii,6));Northy=cell2mat(raw(ii,7));
Xratio=cell2mat(raw(ii,8));Yratio=cell2mat(raw(ii,9));
BarRatio=cell2mat(raw(ii,10));
ZSx0=cell2mat(raw(ii,11));ZSy0=cell2mat(raw(ii,12));
ZSang=cell2mat(raw(ii,13));
CZx0=cell2mat(raw(ii,14));CZy0=cell2mat(raw(ii,15));
CZang=cell2mat(raw(ii,16));
NBx0=cell2mat(raw(ii,17));NBy0=cell2mat(raw(ii,18));
NBang=cell2mat(raw(ii,19));
mmoffset=cell2mat(raw(ii,20));
xxofftmp=cell2mat(raw(ii,21));
ratiotmp=cell2mat(raw(ii,22));
BarRatiox=cell2mat(raw(ii,23));
ParticalNo=cell2mat(raw(ii,24));