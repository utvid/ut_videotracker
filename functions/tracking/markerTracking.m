function utvid = markerTracking(utvid)

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
winsize = .9 * scrsize;%[800 600];
scrbase = monpos(1,1:2)+0.5*scrsize - 0.5*winsize;

trackingFigure = figure('Color',[0.94 0.94 0.94],...
    'MenuBar','none',...
    'Name','UT MARKER TRACKING',...
    'PaperPositionMode','auto',...
    'NumberTitle','off',...
    'Toolbar','none',...
    'Position',[scrbase winsize],...
    'Resize','off');

if utvid.settings.nrOrMar == 0
    for i = 1:3
        handles.hax{i} = axes('Parent',trackingFigure,'position',[(i-1)*(1/3) 0.2 1/3 0.75]);
    end
elseif utvid.settings.nrOrMar ~= 0
    for i = 1:6
        if i <4
            handles.hax{1,i} = axes('Parent',trackingFigure,'position',[(i-1)*(1/3) 0.2 1/3 0.4]);
        else
            handles.hax{2,i} = axes('Parent',trackingFigure,'position',[(i-4)*(1/3) 0.6 1/3 0.4]);
        end
    end
end

Nx = 8;
bsize = [100 100];
utvid.Tracking.plotting = 1;

nbutton = 1;
posx = mod(nbutton-1,8);
posy = floor((nbutton-1)/Nx)+1;
handles.h{nbutton} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Step back',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_back);

nbutton = 2;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{nbutton} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize],...
    'Style','togglebutton',...
    'fontsize',10,...
    'string','Pause',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_pause);

nbutton = 3;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{nbutton} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Step forward',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_step);

nbutton = 4;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{nbutton} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize],...
    'Style','togglebutton',...
    'fontsize',10,...
    'string','Continue',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_run);

posx = 4.1;
handles.h{5} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize],...
    'style','checkbox','string','show images','value',1,'BackgroundColor',[0.94 0.94 0.94],...
    'callback',@utvid_plot);

nbutton = 6;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{20} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)/3-winsize(2)*.85 bsize(1)*2 bsize(2)/3],...
    'Style','edit',...
    'fontsize',10,...
    'string','init',...
    'horizontalalignment','center',...
    'enable','on');

nbutton = 8;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{21} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)/3-winsize(2)*.85 bsize(1) bsize(2)/3],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Save',...
    'horizontalalignment','center',...
    'enable','on','callback',@utvid_Save);


nbutton = 6;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{22} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85  bsize(1)*3 bsize(2)/3],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','load',...
    'horizontalalignment','center',...
    'enable','on','callback',@utvid_Load);

%place edit boxes for Tracking settings
%{
Er moet nog een knop voor utvid.settings.Measmethod
Limieten plaatje instellen rondom interesse gebied

Default knop inbouwen?
%}
Ny = 7;

nbutton = 7;
posx = (2/3)*winsize(1);
posy = 20+(0.2*winsize(2))/Ny*(nbutton-1);
nbsize = [winsize(1)/3/2 0.15*winsize(2)/Ny];
uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','text',...
    'string','PCA expansion limit (mm)',...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

posx = (2/3)*winsize(1)+nbsize(1);
handles.h{12} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','edit',....
    'string','4','Callback',@gettextvalues,...
    'background','white');
utvid.Tracking.lim = str2double(get(handles.h{12},'string'));

nbutton = 6;
posx = (2/3)*winsize(1);
posy = 20+(0.2*winsize(2))/Ny*(nbutton-1);
uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','text',...
    'string','ROI',...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

posx = (2/3)*winsize(1)+nbsize(1);
handles.h{6} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','edit',....
    'string','6','Callback',@gettextvalues,...
    'background','white');
utvid.Tracking.roi = str2double(get(handles.h{6},'string'));

nbutton = 5;
posx = (2/3)*winsize(1);
posy = 20+(0.2*winsize(2))/Ny*(nbutton-1);
uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','text',...
    'string','Measurement Noise',...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

posx = (2/3)*winsize(1)+nbsize(1);
handles.h{7} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','edit',....
    'string','5','Callback',@gettextvalues,...
    'background','white');
utvid.Tracking.sigMeas = str2num(get(handles.h{7},'string'));

nbutton = 4;
posx = (2/3)*winsize(1);
posy = 20+(0.2*winsize(2))/Ny*(nbutton-1);
uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','text',...
    'string','Process Noise X',...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

posx = (2/3)*winsize(1)+nbsize(1);
handles.h{8} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','edit',....
    'string','2','Callback',@gettextvalues,...
    'background','white');
utvid.Tracking.sigVx = str2num(get(handles.h{8},'string'));

nbutton = 3;
posx = (2/3)*winsize(1);
posy = 20+(0.2*winsize(2))/Ny*(nbutton-1);
uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','text',...
    'string','Process Noise Y',...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

posx = (2/3)*winsize(1)+nbsize(1);
handles.h{9} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','edit',....
    'string','2','Callback',@gettextvalues,...
    'background','white');
utvid.Tracking.sigVy = str2num(get(handles.h{9},'string'));

nbutton = 2;
posx = (2/3)*winsize(1);
posy = 20+(0.2*winsize(2))/Ny*(nbutton-1);
uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','text',...
    'string','Process Noise Z',...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

posx = (2/3)*winsize(1)+nbsize(1);
handles.h{10} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','edit',....
    'string','2','Callback',@gettextvalues,...
    'background','white');
utvid.Tracking.sigVz= str2num(get(handles.h{10},'string'));

nbutton = 1;
posx = (2/3)*winsize(1);
posy = 20+(0.2*winsize(2))/Ny*(nbutton-1);
uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','text',...
    'string','Number of Principal Components',...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

posx = (2/3)*winsize(1)+nbsize(1);
handles.h{11} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx posy nbsize],...
    'style','edit',....
    'string','6','Callback',@gettextvalues,...
    'background','white');
utvid.settings.PCs = str2double(get(handles.h{11},'string'));

utvid = initializeTracking(utvid,handles);

set(gcf,'CloseRequestFcn',@utvid_close);
guidata(trackingFigure,handles);
uiwait(trackingFigure);

%% get text box values
    function gettextvalues(trackingFigure,handles)
        handles = guidata(trackingFigure);
        
        % number of principle components
        utvid.settings.PCs =       str2double(get(handles.h{11},'string'));
        % measurement noise
        utvid.Tracking.sigMeas =   str2num(get(handles.h{7},'string'));
        % process noise x y z
        utvid.Tracking.sigVx =     str2num(get(handles.h{8},'string'));
        utvid.Tracking.sigVy =     str2num(get(handles.h{9},'string'));
        utvid.Tracking.sigVz =     str2num(get(handles.h{10},'string'));
        % search region
        utvid.Tracking.roi=        str2double(get(handles.h{6},'string'));
        utvid.Tracking.lim=        str2double(get(handles.h{6},'string'));
        
        % check for empty input, if so use defaults
        if isempty(utvid.settings.PCs);        utvid.settings.PCs = 6;
            set(handles.h{11},'string','6');   end
        if isempty(utvid.Tracking.sigMeas);    utvid.Tracking.sigMeas = 5;
            set(handles.h{7},'string','5');     end
        if isempty(utvid.Tracking.sigVx);      utvid.Tracking.sigVx = 2;
            set(handles.h{8},'string','2');     end
        if isempty(utvid.Tracking.sigVy);      utvid.Tracking.sigVy = 2;
            set(handles.h{9},'string','2');     end
        if isempty(utvid.Tracking.sigVz);      utvid.Tracking.sigVz = 2;
            set(handles.h{10},'string','2');    end
        if isempty(utvid.Tracking.roi);    utvid.Tracking.roi  = 6;
            set(handles.h{6},'string','6');     end
        
        guidata(trackingFigure,handles);
    end
%% Save callback
    function utvid_Save(trackingFigure,handles)
        handles = guidata(trackingFigure);
        set(handles.h{2},'Value',1)
        set(handles.h{4},'Value',0)
        
    if exist([utvid.settings.dir_data '\' get(handles.h{20},'string') '.mat'],'file') ~=0        
        save([utvid.settings.dir_data '\' get(handles.h{20},'string') '.mat'],'utvid','-append');
    else
        save([utvid.settings.dir_data '\' get(handles.h{20},'string') '.mat'],'utvid')
    end
        guidata(trackingFigure,handles);
    end
%% load callback
 function utvid_Load(trackingFigure,handles)
        handles = guidata(trackingFigure);
        
        filename = uigetfile(utvid.settings.dir_data);
        disp([filename '.mat loaded succesfully']);

        guidata(trackingFigure,handles);
    end
%% step back callback
    function utvid_back(trackingFigure,handles)
        handles = guidata(trackingFigure);
        if utvid.Tracking.n > 1
            utvid.Tracking.n = utvid.Tracking.n-1;
            utvid = Tracking(utvid,handles);
        end
        
        guidata(trackingFigure,handles);
    end

%% pause callback
    function utvid_pause(trackingFigure,handles)
        handles = guidata(trackingFigure);
        utvid.Tracking.n = utvid.Tracking.n;
        
        if get(handles.h{2},'Value')
            set(handles.h{2},'Value',1);
        else
            set(handles.h{2},'Value',0);
            
        end
        if get(handles.h{4},'Value')
            set(handles.h{4},'Value',0)
        end
        guidata(trackingFigure,handles);
    end

%% step forward callback
    function utvid_step(trackingFigure,handles)
        handles = guidata(trackingFigure);
        if strcmp(utvid.settings.version,'R2012')
            if utvid.Tracking.n+1 < utvid.Tracking.NoF
                utvid.Tracking.n = utvid.Tracking.n+1;
                utvid = Tracking(utvid,handles);
            end
        elseif strcmp(utvid.settings.version,'R2013')
            if utvid.Tracking.n < utvid.Tracking.NoF
                utvid.Tracking.n = utvid.Tracking.n+1;
                utvid = Tracking(utvid,handles);
            end
            guidata(trackingFigure,handles);
        end
    end

%% continue callback
    function utvid_run(trackingFigure,handles)
        handles = guidata(trackingFigure);
        if get(handles.h{2},'Value')
            set(handles.h{2},'Value',0)
        end
        utvid.Tracking.FrameNum =  VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(1).name]).NumberOfFrames;
        while get(handles.h{2},'value') ~= 1 && utvid.Tracking.n <= utvid.Tracking.FrameNum;
            utvid.Tracking.n = utvid.Tracking.n+1;
            utvid = Tracking(utvid,handles);
        end
        
        guidata(trackingFigure,handles);
    end
%% checkbox plot
    function utvid_plot(trackingFigure,handles)
        handles = guidata(trackingFigure);
        utvid.Tracking.plotting = get(handles.h{5},'Value');
        
        guidata(trackingFigure,handles);
    end

%% close
    function utvid_close(trackingFigure,handles)
        delete(gcf)
    end

end