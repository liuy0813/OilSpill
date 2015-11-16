%% ������
close all;clear all;clc
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;
%
% Input part
% 
Mainpath='f:\work\��������\��֤\����\����Mike\';
DB={'H4';'H9'};
CS={'��ƽ';'��ƽ'};
CASE={'noW';'NW';'SE';'SW'};
hours=[1,3,6,12,24,48,72];
outputfile=[Mainpath,'������ͳ��.csv'];
ind=1;   %��������չ
numid=1; %Ĭ�϶�ȡdfsu�еĵ�һ������
TotalCaseNum=length(DB)*length(CS)*length(CASE);
t1=clock;
%
%
fid=fopen(outputfile,'w');
for ii=1:length(DB)        %Oil Spill Location
    fprintf(fid,'%4s\n',cell2mat(DB(ii)));
    fprintf(fid,'%4s %4s %2s %2s %2s %3s %3s %3s %3s\n','����,','���,',...
    '1h,','3h,','6h,','12h,','24h,','48h,','72h,');
    for jj=1:length(CS)     %tidal
        fprintf(fid,'%2s',[cell2mat(CS(jj)),',']); 
        for kk=1:length(CASE) %wind case
            if kk==1
                fprintf(fid,' %4s',[cell2mat(CASE(kk)),',']);
            else
                fprintf(fid,' %s %2s',' ,',[cell2mat(CASE(kk)),',']);
            end
            casename=[cell2mat(DB(ii)),'+',cell2mat(CS(jj)),'+',cell2mat(CASE(kk))];
            infile = [Mainpath,casename,'.m21fm - Result Files\������.dfs0'];
            if (~exist(infile,'file'))
                [filename,filepath] = uigetfile('*.dfs0','Select the .dfs0');
                infile = [filepath,filename];
            end
    
            dfs0File  = DfsFileFactory.DfsGenericOpen(infile);
           %% Read times and data for all items
            % Use the Dfs0Util for bulk-reading all data and timesteps
            dd = double(Dfs0Util.ReadDfs0DataDouble(dfs0File));
            t = diff(dd(:,1));  %in seconds
            
           %% Read some item information
            items = {};
            for i = 0:dfs0File.ItemInfo.Count-1
                item = dfs0File.ItemInfo.Item(i);
                items{i+1,1} = char(item.Name);
                items{i+1,2} = char(item.Quantity.Unit);
                items{i+1,3} = char(item.Quantity.UnitAbbreviation); 
            end
            if ind==1
                    disp(['��dfsu�й��� ',num2str(dfs0File.ItemInfo.Count),' ������'])
                    disp('������ϢΪ')
                    disp(items)
                    disp(['���ű���ȡ�ı���Ϊ ',items(numid,1)])
                    result=input('�Ƿ�Ϊ������Ҫ��ȡ�ı���,y/n : ','s');
                    if strcmp(result,'y')
                    else
                        numid=input('��������Ҫ���ǵڼ��������� ')
                    end
            else                 
            end
            data =dd(:,numid+1); %������Ϊ�ڶ��е�ֵ
            disp(['��������� ',sprintf('%6.2f',ind/TotalCaseNum*100), ' %','  ��ʱ ',sprintf('%10.2f',etime(clock,t1)),' s']);
            ind=ind+1;
            % Residual Oil in Specific hours
            ResOil=zeros(length(hours));
            for ll=1:length(hours)
                ResOil(ll)=data(hours(ll)*3600/t(1)+1)./1000;
            end
            fprintf(fid,'%8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s\n',...
                    ResOil(1),',',ResOil(2),',',ResOil(3),','...
                    ,ResOil(4),',',ResOil(5),',',ResOil(6),',',ResOil(7),',');
        end
    end
end
fclose(fid);            
dfs0File.Close();