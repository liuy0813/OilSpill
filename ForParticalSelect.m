%
% Partical Tracking
% 2015-10-29 10:00:20
% 1.画出油膜1h 3h 6h 12h 24h 48h 72h 的分布情况，去掉航道管线、保护区及指北针，减少代码量
% 2.通过读取xml文件，总共50个粒子，建立50个文件夹，
%   将每个粒子的轨迹情况和油膜分布情况放到其文件夹内
% 3.Select it !!
% 4.Good Luck !!
%
close all;clear all;clc
%
% 第一部分  油膜分布情况
%
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
%% ==输入部份
Mainpath='f:\work\金塘大桥\验证\溢油\溢油Mike\';
meshfile=[Mainpath,'0.mesh'];
coastline='f:\work\金塘大桥\验证\溢油\matlab\溢油matlab\useful\JinTangMap.xyz';
BaoHuQu='f:\work\金塘大桥\验证\溢油\matlab\溢油matlab\useful\BaoHuQumap.xyz';
Hangxian='f:\work\金塘大桥\验证\溢油\溢油Mike\航线管道\';
Particalpath='f:\work\金塘大桥\验证\溢油\溢油Mike_Partical_Matlab\'; %轨迹目录
ZoneArea='ZoneArea.xlsx';
DB={'H4';'H9'};
CS={'低平';'高平'};
CASE={'noW';'NW';'SE';'SW'};
%
% 第二部分  粒子信息
%
hours=[1,3,6,12,24,48,72];
ParticalNr=50;
xmlname='72hmax.xml';
landcolor=[255 255 169]./255;
indtmp=0;
%% ==输入部份
%
% 读取网格文件信息
%
[tn,Nodes,proj,zUnitKey] = mzReadMesh(meshfile);
xn=Nodes(:,1);yn=Nodes(:,2);zn=Nodes(:,3);
% also calculate element center coordinates
[xe,ye,ze] = mzCalcElmtCenterCoords(tn,xn,yn,zn);
%% Main
%
t1=clock;
for ii=2:length(DB)        %Oil Spill Location
    for jj=1:length(CS)     %tidal
        for kk=1:length(CASE) %wind case
            for ll=1:ParticalNr
                casename=[cell2mat(DB(ii)),'+',cell2mat(CS(jj)),'+',cell2mat(CASE(kk))];
                %
                % 通过读取控制文件内的信息，控制图片生成情况
                %
                [lon0,lon1,lat0,lat1,Northx,Northy,Xratio,Yratio,BarRatio]=xylim(ZoneArea,casename);
                infile = [Particalpath,casename,'.m21fm - Result Files\72hmax.dfsu'];
                if (~exist(infile,'file'))
                    disp([casename,'   ',num2str(kk),' hour'])
                    [filename,filepath] = uigetfile('*.dfsu','Select the .dfsu file to analyse');
                    infile = [filepath,filename];
                end
                dfsu2 = DfsFileFactory.DfsuFileOpen(infile);
                NtoE = tritables(tn);                 
                % Read some item information
                items = {};
                for i = 0:dfsu2.ItemInfo.Count-1
                    item = dfsu2.ItemInfo.Item(i);
                    items{i+1,1} = char(item.Name);
                    items{i+1,2} = char(item.Quantity.Unit);
                    items{i+1,3} = char(item.Quantity.UnitAbbreviation); 
                end
                nsteps = dfsu2.NumberOfTimeSteps;
                h = double(dfsu2.ReadItemTimeStep(1,nsteps-1).Data)';
                h =  h*1000;
                % Calculate node values of h
                [hn] = mzCalcNodeValues(tn,xn,yn,h,xe,ye,NtoE);               
                %New figure
                disp(['lon0=',sprintf('%8.0f ',lon0),' lon1=',sprintf('%8.0f ',lon1)])
                disp(['lat0=',sprintf('%7.0f ',lat0),' lat1=',sprintf('%7.0f ',lat1)])
                %
                %  粒子情况
                %
                [time,xx,yy]=ParticalTraj(Particalpath,casename,ParticalNr,hours,xmlname);
                %
                h=fig('units','inches','width',Xratio,'height',Yratio);
                [C,h]=tricontf(xn,yn,tn,hn,[0.001 0.015 0.025 0.035 0.045 0.055 0.065 0.075 0.085 0.095 0.105]); %  0.5:0.5:8.0
                set(h,'EdgeColor','none')
                colortmp=colormap(mikecolortmp);
                hc=colorbar('Fontname','Times New Roman','Fontsize',10);
                TitleColor=get(hc,'Title');                FigPos=get(gca,'Position');               CbarPos=get(hc,'Position');
                xxoffset=0.045 ; %(Northx-lon0)/(lon1-lon0)*FigPos(3)-0.012;
                set(hc,'Position',[0.075+xxoffset 0.0899+0.01 CbarPos(3) CbarPos(4)*BarRatio]);
                set(TitleColor,'string','(mm)','Fontsize',10,'position',[FigPos(1)+4.2 FigPos(2)+0.0230]);
                set(hc,'xtick',(0:0.02:0.10),'TickLength',[0.00001 0.000001]);
                set(hc,'yticklabel',sprintf('%03.2f|',get(hc,'ytick')),'Fontname','Times New Roman','Fontsize',8);
                %
                xlim([lon0,lon1]);ylim([lat0,lat1]);
                xtick1=get(gca,'xtick');ytick1=get(gca,'ytick');
                set(gca,'xtick',xtick1(1:end));
                set(gca,'xticklabel',sprintf('%8.0f|',get(gca,'xtick')),'Fontname','Times New Roman','Fontsize',10);
                set(gca,'ytick',ytick1);
                set(gca,'Yticklabel',sprintf('%07.0f|',get(gca,'ytick')),'Fontname','Times New Roman','Fontsize',10);
                %
                % plot 粒子轨迹
                %
                hold on
                plot(xx(ll,:),yy(ll,:),'r','linewidth',1.5)
                hold on
                wmask(coastline,landcolor);
                set(gcf,'PaperpositionMode','auto');
                id0=find(infile=='.');
                FigSavePath=[Particalpath,casename,'.m21fm - Result Files\ResFig\'];
                if ll==1
                if exist(FigSavePath,'dir')
                    rmdir(FigSavePath,'s')
                    mkdir(FigSavePath)
                else
                    mkdir(FigSavePath)
                end
                end
                filename=[FigSavePath,'No_',sprintf('%03i',ll)];
                exportfig(gcf,filename,'Color','rgb','format','png','resolution',300);
                close;
%                 return
            end
        end
    end
end
Time0=etime(clock,t1)/60;
disp(['程序运行时间： ',sprintf('%15.7f',Time0),' mins']);