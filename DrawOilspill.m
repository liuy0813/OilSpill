close all;clear all;clc ; 
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
%% ==输入部份
Mainpath='f:\work\金塘大桥\验证\溢油\溢油Mike\';
meshfile=[Mainpath,'0.mesh'];
coastline='f:\work\金塘大桥\验证\溢油\matlab\溢油matlab\useful\JinTangMap.xyz';
BaoHuQu='f:\work\金塘大桥\验证\溢油\matlab\溢油matlab\useful\BaoHuQumap.xyz';
Hangxian='f:\work\金塘大桥\验证\溢油\溢油Mike\航线管道\';
ZoneArea='ZoneArea.xlsx';
DB={'H4';'H9'};
CS={'低平';'高平'};
CASE={'noW';'NW';'SE';'SW'};
hours=[1,3,6,12,24,48,72];
FigSavePath=[Mainpath,'ResFig'];
landcolor=[255 255 169]./255;
indtmp=0;
hours=[1,3,6,12,24,48,72];
%% ==输入部份
%
% 读取网格文件信息
%
[tn,Nodes,proj,zUnitKey] = mzReadMesh(meshfile);
return
xn=Nodes(:,1);yn=Nodes(:,2);zn=Nodes(:,3);
% also calculate element center coordinates
[xe,ye,ze] = mzCalcElmtCenterCoords(tn,xn,yn,zn);
%
% 初始化文件夹
%
if exist(FigSavePath,'dir')
    rmdir(FigSavePath,'s')
    mkdir(FigSavePath)
else
    mkdir(FigSavePath)
end
%% Main
%
for ii=1:length(DB)        %Oil Spill Location
    for jj=1: length(CS)     %tidal
        for kk=1: length(CASE) %wind case
            for ll=1:length(hours)                
                casename=[cell2mat(DB(ii)),'+',cell2mat(CS(jj)),'+',cell2mat(CASE(kk))];
                %
                % 控制图的范围
                %
                [lon0,lon1,lat0,lat1,...
                 Northx,Northy,...
                 Xratio,Yratio,BarRatio,...
                 ZSx0,ZSy0,ZSang,...
                 CZx0,CZy0,CZang,...
                 NBx0,NBy0,NBang,mmoffset...
                 xxofftmp,ratiotmp,BarRatiox]=xylim(ZoneArea,casename);
                infile = [Mainpath,casename,'.m21fm - Result Files\',num2str(hours(ll)),'hmax.dfsu'];
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
                h=fig('units','inches','width',Xratio,'height',Yratio);
                [C,h]=tricontf(xn,yn,tn,hn,[0.001 0.015 0.025 0.035 0.045 0.055 0.065 0.075 0.085 0.095]); %  0.5:0.5:8.0
                set(h,'EdgeColor','none')
                colortmp=colormap(mikecolortmp);
                hc=colorbar('Fontname','Times New Roman','Fontsize',10);
                TitleColor=get(hc,'Title');                FigPos=get(gca,'Position');               CbarPos=get(hc,'Position');
                xxoffset=0.045 ; %(Northx-lon0)/(lon1-lon0)*FigPos(3)-0.012;
                set(hc,'Position',[0.075+xxoffset+xxofftmp 0.0899+0.01 CbarPos(3)*BarRatiox CbarPos(4)*BarRatio]);
                set(TitleColor,'string','(mm)','Fontsize',10,'position',[FigPos(1)+4.2 FigPos(2)+0.0120+mmoffset]);
                set(hc,'xtick',(0:0.02:0.10),'TickLength',[0.00001 0.000001]);
                set(hc,'yticklabel',sprintf('%03.2f|',get(hc,'ytick')),'Fontname','Times New Roman','Fontsize',8);
                %
                %  航线管道部分
                %
                hold on
                wmask_bhq(BaoHuQu);
                hold on
                DrawHangxian(Hangxian,coastline,landcolor,...
                             ZSx0,ZSy0,ZSang,...
                             CZx0,CZy0,CZang,...
                             NBx0,NBy0,NBang);
                xlim([lon0,lon1]);ylim([lat0,lat1]);
                xtick1=get(gca,'xtick');ytick1=get(gca,'ytick');
                set(gca,'xtick',xtick1(1:end));
                set(gca,'xticklabel',sprintf('%8.0f|',get(gca,'xtick')),'Fontname','Times New Roman','Fontsize',10);
                set(gca,'ytick',ytick1);
                set(gca,'Yticklabel',sprintf('%07.0f|',get(gca,'ytick')),'Fontname','Times New Roman','Fontsize',10);
                %
                % 溢油点位置
                %
                if ii==1
                    plot(375524.2834,3327998.1492,'ko','Markersize',6,'MarkerFaceColor','r');
                else
                    plot(383957.5536,3328940.7712,'ko','Markersize',6,'MarkerFaceColor','r');
                end
                %
                % 指北针
                %
                hold on
                comprose(Northx,Northy,1,(lon1-lon0)*Xratio*0.01*ratiotmp,0,15) %,20,'LineWidth',2,'FaceColor',.5*[1,1,1])
                set(gcf,'PaperpositionMode','auto');
                id0=find(infile=='.');
                filename=[FigSavePath,infile(26:id0(1)-1),num2str(hours(ll)),'hours'];
                exportfig(gcf,filename,'Color','rgb','format','png','resolution',300);
                close;
%                 return
        end
    end
end
end