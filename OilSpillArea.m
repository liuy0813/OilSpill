%
%% 统计油膜面积和扫海面积的程序
% liuy 20151021
% 1.Calc Element area
% 2.From start time to specific Time, the Max value of Each element 
% 3.If Max value >0 sum(element area)
% 4.Output
% 需要注意的地方 读取变量时要确认是否是你想要读取的变量
% 数据保存时，保存1h 3h 6h 12h 24h 48h 72h 的结果
% 统计扫海面积，油膜面积部分较简单
% 扫海面积读取各个dfsu中变量在每个单元上的值，在时间上取一个最大值，对该值大于0的单元面积求和
% 油膜面积，变量值取的是读取出来的变量值的最后一步，同上步，对值大于0的单元面积求和
%                     
% 主要复杂的是输出部分,需要输出成特定格式的表格
% 
close all;clear all;clc
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
%
% Input part
% 
Mainpath='f:\work\金塘大桥\验证\溢油\溢油Mike\';
DB={'H4';'H9'};
CS={'低平';'高平'};
CASE={'noW';'NW';'SE';'SW'};
hours=[1,3,6,12,24,48,72];
outputfile=[Mainpath,'溢油统计.csv'];
ind=1;
numid=1; %默认读取dfsu中的第一个变量
TotalCaseNum=length(DB)*length(CS)*length(CASE)*length(hours);
t1=clock;
%
%
fid=fopen(outputfile,'w');
for ii=1:length(DB)        %Oil Spill Location
    fprintf(fid,'%4s\n',cell2mat(DB(ii)));
    fprintf(fid,'%4s %4s %4s %2s %2s %2s %3s %3s %3s %3s\n','潮型,','风况,','项目,',...
    '1h,','3h,','6h,','12h,','24h,','48h,','72h,');
    for jj=1:length(CS)     %tidal
        fprintf(fid,'%2s',[cell2mat(CS(jj)),',']); 
        for kk=1:length(CASE) %wind case
            if kk==1
                fprintf(fid,' %4s',[cell2mat(CASE(kk)),',']);
            else
                fprintf(fid,' %s %2s',' ,',[cell2mat(CASE(kk)),',']);
            end
            for ll=1:length(hours)
                casename=[cell2mat(DB(ii)),'+',cell2mat(CS(jj)),'+',cell2mat(CASE(kk))];
                infile = [Mainpath,casename,'.m21fm - Result Files\',num2str(hours(ll)),'h.dfsu'];
                if (~exist(infile,'file'))
                    disp([casename,'   ',num2str(kk),' hour'])
                    [filename,filepath] = uigetfile('*.dfsu','Select the .dfsu file to analyse');
                    infile = [filepath,filename];
                end
                dfsu2 = DfsFileFactory.DfsuFileOpen(infile);
                % Node coordinates
                xn = double(dfsu2.X);yn = double(dfsu2.Y);zn = double(dfsu2.Z);
                % Create element table in Matlab format
                tn = mzNetFromElmtArray(dfsu2.ElementTable);
                %
                % Attention ! the area Calc From matlab are little different from MIKE2012
                %
                area = mzCalcElmtArea(tn,[xn;yn]');
                % Read item information
                items = {};
                for i = 0:dfsu2.ItemInfo.Count-1
                    item = dfsu2.ItemInfo.Item(i);
                    items{i+1,1} = char(item.Name);
                    items{i+1,2} = char(item.Quantity.Unit);
                    items{i+1,3} = char(item.Quantity.UnitAbbreviation); 
                end
                nsteps = dfsu2.NumberOfTimeSteps;
                if ind==1
                    disp(['该dfsu中共有 ',num2str(dfsu2.ItemInfo.Count),' 个变量'])
                    disp('变量信息为')
                    disp(items)
                    disp(['本脚本读取的变量为 ',items(numid,1)])
                    result=input('是否为你所需要读取的变量,y/n : ','s');
                    if strcmp(result,'y')
                    else
                        numid=input('请输入需要的是第几个变量： ')
                    end
                else                 
                end
                disp(['程序已完成 ',sprintf('%6.2f',ind/TotalCaseNum*100), ' %','  用时 ',sprintf('%10.2f',etime(clock,t1)),' s']);
                ind=ind+1;
                %
                % Read all domain bed thick of each timestep
                %
                h=zeros(length(area),nsteps);
                for nn=0:nsteps-1
                    h(:,nn+1) = double(dfsu2.ReadItemTimeStep(numid,nn).Data)';
                end
                %%  ==== For SaoHaiArea  ==== %%
                %
                % Calc Max value alone time diamension
                %
                h0=max(h,[],2);
                SaoHaiArea(ll)=sum(area(h0>0))/1000000;
                %%  ====    End          ==== %%
                %%  ==== For YouMoArea  ==== %%
                %
                % Read the last step of h 
                %
                h1=h(:,end);
                YouMoArea(ll)=sum(area(h1>0))/1000000;
                % clear for memory
                h=[];clear h h1 h0
                %%  ====    End          ==== %%
                dfsu2.Close();
            end
            fprintf(fid,'%4s %8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s\n',...
                    '扫海面积,',SaoHaiArea(1),',',SaoHaiArea(2),',',SaoHaiArea(3),','...
                    ,SaoHaiArea(4),',',SaoHaiArea(5),',',SaoHaiArea(6),',',SaoHaiArea(7),',');
            fprintf(fid,'%s %s%4s %8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s %8.4f%s\n',...
                    ' ,',' ,','油膜面积,',YouMoArea(1),',',YouMoArea(2),',',YouMoArea(3),','...
                    ,YouMoArea(4),',',YouMoArea(5),',',YouMoArea(6),',',YouMoArea(7),',');
        end
    end
end
fclose(fid);
dfsu2.Close();
