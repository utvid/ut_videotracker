function [utvid] = measurement(utvid)
% inputs:    utvid,
%            frames = {FrameL,FrameR,FrameM}
%            str = or / shape
%            n = framenumber
str = {'or','shape'};

if utvid.coords.nOrMar ~= 0
    jmax = 1;
else
    jmax = 2;
end

for j = 1:jmax
    frames = {utvid.Tracking.FrameL,utvid.Tracking.FrameR,utvid.Tracking.FrameM};
    cam = {'left','right','center'};
    if isfield(utvid.settings,'Measmethod')~=1
        utvid.settings.Measmethod = 'minsearch';
    end
    
    for i = 1:utvid.settings.nrcams
        im  = frames{i};
        if i == 1
            x   = utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n) ;
            y   = utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n) ;
        elseif i == 2
            x   = utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n) ;
            y   = utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n) ;
        elseif i == 3
            x   = utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n) ;
            y   = utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n) ;
        end
        
        switch utvid.settings.Measmethod
            case 'findblue'
                [x,y] = findblue(x,y,im,utvid.Tracking.roi);
            case 'minsearch'
                [x,y] = minsearch(x,y,im,utvid.Tracking.roi);
            case 'templatematching'
                [x,y] = templatematching(x,y,im,utvid.Tracking.roi);
            case 'findcircle'
                [x,y] = findcircle(x,y,im,utvid.Tracking.roi);
            otherwise
                disp('No valid measurement setting selected');
        end
        utvid.Tracking.(str).meas2D.(cam{i}).x(:,utvid.Tracking.n) = x;
        utvid.Tracking.(str).meas2D.(cam{i}).y(:,utvid.Tracking.n) = y;
    end
end

end