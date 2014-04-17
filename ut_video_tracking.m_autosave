function ut_video_tracking

% p = mfilename('fullpath');
p = pwd;
% [path,name,ext] = fileparts(p)
addpath(genpath([p '\Functions']));

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
winsize = [600 100];
scrbase = monpos(1,1:2)+0.5*scrsize - 0.5*winsize;

hMainFigure = figure(	'Color',[1 1 1],...
    'MenuBar','none',...
    'Name','UT VIDEO TRACKER',...
    'PaperPositionMode','auto',...
    'NumberTitle','off',...
    'Toolbar','none',...
    'Position',[scrbase winsize],...
    'Resize','off');

Nx = 4;     % number of buttons in hor direction
Ny = 2;     % number of buttons in ver direction
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
    'string','IMAGE ENHANCEMENT',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@imenhance);

nbutton = 5;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
utvid.handle.h5 = uicontrol(...
    'position',[posx*bsize(1) winsize(2)-posy*bsize(2) bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','SELECT MARKERS',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_markerselector);

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
    'callback',@utvid_na);

nbutton = Nx*Ny;
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
close(hMainFigure);
end

%% Warning function for not yet implemented functions
function utvid_na(hMainFigure,utvid)
warndlg('not yet implemented',' ','modal')
end

%% Bayerfilter and compress videos
function utvid_bayercompress(hMainFigure,utvid);
utvid = guidata(hMainFigure);

% Ask for using compression or not
prompt = 'Use compression (y/n)? ';
result = input(prompt, 's');
if isempty(result)
    result = 'y';
end

while isempty(regexpi(result,'y'))
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
%}

%% Calibration process
function utvid_calibration(hMainFigure,utvid)
utvid = guidata(hMainFigure);
cam ={'left','right','center'};
for i = 1:utvid.settings.nrcams;
    image = read(VideoReader([utvid.settings.dir_data '\Calibration\' utvid.movs.calb.(cam{i}).name]),2);
    I = demosaic(image(:,:,1),'rggb');
    % calibration using script of Hageman and van der Heijden
    [K, R, T, P,avgEr,stdEr] = utvid_camcalibration(I,50);
    utvid.calbMat.(cam{i}){1,1} = K;
    utvid.calbMat.(cam{i}){1,2} = R;
    utvid.calbMat.(cam{i}){1,3} = T;
    utvid.calbMat.(cam{i}){1,4} = P;
    utvid.calbMat.(cam{i}){1,5} = avgEr;
    utvid.calbMat.(cam{i}){1,6} = stdEr;
    utvid.calb{i}.P = utvid.calbMat.(cam{i}){1,4};
end
utvid.settings.state = 3; % update state
save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
guidata(hMainFigure,utvid);
set(utvid.handle.h3,'backgroundcolor','g');
end

%% Image enhancement
function imenhance(hMainFigure,utvid);
utvid = guidata(hMainFigure);

% imenhanceGUI moet nog verbeterd worden met meer opties
utvid = imenhanceGUI(hMainFigure,utvid);

utvid.settings.state = 4; % update state
save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
guidata(hMainFigure,utvid);
set(utvid.handle.h4,'backgroundcolor','g');
end

%% Select markers
function utvid_markerselector(hMainFigure,utvid);
utvid = guidata(hMainFigure);
[utvid.Pstruct, utvid.Pstruct_or] = getPstruct(utvid.calb, utvid); % create Pstruct and Pstruct_or
nOrMar = 6;
nMar = 10;
cam ={'left','right','center'};
for j = 1:size(utvid.movs.instrstart,2)
    for i = 1:utvid.settings.nrcams;
        if strcmp(utvid.version,'R2012')
            Im = read(VideoReader([utvid.settings.dir_data '\Video\' utvid.movs.list(utvid.movs.(cam{i})(1,utvid.movs.instrstart(j))).name]),2);
        elseif strcmp(utvid.version,'R2013')
            Im = read(VideoReader([utvid.settings.dir_data '\Video\' utvid.movs.list(utvid.movs.(cam{i})(1,utvid.movs.instrstart(j))).name]),1);
        else
            disp('Version not yet implemented')
        end

        [utvid.coords.or.(cam{i}).x(j,:),utvid.coords.or.(cam{i}).y(j,:)] = getPoints(Im,nOrMar,'Select Orientation markers');
        [utvid.coords.lip.(cam{i}).x(j,:),utvid.coords.lip.(cam{i}).y(j,:)] = getPoints(Im,nMar,'Select Lip markers');
    end
end

utvid.settings.state = 5; % update state
save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
guidata(hMainFigure);
set(utvid.handle.h5,'backgroundcolor','g');

end
%% PCA model
    function utvid_selectpca(hMainFigure,utvid)
        utvid = guidata(hMainFigure);
        
        prompt = 'Do you want to use a predefined PCA model (y/n)? '
        result = input(prompt, 's');
        if isempty(result)
            result = 'y';
        end
        
        while isempty(regexpi(result,'y'))
            if regexpi(result,'n')==1
                break
                utvid_settings.pca = 'expansion';
            else
                prompt = 'Do you want to use a predefined PCA model (y/n)? Please type y for yes or n for no: ';
                result = input(prompt, 's');
            end
        end
        if result == regexpi(result,'y');
            %% hier moet de PCA selectie GUI aangeroepen worden
            %  met mogelijkheid tot het laden van een opgeslagen pcamodel
            utvid_settings.pca = 'predefined';
        end
        utvid.settings.state = 6; % update state
        save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
        guidata(hMainFigure,utvid);
        set(utvid.handle.h6,'backgroundcolor','g');
    end

%% Marker tracking
    function markertracker(hMainFigure,utvid);
        utvid = guidata(hMainFigure);
        
        % verschillende opties toevoegen:
        %  templatematching
        %  circle search
        %  minimum search
        %  findblue
        %  active appearance
        %  et cetera
        switch(result)
            case templatematching
                disp('Not yet implemented');
            case minsearch
                disp('Not yet implemented');
            case bluesearch
                disp('Not yet implemented');
            case circlesearch
                disp('Not yet implemented');
            case aam
                disp('Not yet implemented');
        end
        
        
        
        
        utvid.settings.state = 7; % update state
        save([utvid.settings.dir_data '\init.mat'],'utvid','-append');
        guidata(hMainFigure);
        set(utvid.handle.h7,'backgroundcolor','g');
    end