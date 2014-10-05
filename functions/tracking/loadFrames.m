function utvid = loadFrames(utvid,handles)
cf = cumsum(utvid.Tracking.NoF); % total number of frames
idx = find(cf>=utvid.Tracking.n,1,'first');
if idx>1
    n = utvid.Tracking.n-cf(idx-1);
else
    idx = 1;
    n = utvid.Tracking.n;
end
% read frames
if strcmp(utvid.settings.version,'R2012')
    utvid.Tracking.FrameLorig = im2double(read(utvid.Tracking.ObjL{idx},n+1));
    utvid.Tracking.FrameRorig = im2double(read(utvid.Tracking.ObjR{idx},n+1));
    utvid.Tracking.FrameMorig = im2double(read(utvid.Tracking.ObjM{idx},n+1));
elseif strcmp(utvid.settings.version,'R2013')
    utvid.Tracking.FrameLorig = im2double(read(utvid.Tracking.ObjL{idx},n));
    utvid.Tracking.FrameRorig = im2double(read(utvid.Tracking.ObjR{idx},n));
    utvid.Tracking.FrameMorig = im2double(read(utvid.Tracking.ObjM{idx},n));
else
    disp('Version not yet implemented')
end

%
for j = 1:utvid.settings.nrcams
    
    if      j == 1; im = utvid.Tracking.FrameLorig;
    elseif  j == 2; im = utvid.Tracking.FrameRorig;
    elseif  j == 3; im = utvid.Tracking.FrameMorig;
    end
    try
        % image enhancement using quadratic mapping
        if utvid.settings.nrOrMar ~= 0
            w = utvid.enhancement.Trgb2gray_or{utvid.Tracking.instr,j}.w;            % the linear mapping
            W = utvid.enhancement.Trgb2gray_or{utvid.Tracking.instr,j}.W;            % the quadratic mapping
            
            goo = reshape(im,size(im,1)*size(im,2),3);
            imlikel=sum(goo.*(W*goo')',2)+goo*w;        % the pixel log-likelihood ratio
            imlikel = reshape(imlikel,size(im,1),size(im,2));
            Im_filteredor = ut_gauss(imlikel,2.5);
            if      j == 1; utvid.Tracking.FrameLor = Im_filteredor;
            elseif  j == 2; utvid.Tracking.FrameRor = Im_filteredor;
            elseif  j == 3; utvid.Tracking.FrameMor = Im_filteredor;
            end
        end
        %             R = im(:,:,1);
        %             G = im(:,:,2);
        %             B = im(:,:,3);
        %             R(R>.4|R<.1)=1;
        %             G(G>.3|G<.1)=1;
        %             B(B>.3|B<.2)=1;
        %             im(:,:,1) = R;
        %             im(:,:,2) = G;
        %             im(:,:,3) = B;
        
        w = utvid.enhancement.Trgb2gray{utvid.Tracking.instr,j}.w;            % the linear mapping
        W = utvid.enhancement.Trgb2gray{utvid.Tracking.instr,j}.W;            % the quadratic mapping
        goo = reshape(im,size(im,1)*size(im,2),3);
        imlikel=sum(goo.*(W*goo')',2)+goo*w;        % the pixel log-likelihood ratio
        imlikel = reshape(imlikel,size(im,1),size(im,2));
        Im_filtered = ut_gauss(imlikel,2.5);
    catch
        disp('Something went wrong with filtering');
    end
    if      j == 1; utvid.Tracking.FrameL = Im_filtered;
    elseif  j == 2; utvid.Tracking.FrameR = Im_filtered;
    elseif  j == 3; utvid.Tracking.FrameM = Im_filtered;
    end
    
end
end