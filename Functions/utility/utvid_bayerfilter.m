function utvid_bayerfilter(utvid,compression)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here 
    h = waitbar(0,'Please wait debayering and compressing videos');
    for i = 1:size(utvid.movs.list,1)
        waitbar(i/size(utvid.movs.list,1))
        
        utvid.movs.obj{i} =  VideoReader([utvid.settings.dir_data '\Video\' utvid.movs.list(i).name]);
        if compression == 1
            profile = 'Motion JPEG AVI';
            wobj = VideoWriter([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(i).name],profile);
            wobj.Quality = utvid.settings.vidquality;
        else
            profile = 'Uncompressed AVI';
            wobj = VideoWriter([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(i).name],profile);
        end
        wobj.FrameRate = utvid.movs.obj{i}.FrameRate;
        open(wobj);
        
        h2 = waitbar(0,['Processing video ' num2str(i) ' of ' num2str(size(utvid.movs.list,1))]);
        for f = 1:utvid.movs.obj{i}.NumberOfFrames
            waitbar(f/utvid.movs.obj{i}.NumberOfFrames);
            I = read(utvid.movs.obj{i},f);
            I = demosaic(I(:,:,1),'rggb');
            for ii = 1:3
                I(:,:,ii) = flipud(I(:,:,ii));
            end
            writeVideo(wobj,I);
        end
        close(h2)
        close(wobj);
    end
    close(h)
end