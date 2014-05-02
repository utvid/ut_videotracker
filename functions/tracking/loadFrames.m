function utvid = loadFrames(utvid,handles)

if strcmp(utvid.settings.version,'R2012')
    utvid.Tracking.FrameL = im2double(read(utvid.Tracking.ObjL,utvid.Tracking.n+1));
    utvid.Tracking.FrameR = im2double(read(utvid.Tracking.ObjR,utvid.Tracking.n+1));
    utvid.Tracking.FrameM = im2double(read(utvid.Tracking.ObjM,utvid.Tracking.n+1));
elseif strcmp(utvid.settings.version,'R2013')
    utvid.Tracking.FrameL = im2double(read(utvid.Tracking.ObjL,utvid.Tracking.n));
    utvid.Tracking.FrameR = im2double(read(utvid.Tracking.ObjR,utvid.Tracking.n));
    utvid.Tracking.FrameM = im2double(read(utvid.Tracking.ObjM,utvid.Tracking.n));
else
    disp('Version not yet implemented')
end

axes(handles.hax{1,1}), imshow(utvid.Tracking.FrameL,[]);
axes(handles.hax{1,2}), imshow(utvid.Tracking.FrameR,[]);
axes(handles.hax{1,3}), imshow(utvid.Tracking.FrameM,[]);

end