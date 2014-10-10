function [Im_filtered,Trgb2gray] = utvid_imenhanceLLRinit(im,coords)

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
winsize = [.95 * scrsize(1) 0.95* scrsize(2) ];%[800 600];
scrbase = monpos(1,1:2)+0.5*scrsize - 0.5*winsize;

enhanceFig = figure('Color',[0.94 0.94 0.94],...
    'MenuBar','none',...
    'Name','Enhance Tool',...
    'PaperPositionMode','auto',...
    'NumberTitle','off',...
    'Toolbar','none',...
    'Position',[scrbase winsize],...
    'Resize','off');

handles.hax1 = axes('Parent',enhanceFig,'position',[.075 .2 .4 .6]);
handles.hax2 = axes('Parent',enhanceFig,'position',[.55 .2 .4 .6]);

axes(handles.hax1), imshow(im,[]);
axes(handles.hax2), imshow(im,[]);

im(:,:,1) = im(:,:,1).^2; % squared Red channel for enhancing lips
r_marker = 5;
r_outer = 15;
r_inner = 10;


%% OK button
bsize =  [0.25*winsize(1) 0.125*winsize(2)];
handles.h{1} = uicontrol(...
    'Parent',enhanceFig,...
    'position',[0.2*winsize(1) 0.05*winsize(2) bsize],...
    'Style','togglebutton',...
    'fontsize',10,...
    'string','O.K.',...
    'horizontalalignment','center',...
    'enable','on',...
    'callback',{@docalculations});
%% slider inner
slmax = 30;
slmin = 0;
slize = [bsize(1), bsize(2)/3];
handles.sl{1} = uicontrol(...
    'Parent',enhanceFig, ...
    'Style','slider', ...
    'Min',slmin,'Max',slmax,'Value',r_inner, ...
    'SliderStep',[1 5]./(slmax-slmin), ...
    'Position',[0.5*winsize(1) 0.05*winsize(2) slize], ...
    'Callback',{@slider,1});
handles.text{1} = uicontrol(...
    'Parent',enhanceFig,...
    'position', [0.75*winsize(1), 0.05*winsize(2) bsize(1) slize(2)],...
    'style','text',...
    'string',['Inner radius: ' num2str(r_inner)],...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

%% slider outer
handles.sl{2} = uicontrol(...
    'Parent',enhanceFig, ...
    'Style','slider', ...
    'Min',slmin,'Max',slmax,'Value',r_outer, ...
    'SliderStep',[1 5]./(slmax-slmin), ...
    'Position',[0.5*winsize(1) 0.05*winsize(2)+slize(2) slize], ...
    'Callback',{@slider,2});
handles.text{2} = uicontrol(...
    'Parent',enhanceFig,...
    'position', [0.75*winsize(1), 0.05*winsize(2)+slize(2) bsize(1) slize(2)],...
    'style','text',...
    'string',['Outer radius: ' num2str(r_outer)],...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

%% slider
handles.sl{3} = uicontrol(...
    'Parent',enhanceFig, ...
    'Style','slider', ...
    'Min',slmin,'Max',slmax,'Value',r_marker, ...
    'SliderStep',[1 5]./(slmax-slmin), ...
    'Position',[0.5*winsize(1) 0.05*winsize(2)+slize(2)*2 slize], ...
    'Callback',{@slider,3});
handles.text{3} = uicontrol(...
    'Parent',enhanceFig,...
    'position', [0.75*winsize(1), 0.05*winsize(2)+slize(2)*2 bsize(1) slize(2)],...
    'style','text',...
    'string',['Radius marker: ' num2str(r_marker)],...
    'background','white','BackgroundColor',[0.94 0.94 0.94]);

guidata(enhanceFig,handles)
uiwait(enhanceFig)

%% do calculations
    function docalculations(enhanceFig,handles)
        Trgb2gray = utvid_calcTrgb(im,coords,r_marker,r_outer,r_inner);
        w = Trgb2gray.w;            % the linear mapping
        W = Trgb2gray.W;            % the quadratic mapping
        
        goo = reshape(im,size(im,1)*size(im,2),3);
        imlikel= sum(goo.*(W*goo')',2)+goo*w;        % the pixel log-likelihood ratio
        imlikel = reshape(imlikel,size(im,1),size(im,2));
        Im_filtered = ut_gauss(imlikel,2.5);        % low pass filtering to suppress multiple responses
        delete(gcf)
    end

%% slider adjustment
    function slider(enhanceFig,handles,x);
        handles = guidata(enhanceFig);
        val = get(handles.sl{x},'value');
        set(handles.sl{x},'value',val);
        if x == 1
            r_inner = val;
            set(handles.sl{2},'Min',val+1);
            set(handles.sl{3},'Max',val-1)
            set(handles.text{1},'string',['Inner radius: ' num2str(r_inner)]);
            if get(handles.sl{3},'value') >= r_inner
                set(handles.sl{3},'value',r_inner-1);
                set(handles.text{3},'string',['Radius marker: ' num2str(r_inner-1)]);
                r_marker = r_inner-1;
            end
            if get(handles.sl{2},'value') <= r_inner
                set(handles.sl{2},'value',r_inner+1);
                set(handles.text{2},'string',['Radius marker: ' num2str(r_inner+1)]);
                r_marker = r_inner+1;
            end
        elseif x == 2
            r_outer = val;
            set(handles.sl{1},'Max',val-1);
            set(handles.text{2},'string',['Outer radius: ' num2str(r_outer)]);
            if get(handles.sl{1},'value') >= r_outer
                set(handles.sl{1},'value',r_outer-1);
                set(handles.text{1},'string',['Inner radius: ' num2str(r_outer-1)]);
                r_inner = r_outer-1;
            end
            if get(handles.sl{3},'value') >= r_outer;
                set(handles.sl{3},'value',r_outer-2);
                set(handles.text{3},'string',['Radius marker: ' num2str(r_outer-2)]);
                r_marker = r_outer-2;
            end
        elseif x == 3
            r_marker = val;
            set(handles.sl{2},'Min',val+1);
            set(handles.sl{1},'Min',val+1);
            set(handles.text{3},'string',['Radius marker: ' num2str(r_marker)]);
            if get(handles.sl{1},'value') <= r_marker;
                set(handles.sl{1},'value',r_marker+1);
                set(handles.text{1},'string',['Inner radius: ' num2str(r_marker+1)]);
                r_inner = r_marker+1;
            end
             if get(handles.sl{2},'value') <= r_marker;
                set(handles.sl{2},'value',r_marker+2);
                set(handles.text{2},'string',['Outer radius: ' num2str(r_marker+2)]);
                r_outer = r_marker+2;
            end
        end    
        
        
        [Trgb2gray,imring,imdil] = utvid_calcTrgbINIT(im,coords,r_marker,r_outer,r_inner);
        
        w = Trgb2gray.w;            % the linear mapping
        W = Trgb2gray.W;            % the quadratic mapping
        
        goo = reshape(im,size(im,1)*size(im,2),3);
        imlikel= sum(goo.*(W*goo')',2)+goo*w;        % the pixel log-likelihood ratio
        imlikel = reshape(imlikel,size(im,1),size(im,2));
        Im_filtered = ut_gauss(imlikel,2.5);        % low pass filtering to suppress multiple responses
        cla(handles.hax1)
        axes(handles.hax1);imshow(Im_filtered,[]);
        cla(handles.hax2)
        axes(handles.hax2), imshow(im,[]); % display original filtered image
        green = cat(3, zeros(size(Im_filtered)), ones(size(Im_filtered)), zeros(size(Im_filtered)));% Make a truecolor all-green image.
        hold on;
        h = imshow(green); % display all green on top of original
        hold off
        set(h, 'AlphaData', imring+imdil)
        guidata(enhanceFig,handles);
    end
end