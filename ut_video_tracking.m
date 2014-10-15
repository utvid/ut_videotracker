function ut_video_tracking
clc
p = mfilename('fullpath');
[path,~,~] = fileparts(p);
cd(path);
addpath(genpath([path '\functions']));

warning off;
%% set up the main figure window
utvid =[];
monpos = get(0,'monitorposition');
if size(monpos,1) == 1                                  % there is only a primary monitor
    scrbase = monpos(1,1:2)+8;
    scrsize = (monpos(1,3:4)-monpos(1,1:2) - [8 62]);
else                                                    % there is a secondary monitor
    scrsize = (monpos(2,3:4)-monpos(2,1:2)  - [8 62]);
    scrbase(1) = monpos(2,1)+8;
    scrbase(2) = monpos(1,4)-monpos(2,4)+9;
end
if scrsize(1)/scrsize(2)>1.5, scrsize(1)=1.5*scrsize(2); end

scrsize = monpos(1,3:4);
winsize = [600 150];
scrbase = monpos(1,1:2)+0.5*scrsize - 0.5*winsize;

hMainFigure = figure('Color',[0.94 0.94 0.94],...
    'MenuBar','none',...
    'Name','UT VIDEO TRACKER',...
    'PaperPositionMode','auto',...
    'NumberTitle','off',...
    'Toolbar','none',...
    'Position',[scrbase winsize],...
    'Resize','off');

Nx = 4;     % number of buttons in hor direction
Ny = 3;     % number of buttons in ver direction
bsize = [winsize(1)/Nx winsize(2)/Ny];

nbutton = 1;
posx = mod(nbutton-1,Nx);
posy = floor(nbutton-1/Nx)+1;
utvid.handle.h1 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','INIT',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_initialise);

nbutton = 2;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h2 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','DEBAYER/COMPRESS',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_bayercompress);

nbutton = 3;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h3 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','CAM CALIBRATION',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_calibration);

nbutton = 4;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h4 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','SELECT MARKERS',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_markerselector);

nbutton = 5;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h5 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','IMAGE ENHANCEMENT',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_imenhance);

nbutton = 6;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h6 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','MAKE PCA',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_selectpca);

nbutton = 7;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h7 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','START TRACK',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@markertracker);

nbutton = 8;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h8 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','EXIT',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_close);


nbutton = 9;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h10 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2)+bsize(2)/2-5 bsize(1)*2 bsize(2)/2],...
    'Style','text',...
    'fontsize',10,...
    'string','Initialize previously used folders: ',...
    'horizontalalignment','left',...
    'enable','on');

try
    load historyfolder.mat
catch
    historyfolder = {''};
    save('historyfolder.mat','historyfolder');
end

utvid.settings.historyfolder = historyfolder;
utvid.settings.dir_data = 0;
if isempty(historyfolder)
    historyfolder = 'no folder selected yet';
end

nbutton = 9;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h9 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize(1)*2 bsize(2)/2],...
    'Style','popupmenu',...
    'fontsize',10,...
    'string',utvid.settings.historyfolder,...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_history);

guidata(hMainFigure,utvid);
end

%% initialise marker tracking process
function utvid_initialise(hMainFigure,utvid)
utvid = guidata(hMainFigure);
utvid = utvid_init(hMainFigure,utvid);

% make buttons of completed steps green
for i = 1:utvid.settings.state
    set(eval(['utvid.handle.h' num2str(i)]),'backgroundcolor','g');
end

guidata(hMainFigure,utvid)
end

%% close Marker Tracker GUI
function utvid_close(hMainFigure,utvid)
% utvid = guidata(hMainFigure);
delete(gcf);
end

%% Warning function for not yet implemented functions
function utvid_na(hMainFigure,utvid)
warndlg('not yet implemented',' ','modal')
end

%% Bayerfilter and compress videos
function utvid_bayercompress(hMainFigure,utvid);
utvid = guidata(hMainFigure);

prompt = 'Give standard name (e.g. NEW): ';
result = input(prompt,'s');
if isempty(result)
    utvid.setttings.stname = 'NEW'
else
    utvid.settings.stname = result;
end

% Ask for using compression or not
prompt = 'Use compression (y/n)? ';
result = input(prompt, 's');
if isempty(result)
    result = 'y';
end

while isempty(regexpi(result,'y'));
    if regexpi(result,'n')==1
        break
    else
        prompt = 'Use compression (y/n)? Please type y for yes or n for no: ';
        result = input(prompt, 's');
    end
end

% When using compression ask for video quality
if regexpi(result,'y')==1
    prompt = 'Set video quality (0 - 100): ';
    result = str2num(input(prompt,'s'));
    
    while isempty(result) || result<1 || result>100
        prompt = 'Set video quality (0 - 100), please type a number between 0 and 100: ';
        result = str2num(input(prompt,'s'));
    end
    utvid.settings.vidquality = result;
    utvid_bayerfilter(utvid,1);
else
    utvid_bayerfilter(utvid,0);
end

utvid.settings.state = 2; % update state
save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
guidata(hMainFigure,utvid);
set(utvid.handle.h2,'backgroundcolor','g');

end

%{
Ideas to add:
-   Choose compression method: motion jpg avi, motion jpg 2000 mpeg 4 etc
-   Choose new standard filenames for videos + location,
    these standard filenames must also be added to utvid_init
-   Connect corresponding videoclips to one recording
%}

%% Calibration process
function utvid_calibration(hMainFigure,utvid)
utvid = guidata(hMainFigure);
utvid.settings.camseq = {'left','right','center'};
utvid.settings.stname =[];
if strcmp(utvid.settings.version,'R2014') 
    utvid.settings.version = 'R2013';
end
for i = 1:utvid.settings.nrcams;
    if strcmp(utvid.settings.version,'R2012')
        I = read(VideoReader([utvid.settings.dir_data '\Calibration\'  utvid.settings.stname utvid.movs.calb.(utvid.settings.camseq{i})(1).name]),2);
        if size(I,3) == 1
            I = demosaic(I,'rggb');
        end
    elseif strcmp(utvid.settings.version,'R2013') 
        I = read(VideoReader([utvid.settings.dir_data '\Calibration\'  utvid.settings.stname utvid.movs.calb.(utvid.settings.camseq{i})(1).name]),1);
        if size(I,3) == 1
            I = demosaic(I,'rggb');
        end
    else
        disp('Version not yet implemented')
    end
    % calibration using script of Hageman and van der Heijden
    [K, R, T, P,Ximage,avgEr,stdEr] = utvid_camcalibration(I,50);
    utvid.calbMat.(utvid.settings.camseq{i}){1,1} = K;
    utvid.calbMat.(utvid.settings.camseq{i}){1,2} = R;
    utvid.calbMat.(utvid.settings.camseq{i}){1,3} = T;
    utvid.calbMat.(utvid.settings.camseq{i}){1,4} = P;
    utvid.calbMat.(utvid.settings.camseq{i}){1,5} = Ximage;
    utvid.calbMat.(utvid.settings.camseq{i}){1,6} = avgEr;
    utvid.calbMat.(utvid.settings.camseq{i}){1,7} = stdEr;
    utvid.calb{i}.P = utvid.calbMat.(utvid.settings.camseq{i}){1,4};
end

utvid.settings.state = 3; % update state
save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
guidata(hMainFigure,utvid);
set(utvid.handle.h3,'backgroundcolor','g');

end
%% Select markers
% ideas to add:
% manually select number of orientation and facial/lip markers
% search for ideal marker pixel after clicking
function utvid_markerselector(hMainFigure,utvid)
utvid = guidata(hMainFigure);
% 
% prompt = 'Use orientation markers (y/n)? Please type y for yes or n for no: ';
% result = input(prompt, 's');
% 
% if strcmp(result,'n')
%     utvid.settings.nrOrMar = 0;
%     prompt = 'How many markers to follow? ';
%     utvid.settings.nrMarkers = str2double(input(prompt, 's'));
% else
%     prompt = 'How many orientation markers to follow? ';
%     utvid.settings.nrOrMar = str2double(input(prompt, 's'));
%     if utvid.settings.nrOrMar < 3
%         prompt = 'At least 3 orientation markers needed. Do you still want to use orientation markers (y/n)? ';
%         utvid.settings.nrOrMar = str2double(input(prompt, 's'));
%         result = input(prompt, 's');
%         if strcmp(result,'n')
%             utvid.settings.nrOrMar = 0;
%         else
%             prompt = 'How many orientation markers to follow? Minimum of 3. ';
%             utvid.settings.nrOrMar = str2double(input(prompt, 's'));
%         end
%     end
%     
%     prompt = 'How many markers to follow? ';
%     utvid.settings.nrMarkers = str2double(input(prompt, 's'));
% end
% 
% %% check cameras for selecting cameras to use
% for j = 1
%     for i = 1:utvid.settings.nrcams;
%         if strcmp(utvid.settings.version,'R2012')
%             Im = read(VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.(utvid.settings.camseq{i})(1,utvid.movs.instrstart(j))).name]),2);
%         elseif strcmp(utvid.settings.version,'R2013')
%             Im = read(VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.(utvid.settings.camseq{i})(1,utvid.movs.instrstart(j))).name]),1);
%         else
%             disp('Version not yet implemented')
%         end
%         % check which camera didnot record anything useful
%         if j==1;
%             frames{i} = Im;
%             if i == utvid.settings.nrcams
%                 figure;
%                 subplot(1,3,1);imshow(frames{1},[]);
%                 subplot(1,3,2);imshow(frames{2},[]);
%                 subplot(1,3,3);imshow(frames{3},[]);
%                 utvid.Tracking.usecams = input('Which cameras to use (e.g. [1,3],[1,2], or  [1,2,3]? ');
%                 utvid.Tracking.nrcams = length(utvid.Tracking.usecams);
%             end
%         end
%     end
% end
% 
% for j = 1:size(utvid.movs.instrstart,2)
%     disp(['Instruction number: ' num2str(j)]);
%     for i = 1:length(utvid.Tracking.usecams);
%         if strcmp(utvid.settings.version,'R2012')
%             Im = read(VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.(utvid.settings.camseq{utvid.Tracking.usecams(i)})(1,utvid.movs.instrstart(j))).name]),2);
%         elseif strcmp(utvid.settings.version,'R2013')
%             Im = read(VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.(utvid.settings.camseq{utvid.Tracking.usecams(i)})(1,utvid.movs.instrstart(j))).name]),1);
%         else
%             disp('Version not yet implemented')
%         end
%         
%         if utvid.settings.nrOrMar == 0
%             [utvid.coords.shape.(utvid.settings.camseq{utvid.Tracking.usecams(i)}).x(:,j),utvid.coords.shape.(utvid.settings.camseq{utvid.Tracking.usecams(i)}).y(:,j)] = getPoints(Im,utvid.settings.nrMarkers,'Select shape markers');
%         else
%             [utvid.coords.or.(utvid.settings.camseq{utvid.Tracking.usecams(i)}).x(:,j),utvid.coords.or.(utvid.settings.camseq{utvid.Tracking.usecams(i)}).y(:,j)] = getPoints(Im,utvid.settings.nrOrMar,'Select Orientation markers');
%             [utvid.coords.shape.(utvid.settings.camseq{utvid.Tracking.usecams(i)}).x(:,j),utvid.coords.shape.(utvid.settings.camseq{utvid.Tracking.usecams(i)}).y(:,j)] = getPoints(Im,utvid.settings.nrMarkers,'Select shape markers');
%         end
%     end
% end

[utvid.Pstruct, utvid.Pstruct_or] = getPstruct(utvid.calb, utvid); % create Pstruct and Pstruct_or

utvid.settings.state = 4; % update state
save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
guidata(hMainFigure,utvid);
set(utvid.handle.h4,'backgroundcolor','g');

end
%% Image enhancement
function utvid_imenhance(hMainFigure,utvid)
utvid = guidata(hMainFigure);
utvid.enhancement.Trgb2gray = cell(size(utvid.movs.instrstart,2),length(utvid.Tracking.usecams));
utvid.enhancement.Trgb2gray_or = cell(size(utvid.movs.instrstart,2),length(utvid.Tracking.usecams));

for i = 1%:size(utvid.movs.instrstart,2)
    for j = 1:length(utvid.Tracking.usecams)
        vidnr = utvid.movs.(utvid.settings.camseq{utvid.Tracking.usecams(j)})(1,utvid.movs.instrstart(i)); % which video to load
        obj = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(vidnr).name]); % create videoreader object
        im = im2double(read(obj,1)); % load image
        
        % Enhance image by using 2 class problem quadratic mapping (shape
        % markers)
        coords.x = utvid.coords.shape.(utvid.settings.camseq{utvid.Tracking.usecams(j)}).x(:,i);
        coords.y = utvid.coords.shape.(utvid.settings.camseq{utvid.Tracking.usecams(j)}).y(:,i);
        
        if i == 1;
            [utvid.enhancement.Trgb2gray{i,j},utvid.enhancement.r_marker,utvid.enhancement.r_outer,utvid.enhancement.r_inner] = utvid_imenhanceLLRinit(im,coords);

        else
          [utvid.enhancement.Trgb2gray{i,j}] = utvid_imenhanceLLR(im,coords,utvid.enhancement.r_marker,utvid.enhancement.r_outer,utvid.enhancement.r_inner);
        end

        
        % Enhance image by using 2 class problem quadratic mapping
        % (orientation
        % markers)
        if utvid.settings.nrOrMar ~= 0
            coords_or.x = utvid.coords.or.(utvid.settings.camseq{utvid.Tracking.usecams(j)}).x(:,i);
            coords_or.y = utvid.coords.or.(utvid.settings.camseq{utvid.Tracking.usecams(j)}).y(:,i);
                
        if i == 1;
            [utvid.enhancement.Trgb2gray_or{i,j},utvid.enhancement.r_marker,utvid.enhancement.r_outer,utvid.enhancement.r_inner] = utvid_imenhanceLLRinit(im,coords_or);

        else
          [utvid.enhancement.Trgb2gray_or{i,j}] = utvid_imenhanceLLR(im,coords_or,utvid.enhancement.r_marker,utvid.enhancement.r_outer,utvid.enhancement.r_inner);
        end

        end
    end
end

utvid.settings.state = 5; % update state
% save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
guidata(hMainFigure,utvid);
set(utvid.handle.h5,'backgroundcolor','g');
end
%% PCA model
function utvid_selectpca(hMainFigure,utvid)
utvid = guidata(hMainFigure);
utvid.settings.PCs=10;
utvid.pca.sigv = 0.01;
prompt = 'Do you want to use a predefined PCA model (y/n)? ';
result = input(prompt, 's');
if isempty(result)
    result = 'y';
end

while isempty(regexpi(result,'y'))
    if regexpi(result,'n')==1
        utvid.settings.pca = 'expansion';
        break
    else
        prompt = 'Do you want to use a predefined PCA model (y/n)? Please type y for yes or n for no: ';
        result = input(prompt, 's');
    end
end

if regexpi(result,'y');
    %% hier moet de PCA selectie GUI aangeroepen worden
    %  met mogelijkheid tot het laden van een opgeslagen pcamodel
    utvid = getPCApoints(utvid);
    utvid.settings.pca = 'predefined';
end
prompt = 'Do you want to use MMSE as PCA coefficient estimator (y/n)? ';
result = input(prompt, 's');
if isempty(result)
    result = 'y';
end
while isempty(regexpi(result,'y'))
    if regexpi(result,'n')==1
        utvid.pca.MMSE = 0;
        disp('LSE not working yet')
        break
    else
        prompt = 'Do you want to use MMSE as PCA coefficient estimator (y/n)? ';
        result = input(prompt, 's');
    end
end
if regexpi(result,'y');
    utvid.pca.MMSE = 1;
end
utvid.pca.Normed = 1; % Always normalise data

if utvid.pca.MMSE == 1
    utvid = pcaMMSE(utvid);
end
prompt = 'Do you want to use Mahalanobis Distance (type 1) or 3D euclidean distance (type 2) as error measure? ';
result = input(prompt, 's');
if isempty(result)
    result = '1';
    utvid.pca.errMethod = 'MahDist';
end
while isempty(regexpi(result,'1'))
    if regexpi(result,'2')==1
        utvid.pca.errMethod = '3Ddist';
        break
    else
        prompt = 'Type 1 for Mahalanobis distance, Type 2 for 3D euclidean distance : ';
        result = input(prompt, 's');
    end
end

utvid.settings.state = 6; % update state
save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
guidata(hMainFigure,utvid);
set(utvid.handle.h6,'backgroundcolor','g');
end
%% Marker tracking
function markertracker(hMainFigure,utvid)

utvid = guidata(hMainFigure);
for i = 20% size(utvid.movs.instrstart,2):-1:1  % backwards through videos because of pca model training (most variance is in the last instructions).
    utvid.settings.initTracking =1;
    utvid.Tracking.instr = i;
    %     utvid.settings.nrOrMar = 0;
    utvid = markerTracking(utvid);
    save([utvid.settings.dir_data '\trackingOK' num2str(i) '.mat'],'utvid');
end
utvid.settings.state = 7; % update state
guidata(hMainFigure);
set(utvid.handle.h7,'backgroundcolor','g');

end

%%
function utvid_history(hMainFigure,utvid)
utvid = guidata(hMainFigure);

if iscell(utvid.settings.historyfolder)
    num = get(hMainFigure,'value');
    utvid.settings.dir_data = utvid.settings.historyfolder{num};
    disp([  'Measurement folder: ' utvid.settings.dir_data])
end

%proceed with initialization
utvid = utvid_init(hMainFigure,utvid);
% make buttons of completed steps green
for i = 1:utvid.settings.state
    set(eval(['utvid.handle.h' num2str(i)]),'backgroundcolor','g');
end

guidata(hMainFigure,utvid)
end