function [x,y] = getPoints(Im,nrMarkers,str);
figure; imshow(Im); title(str);
hold on;
x=[];y=[];
k = 1;
while k <= nrMarkers+1
    try
        [x(k),y(k)]=ginput(1);
        h(k) = plot(x(k),y(k),'or','MarkerSize',5);
        k = k+1;
        if k==nrMarkers+1;
            try
                [x(k),y(k)]=ginput(1);
                x(k)=[];y(k)=[];
                k=k+1;
            catch
                k = k-1;
                x(k)=[];y(k)=[];
                delete(h(k))
            end
        end
    catch
        if k~=1;
            k = k-1;
            x(k)=[];y(k)=[];
            delete(h(k))
        end
    end
end
hold off;
close
end