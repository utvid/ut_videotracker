function [Im_filtered,handles] = utvid_applyfilter(im,coords,handles)

for i = 1:size(im,3)
    Im_filtered(:,:,i) = ut_gauss(handles.alpha*im(:,:,i) ...
        -(handles.alpha-1)*ut_gauss(im(:,:,i),handles.sigma_up),...
        handles.sigma_down);
end

if strcmpi(handles.mono,'true')==1
try 
    handles.Trgb2gray = utvid_calcTrgb(Im_filtered,coords,handles.vertical,handles.horizontal);
    handles.imbw = reshape(reshape(im,size(im,1)*size(im,2),3)*...
        handles.Trgb2gray,size(im,1),size(im,2));
    handles.imenergy = imfilter(handles.imbw.^2,handles.averpsf,'replicate');
    handles.imt = ut_gauss(handles.alpha*handles.imbw-(handles.alpha-1)*...
        ut_gauss(handles.imbw,handles.sigma_up),handles.sigma_down);
    Im_filtered = handles.a*handles.imt - handles.b*handles.imenergy;
catch 
   disp('Something went wrong with filtering'); 
end
end

end