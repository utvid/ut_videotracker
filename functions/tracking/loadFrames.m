function utvid = loadFrames(utvid,handles)

utvid.Tracking.FrameL = im2double(read(utvid.Tracking.ObjL,utvid.Tracking.n));
utvid.Tracking.FrameR = im2double(read(utvid.Tracking.ObjR,utvid.Tracking.n));
utvid.Tracking.FrameM = im2double(read(utvid.Tracking.ObjM,utvid.Tracking.n));

axes(handles.hax{1,1}), imshow(utvid.Tracking.FrameL,[]);
axes(handles.hax{1,2}), imshow(utvid.Tracking.FrameR,[]);
axes(handles.hax{1,3}), imshow(utvid.Tracking.FrameM,[]);

end