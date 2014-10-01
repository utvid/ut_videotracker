function [Im_filtered,Trgb2gray] = utvid_applyfilter(im,coords,handles)
if strcmpi(handles.mono,'false')==1
    for i = 1:size(im,3)
        Im_filtered(:,:,i) = ut_gauss(handles.alpha*im(:,:,i) ...
            -(handles.alpha-1)*ut_gauss(im(:,:,i),handles.sigma_up),...
            handles.sigma_down);
    end
    Trgb2gray = [];
    
elseif strcmpi(handles.mono,'true')==1
    try
        Trgb2gray = utvid_calcTrgb(im,coords);
        w = Trgb2gray.w;            % the linear mapping
        W = Trgb2gray.W;            % the quadratic mapping
        goo = reshape(im,size(im,1)*size(im,2),3);
        imlikel=sum(goo.*(W*goo')',2)+goo*w;        % the pixel log-likelihood ratio           
        imlikel = reshape(imlikel,size(im,1),size(im,2));
        Im_filtered = ut_gauss(imlikel,2.5);        % low pass filtering to suppress multiple responses

    catch
        disp('Something went wrong with filtering');
    end
    
end

end