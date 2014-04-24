function [utvid] = getPCApoints(utvid)
warning off;
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
winsize = [0.4*scrsize(1) .75 * scrsize(2)];%[800 600];
scrbase = monpos(1,1:2)+0.5*scrsize - 0.5*winsize;

pcaselectFig = figure(	'Color',[1 1 1],...
    'MenuBar','none',...
    'Name','UT PCA SELECTION TOOL',...
    'PaperPositionMode','auto',...
    'NumberTitle','off',...
    'Toolbar','none',...
    'Position',[scrbase winsize],...
    'Resize','off');

% set axes for showing images
handles.hax1 = axes('Parent',pcaselectFig,'position',[0.15 0.4 0.7 0.5]);

Nx = 2; % number of objects in x direction
Ny = 1; % number of objects in y direction

%% creates pushbuttons for selecting frames and closing GUI
bsize = [winsize(1)/4 winsize(2)/8];
nbutton = 1;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{1} = uicontrol(...
    'Parent',pcaselectFig,...
    'position',[posx*bsize(1)+.25*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.8 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Select frame',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_selectframe);
nbutton = 2;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{2} = uicontrol(...
    'Parent',pcaselectFig,...
    'position',[posx*bsize(1)+.25*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.8 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Close',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_close);
%% create dropdown to select videos
for j = 1:length(utvid.movs.center)
    movs{j} = utvid.movs.list(utvid.movs.center(1,j)).name;
end
handles.video = uicontrol('Style', 'popup',...
    'String', movs,...
    'Position', [0.15*winsize(1) 0.30*winsize(2) 0.7*winsize(1) 0.05*winsize(2)],...
    'Callback', @utvid_vidselect);
%% text boxes
handles.text.frame =     uicontrol(...
    'Parent',pcaselectFig,...
    'Style','text',...
    'FontSize',12,...
    'FontWeight','bold',...
    'Background','white',...
    'Position',[0.12*winsize(1) .21*winsize(2) 0.7*winsize(1) 0.03*winsize(2)],...
    'String','Frame number: ');
handles.text.framenumber =     uicontrol(...
    'Parent',pcaselectFig,...
    'Style','text',...
    'FontSize',12,...
    'FontWeight','bold',...
    'Background','white',...
    'Position',[0.55*winsize(1) .21*winsize(2) 0.1*winsize(1) 0.03*winsize(2)],...
    'String',num2str(1));

handles.text.selected =     uicontrol(...
    'Parent',pcaselectFig,...
    'Style','text',...
    'FontSize',12,...
    'FontWeight','bold',...
    'Background','white',...
    'Position',[0.25*winsize(1) .03*winsize(2) 0.3*winsize(1) 0.03*winsize(2)],...
    'String','Number of selected frames:');

handles.text.curNoF =     uicontrol(...
    'Parent',pcaselectFig,...
    'Style','text',...
    'FontSize',12,...
    'FontWeight','bold',...
    'Background','white',...
    'ForegroundColor','red',...
    'Position',[0.55*winsize(1) .03*winsize(2) 0.1*winsize(1) 0.03*winsize(2)],...
    'String',num2str(0));

%% defaults
handles.vid_selected = 1; % selected video (start at video 1)
handles.frame_selected = 1;% selected frame (start at frame 1)
if isfield(utvid,'pca');
    handles.curNoF = length(utvid.pca);
    ids = find(strcmp({utvid.pca.video},utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name));
    if isempty(ids)==0
        for j = 1:length(ids)
            if utvid.pca(ids(j)).frame == handles.frame_selected;
                set(handles.text.framenumber,'ForegroundColor','red');
                break
            else
                set(handles.text.framenumber,'ForegroundColor','black');
            end
        end
        set(handles.video,'ForegroundColor','red');
    else
        set(handles.video,'ForegroundColor','black');
        set(handles.text.framenumber,'ForegroundColor','black');
    end
else
    handles.curNoF = 0;% current number of frames selected
end
set(handles.text.curNoF,'string',handles.curNoF);
%% create slider to scroll through frames
obj = VideoReader([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name]);
handles.sliderframe = uicontrol(...
    'Parent',pcaselectFig,...
    'Style', 'slider',...
    'Min',1,'Max',obj.NumberOfFrames,'Value',1,...
    'SliderStep',[1 10]/(obj.NumberOfFrames-1),...
    'Position', [0.15*winsize(1) .25*winsize(2) .7*winsize(1) .05*winsize(2)],...
    'Callback', {@utvid_sliderframe});
handles.I = im2double(read(obj,handles.frame_selected));
axes(handles.hax1);imshow(handles.I);title(utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name)
set(gcf,'CloseRequestFcn',@utvid_close);

guidata(pcaselectFig,handles);
uiwait(pcaselectFig);
%% popupmenu callback
    function utvid_vidselect(pcaselectFig,handles)
        handles = guidata(pcaselectFig);
        handles.vid_selected = get(handles.video,'value');
        handles.frame_selected = 1;
        obj = VideoReader([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name]);
        handles.I = im2double(read(obj,handles.frame_selected));
        axes(handles.hax1);imshow(handles.I);title(utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name);
        set(handles.sliderframe,'Value',1);
        set(handles.sliderframe,'Max',obj.NumberOfFrames);
        set(handles.sliderframe,'SliderStep',[1 10]/(obj.NumberOfFrames-1));
        if isfield(utvid,'pca');
            ids = find(strcmp({utvid.pca.video},utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name));
            if isempty(ids)==0
                for k = 1:length(ids)
                    if utvid.pca(ids(k)).frame == handles.frame_selected;
                        set(handles.text.framenumber,'ForegroundColor','red');
                        break
                    else
                        set(handles.text.framenumber,'ForegroundColor','black');
                    end
                end
                set(handles.video,'ForegroundColor','red');
            else
                set(handles.video,'ForegroundColor','black');
                set(handles.text.framenumber,'ForegroundColor','black');
            end
        end
        set(handles.text.framenumber,'string',handles.frame_selected);
        guidata(pcaselectFig,handles);
    end
%% sliderframe callback
    function utvid_sliderframe(pcaselectFig,handles)
        handles = guidata(pcaselectFig);
        handles.frame_selected = round(get(handles.sliderframe,'value'));
        handles.I = im2double(read(VideoReader([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name]),handles.frame_selected));
        axes(handles.hax1);imshow(handles.I);title(utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name)
        set(handles.text.framenumber,'string',handles.frame_selected);
        if isfield(utvid,'pca')
            ids = find(strcmp({utvid.pca.video},utvid.movs.list(utvid.movs.center(1,handles.vid_selected)).name));
            if isempty(ids)==0
                for k = 1:length(ids);
                    if utvid.pca(ids(k)).frame == handles.frame_selected;
                        set(handles.text.framenumber,'ForegroundColor','red');
                        break
                    else
                        set(handles.text.framenumber,'ForegroundColor','black');
                    end
                end
                set(handles.video,'ForegroundColor','red');
            else
                set(handles.video,'ForegroundColor','black');
                set(handles.text.framenumber,'ForegroundColor','black');
            end
        end
        guidata(pcaselectFig,handles);
    end
%% select frame
    function utvid_selectframe(pcaselectFig,handles)
        handles = guidata(pcaselectFig);
        handles.curNoF = handles.curNoF + 1;
        cam ={'left','right','center'};
        nrOrMar =1 ;
        nrMarkers = 1;
        % go through all cameras
        for j = 1:utvid.settings.nrcams
            utvid.pca(handles.curNoF,j).video = utvid.movs.list(utvid.movs.(cam{j})(1,handles.vid_selected)).name;
            utvid.pca(handles.curNoF,j).frame = handles.frame_selected;
            [utvid.pca(handles.curNoF,j).x_or,utvid.pca(handles.curNoF,j).y_or] = ...
                getPoints(im2double(read(VideoReader([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(utvid.movs.(cam{j})(1,handles.vid_selected)).name]),handles.frame_selected)), nrOrMar,'Select orientation markers');
            [utvid.pca(handles.curNoF,j).x,utvid.pca(handles.curNoF,j).y] = ...
                getPoints(im2double(read(VideoReader([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(utvid.movs.(cam{j})(1,handles.vid_selected)).name]),handles.frame_selected)), nrMarkers, 'Select lip markers');
        end
        assignin('base','temputvid',utvid);
        set(handles.text.curNoF,'string',handles.curNoF);
        set(handles.video,'Foregroundcolor','red');
        set(handles.text.framenumber,'Foregroundcolor','red');
 
        guidata(pcaselectFig,handles);
    end
%% close
    function utvid_close(pcaselectFig,handles)
        delete(gcf)
    end
end
