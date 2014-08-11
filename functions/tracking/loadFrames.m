function utvid = loadFrames(utvid,handles)
cf = cumsum(utvid.Tracking.NoF);
idx = find(cf>=utvid.Tracking.n,1,'first');
if idx>1
    n = utvid.Tracking.n-cf(idx-1);
else
    idx = 1;
    n = utvid.Tracking.n;
end


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

for j = 1:utvid.settings.nrcams
    if      j == 1; im = utvid.Tracking.FrameLorig;
    elseif  j == 2; im = utvid.Tracking.FrameRorig;
    elseif  j == 3; im = utvid.Tracking.FrameMorig;
    end
    if strcmpi(utvid.enhancement.histeq,'true')==1
        for i = 1:size(im,3)
            im2(:,:,i) = histeq(im(:,:,i)); 
        end
       im = im2; clear im2; 
    end
    if strcmpi(utvid.enhancement.mono,'false')==1
        
        for i = 1:size(im,3)
            Im_filtered(:,:,i) = ut_gauss(utvid.enhancement.alpha*im(:,:,i) ...
                -(utvid.enhancement.alpha-1)*ut_gauss(im(:,:,i),utvid.enhancement.sigma_up),...
                utvid.enhancement.sigma_down);
        end
        
    elseif strcmpi(utvid.enhancement.mono,'true')==1
        try
            imbw = reshape(reshape(im,size(im,1)*size(im,2),3)*...
                utvid.enhancement.Trgb2gray,size(im,1),size(im,2));
            imenergy = imfilter(imbw.^2,utvid.enhancement.averpsf,'replicate');
            imt = ut_gauss(utvid.enhancement.alpha*imbw-(utvid.enhancement.alpha-1)*...
                ut_gauss(imbw,utvid.enhancement.sigma_up),utvid.enhancement.sigma_down);
            Im_filtered = utvid.enhancement.a*imt - utvid.enhancement.b*imenergy;
        catch
            disp('Something went wrong with filtering');
        end
    end
    
    if      j == 1; utvid.Tracking.FrameL = Im_filtered;
    elseif  j == 2; utvid.Tracking.FrameR = Im_filtered;
    elseif  j == 3; utvid.Tracking.FrameM = Im_filtered;
    end
    
    
end

end