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
    utvid.Tracking.FrameLorig = im2double(read(utvid.Tracking.Obj.left{idx},n+1));
    utvid.Tracking.FrameRorig = im2double(read(utvid.Tracking.Obj.right{idx},n+1));
    utvid.Tracking.FrameMorig = im2double(read(utvid.Tracking.Obj.center{idx},n+1));
elseif strcmp(utvid.settings.version,'R2013')
    utvid.Tracking.FrameLorig = im2double(read(utvid.Tracking.Obj.left{idx},n));
    utvid.Tracking.FrameRorig = im2double(read(utvid.Tracking.Obj.right{idx},n));
    utvid.Tracking.FrameMorig = im2double(read(utvid.Tracking.Obj.center{idx},n));
else
    disp('Version not yet implemented')
end



%
for j = 1:utvid.Tracking.nrcams
    jj= utvid.Tracking.usecams(j);
    
    if      jj == 1; im = utvid.Tracking.FrameLorig;
    elseif  jj == 2; im = utvid.Tracking.FrameRorig;
    elseif  jj == 3; im = utvid.Tracking.FrameMorig;
    end
    try
        % image enhancement using quadratic mapping
        if utvid.settings.nrOrMar ~= 0
           Im_filteredor = ut_gauss(rgb2gray(ut_single_retinex(im,30,0.01)),2.5);
%             
%             w = utvid.enhancement.Trgb2gray_or{utvid.Tracking.instr,j}.w;            % the linear mapping
%             W = utvid.enhancement.Trgb2gray_or{utvid.Tracking.instr,j}.W;            % the quadratic mapping
%             
%             goo = reshape(im,size(im,1)*size(im,2),3);
%             imlikel=sum(goo.*(W*goo')',2)+goo*w;        % the pixel log-likelihood ratio
%             imlikel = reshape(imlikel,size(im,1),size(im,2));
%             Im_filteredor = ut_gauss(imlikel,2.5);
            if      jj == 1; utvid.Tracking.FrameLor = Im_filteredor;
            elseif  jj == 2; utvid.Tracking.FrameRor = Im_filteredor;
            elseif  jj == 3; utvid.Tracking.FrameMor = Im_filteredor;
            end
        end
            Im_filtered = ut_gauss(rgb2gray(ut_single_retinex(im,30,0.01)),2.5);

% %         w = utvid.enhancement.Trgb2gray{utvid.Tracking.instr,j}.w;            % the linear mapping
% %         W = utvid.enhancement.Trgb2gray{utvid.Tracking.instr,j}.W;            % the quadratic mapping
% %         goo = reshape(im,size(im,1)*size(im,2),3);
% %         imlikel=sum(goo.*(W*goo')',2)+goo*w;        % the pixel log-likelihood ratio
% %         imlikel = reshape(imlikel,size(im,1),size(im,2));
% %         Im_filtered = ut_gauss(imlikel,2.5);
    catch
        disp('Something went wrong with filtering');
    end
    if      jj == 1; utvid.Tracking.FrameL = Im_filtered;
%         utvid.Tracking.FrameLor = im;
    elseif  jj == 2; utvid.Tracking.FrameR = Im_filtered;
%         utvid.Tracking.FrameRor = im;
    elseif  jj == 3; utvid.Tracking.FrameM = Im_filtered;
%         utvid.Tracking.FrameMor = im;
    end
end
end
