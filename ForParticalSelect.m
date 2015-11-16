%
% Partical Tracking
% 2015-10-29 10:00:20
% 1.������Ĥ1h 3h 6h 12h 24h 48h 72h �ķֲ������ȥ���������ߡ���������ָ���룬���ٴ�����
% 2.ͨ����ȡxml�ļ����ܹ�50�����ӣ�����50���ļ��У�
%   ��ÿ�����ӵĹ켣�������Ĥ�ֲ�����ŵ����ļ�����
% 3.Select it !!
% 4.Good Luck !!
%
close all;clear all;clc
%
% ��һ����  ��Ĥ�ֲ����
%
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
%% ==���벿��
Mainpath='f:\work\��������\��֤\����\����Mike\';
meshfile=[Mainpath,'0.mesh'];
coastline='f:\work\��������\��֤\����\matlab\����matlab\useful\JinTangMap.xyz';
BaoHuQu='f:\work\��������\��֤\����\matlab\����matlab\useful\BaoHuQumap.xyz';
Hangxian='f:\work\��������\��֤\����\����Mike\���߹ܵ�\';
Particalpath='f:\work\��������\��֤\����\����Mike_Partical_Matlab\'; %�켣Ŀ¼
ZoneArea='ZoneArea.xlsx';
DB={'H4';'H9'};
CS={'��ƽ';'��ƽ'};
CASE={'noW';'NW';'SE';'SW'};
%
% �ڶ�����  ������Ϣ
%
hours=[1,3,6,12,24,48,72];
ParticalNr=50;
xmlname='72hmax.xml';
landcolor=[255 255 169]./255;
indtmp=0;
%% ==���벿��
%
% ��ȡ�����ļ���Ϣ
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
                % ͨ����ȡ�����ļ��ڵ���Ϣ������ͼƬ�������
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
                %  �������
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
                % plot ���ӹ켣
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
disp(['��������ʱ�䣺 ',sprintf('%15.7f',Time0),' mins']);