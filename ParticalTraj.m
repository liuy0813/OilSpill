function [time,xx,yy]=ParticalTraj(ParticalPath,casename,ParticalNr,hours,xmlname);
%
% ��functionĿ����ͨ����ȡcaseĿ¼�е�xml�ļ����õ���������
% ��ͬʱ��������λ����Ϣ
% time(ParticalNr,hours(end)*3600/str2double(Timestep)-1)
% xx yy ά����timeһ��
%
xmlfile=[ParticalPath,casename,'.m21fm - Result Files\',xmlname]
fid=fopen(xmlfile,'r');
while ~feof(fid)
    tline=fgetl(fid);
    if ~isempty(tline)
        %
        % <TimeStepSeconds>1800</TimeStepSeconds>
        %
        if length(tline)>16
            if strcmp(tline(1:17),'<TimeStepSeconds>')
                tmpind0=find(tline=='>');tmpind1=find(tline=='<');
                Timestep=tline(tmpind0(1)+1:tmpind1(2)-1);
            end
        end
        %
        % <StartTime>2015-07-16 17:30:00</StartTime>
        %
        if length(tline)>10
            if strcmp(tline(1:11),'<StartTime>');
                tmpind0=find(tline=='>');tmpind1=find(tline=='<');
                StartTime=tline(tmpind0(1)+1:tmpind1(2)-1);
            end
        end
        %
        % <ExpectedEndTime>2015-07-19 17:30:00</ExpectedEndTime>
        %
        if length(tline)>16
            if strcmp(tline(1:17),'<ExpectedEndTime>');
                tmpind0=find(tline=='>');tmpind1=find(tline=='<');
                EndTime=tline(tmpind0(1)+1:tmpind1(2)-1);
                break;
            end
        end
    end
end
disp(['ModelStartTime is ',StartTime])
disp(['ModelEndTime   is ',EndTime])
disp(['ModelTimestep  is ',Timestep])
res='y';%input('Is this Setup Right ?  y/n: ','s');
if strcmp(res,'y')
else
   error('Check Your Model Setup and Try again!');
end
ii=2;
%
% Ԥ�����ڴ�
%
time=zeros(ParticalNr,hours(end)*3600/str2double(Timestep)-1);
xx=time;yy=time;
while ~feof(fid)
    %
    % �������ͷ�1h��ʼ��,ǰһ��Сʱ���������ͷŽ׶�
    %
    while ii < hours(end)*3600/str2double(Timestep)+1
        Time0=datestr(datenum(StartTime)+ii*str2double(Timestep)/3600/24,'yyyy-mm-dd hh:MM:ss');
        %
        %�����ȡ����ʱ���� <DateTime>2015-07-16 18:30:00</DateTime>
        %
        tline=fgetl(fid);
        if strcmp(tline,['<DateTime>',Time0,'</DateTime>'])
            for jj=1:ParticalNr
                tline=fgetl(fid);  % </Particle>
                tline=fgetl(fid);  % <Particle Nr="2">
                tmpind0=find(tline=='=');tmpind1=find(tline=='"');
                Nr0=tline(tmpind0+2:tmpind1(2)-1);
                if jj~=str2double(Nr0)
                    error('��ȡ���ӹ켣��x yʱ������ID����')
                end
                tline=fgetl(fid);
                tmpind0=find(tline=='[');tmpind1=find(tline==',');
                time(jj,ii-1)=ii*str2double(Timestep)/3600;
                xx(jj,ii-1)=str2double(tline(tmpind0(2)+1:tmpind1(1)-1));
                yy(jj,ii-1)=str2double(tline(tmpind1(1)+1:tmpind1(2)-1));
            end
            tline=fgetl(fid); % </Particle>
            tline=fgetl(fid); % </ParticleClass>
            tline=fgetl(fid); % </TimeStep>
            tline=fgetl(fid); % <TimeStep nr="516">
            ii=ii+1;
        end
    end
end
fclose(fid);
                        