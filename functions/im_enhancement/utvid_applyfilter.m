function [Im_filtered,Trgb2gray] = utvid_applyfilter(im,coords,handles)
if strcmpi(handles.mono,'false')==1
    for i = 1:size(im,3)
        Im_filtered(:,:,i) = ut_gauss(handles.alpha*im(:,:,i) ...
            -(handles.alpha-1)*ut_gauss(im(:,:,i),handles.sigma_up),...
            handles.sigma_down);
    end
    
elseif strcmpi(handles.mono,'true')==1
    try
        Trgb2gray = utvid_calcTrgb(im,coords,handles.vertical,handles.horizontal);
        handles.imbw = reshape(reshape(im,size(im,1)*size(im,2),3)*...
            Trgb2gray,size(im,1),size(im,2));
        handles.imenergy = imfilter(handles.imbw.^2,handles.averpsf,'replicate');
        handles.imt = ut_gauss(handles.alpha*handles.imbw-(handles.alpha-1)*...
            ut_gauss(handles.imbw,handles.sigma_up),handles.sigma_down);
        Im_filtered = handles.a*handles.imt - handles.b*handles.imenergy;
    catch
        disp('Something went wrong with filtering');
    end
    
end

end