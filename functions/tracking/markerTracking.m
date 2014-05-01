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

if utvid.coords.nOrMar == 0
    for i = 1:3
        handles.hax{i} = axes('Parent',trackingFigure,'position',[(i-1)*(1/3) 0.2 1/3 0.75]);
    end
elseif utvid.coords.nOrMar ~= 0
    for i = 1:6
        if i <4
            handles.hax{1,i} = axes('Parent',trackingFigure,'position',[(i-1)*(1/3) 0.2 1/3 0.4]);
        else
            handles.hax{2,i} = axes('Parent',trackingFigure,'position',[(i-4)*(1/3) 0.6 1/3 0.4]);
        end
    end
end

utvid.Tracking.ObjL = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.left(1,1)).name]);
utvid.Tracking.ObjR = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.right(1,1)).name]);
utvid.Tracking.ObjM = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.center(1,1)).name]);


Nx = 4;
bsize = [100 100];

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

posx = 4.5;
handles.h{5} = uicontrol(...
    'Parent',trackingFigure,...
    'position',[posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize],...
    'style','checkbox','string','show images','value',1,'BackgroundColor',[0.94 0.94 0.94]);

nbsize = [bsize(1)*2 bsize(2)/2];
posx = 5.5;
posy = .75;
handles.h{6} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 nbsize],...
    'style','edit',....
    'string','Type number of principle components',...
    'background','white');

posx = 8;
posy = .75;
handles.h{7} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize(1)*2 bsize(2)/2],...
    'style','edit',....
    'string','Type measurement noise',...
    'background','white');

posx = 10.5;
posy = .25;
handles.h{8} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize(1)*2 bsize(2)/2],...
    'style','edit',....
    'string','Type process noise (X)',...
    'background','white');
posx = 10.5;
posy = .75;
handles.h{9} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize(1)*2 bsize(2)/2],...
    'style','edit',....
    'string','Type process noise (Y)',...
    'background','white');
posx = 10.5;
posy = 1.25;
handles.h{10} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize(1)*2 bsize(2)/2],...
    'style','edit',....
    'string','Type process noise (Z)',...
    'background','white');

posx = 13;
posy = .75;
handles.h{11} = uicontrol(...
    'Parent',trackingFigure,...
    'position', [posx*bsize(1)+.05*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.85 bsize(1)*2 bsize(2)/2],...
    'style','edit',....
    'string','Type region of interest',...
    'background','white');

utvid = initializeTracking(utvid,handles);

set(gcf,'CloseRequestFcn',@utvid_close);
guidata(trackingFigure,handles);
uiwait(trackingFigure);

%% get text box values
    function gettextvalues(trackingFigure,handles)
             % number of principle components
             utvid.settings.PCs =       str2num(get(handles.h{6},'string'));
             % measurement noise
             utvid.Tracking.sigMeas =   str2num(get(handles.h{7},'string'));
             % process noise x y z
             utvid.Tracking.sigVx =     str2num(get(handles.h{8},'string'));
             utvid.Tracking.sigVy =     str2num(get(handles.h{9},'string'));
             utvid.Tracking.sigVz=     str2num(get(handles.h{10},'string'));
             % search region
             utvid.Tracking.roi=        str2num(get(handles.h{11},'string'));
             
             % check for empty input, if so use defaults
             if isempty(utvid.settings.PCs); utvid.settings.PCs = 6;end
             if isempty(utvid.Tracking.sigMeas); utvid.Tracking.sigMeas = 5;end
             if isempty(utvid.Tracking.sigVx); utvid.Tracking.sigVx = 2;end
             if isempty(utvid.Tracking.sigVy); utvid.Tracking.sigVy = 2;end
             if isempty(utvid.Tracking.sigVz); utvid.Tracking.sigVz = 2;end
             if isempty(utvid.Tracking.roi); utvid.Tracking.roi  = 6;end
        end     
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
        utvid.Tracking.n = utvid.Tracking.n+1;
        utvid = Tracking(utvid,handles);
        
        guidata(trackingFigure,handles);
    end

%% continue callback
    function utvid_run(trackingFigure,handles)
        handles = guidata(trackingFigure);
        if get(handles.h{2},'Value')
            set(handles.h{2},'Value',0)
        end
        utvid.Tracking.FrameNum =  VideoReader([utvid.settings.dir_data '\Video\' utvid.movs.list(1).name]).NumberOfFrames;
        while get(handles.h{2},'value') ~= 1 && utvid.Tracking.n <= utvid.Tracking.FrameNum;
            utvid.Tracking.n = utvid.Tracking.n+1;
            utvid = Tracking(utvid,handles);
            pause(0.5)
        end
        
        guidata(trackingFigure,handles);
    end

%% close
    function utvid_close(trackingFigure,handles)
        delete(gcf)
    end

end