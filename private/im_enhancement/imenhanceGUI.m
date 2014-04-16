function [ utvid ] = imenhanceGUI(hMainFigure,utvid)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

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

enhanceFigure = figure(	'Color',[1 1 1],...
    'MenuBar','none',...
    'Name','UT IMAGE ENHANCEMENT',...
    'PaperPositionMode','auto',...
    'NumberTitle','off',...
    'Toolbar','none',...
    'Position',[scrbase winsize],...
    'Resize','off');

handles.hax1 = axes('Parent',enhanceFigure,'position',[0 0.4 0.5 0.5]);
handles.hax2 = axes('Parent',enhanceFigure,'position',[0.5 0.4 0.5 0.5]);
handles.I = im2double(read(VideoReader([utvid.settings.dir_data '\Video\' utvid.movs.list(utvid.movs.center(1,1)).name]),1));
handles.J = [];
axes(handles.hax1);imshow(handles.I);title('Original Image');
axes(handles.hax2);imshow(handles.I);title('Enhanced Image');

Nx = 4; % number of objects in x direction
Ny = 2; % number of objects in y direction

bsize = [winsize(1) winsize(2)]/8;
nbutton = 1;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{1} = uicontrol(...
    'Parent',enhanceFigure,...
    'position',[posx*bsize(1)+.06*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.6 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Histeq',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_histeq);
nbutton = 2;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{2} = uicontrol(...
    'Parent',enhanceFigure,...
    'position',[posx*bsize(1)+.06*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.6 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Imadjust',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_imadjust);
nbutton = 3;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{3} = uicontrol(...
    'Parent',enhanceFigure,...
    'position',[posx*bsize(1)+.06*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.6 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Filters',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@contrastfilter);
nbutton = 4;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{4} = uicontrol(...
    'Parent',enhanceFigure,...
    'position',[posx*bsize(1)+.06*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.6 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Histeq',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@utvid_na);
nbutton = 5;
posx = mod(nbutton-1,Nx);
posy = floor((nbutton-1)/Nx)+1;
handles.h{5} = uicontrol(...
    'Parent',enhanceFigure,...
    'position',[posx*bsize(1)+.06*winsize(1) winsize(2)-posy*bsize(2)-winsize(2)*.6 bsize],...
    'Style','pushbutton',...
    'fontsize',10,...
    'string','Reset all',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',@reset);

handles.enhancement.histeq =[];
handles.enhancement.imadjust =[];



handles.sigma_up = 5; 
handles.sigma_down = 1;
handles.alfa = 5;
handles.ndown = 15; handles.nleft = 0;
nregion = 6; 
nwin = 5;  
averpsf = fspecial('average',2*nwin+1); 
handles.a = 36; handles.b = 0.5;

guidata(enhanceFigure,handles);


end
%%
function utvid_na(enhanceFigure,handles)
warndlg('not yet implemented',' ','modal')
end

%% histogram equalizer
function utvid_histeq(enhanceFigure,handles);
handles = guidata(enhanceFigure);
set(handles.h{1},'background','g')
if isempty(handles.J)==1;
    handles.J = handles.I;
end
for i = 1:size(handles.I,3)
    handles.J(:,:,i) = histeq(handles.J(:,:,i));
end
axes(handles.hax2);imshow(handles.J);title('Enhanced Image');
handles.enhancement.histeq = 'true';
guidata(enhanceFigure,handles);
end
%% image adjuster
function utvid_imadjust(enhanceFigure,handles);
handles = guidata(enhanceFigure);
set(handles.h{2},'background','g')
if isempty(handles.J)==1;
    handles.J = handles.I;
end
handles.J = imadjust(handles.J,[.3 .2 .2; .6 .7 .7]);
axes(handles.hax2);imshow(handles.J);title('Enhanced Image');
handles.enhancement.imadjust = 'true';
guidata(enhanceFigure,handles);
end

%% Filtering
function contrastfilter(enhanceFigure,handles);
handles = guidata(enhanceFigure);
set(handles.h{3},'background','g')
if isempty(handles.J)==1;
    handles.J = handles.I;
end

for i = 1:size(handles.J,3)
    handles.J(:,:,i) = ut_gauss(handles.alfa*handles.J(:,:,i)-(handles.alfa-1)*...
                         ut_gauss(handles.J(:,:,i),handles.sigma_up),handles.sigma_down);
end
axes(handles.hax2);imshow(handles.J);title('Enhanced Image');
handles.enhancement.filters = 'true';
guidata(enhanceFigure,handles);
end


%% reset settings
function reset(enhanceFigure,handles);
handles = guidata(enhanceFigure);
field = {'histeq','imadjust','filters'};
for i = 1:size(handles.h,2)
    set(handles.h{1,i},'background','default');
    try
    handles.enhancement.(field{i}) = 'false';
    catch end
end
   handles.J = handles.I;
   axes(handles.hax2);imshow(handles.J);title('Enhanced Image');
   guidata(enhanceFigure,handles);
end