function [coords] = correctPoints(Im,nrMar,coords,str)
% Im = image 
% nrMar = number of markers in coords variable
% coords = struct with x and y location of ten markers:
% coords.x and coords.y
% str = string containting the title of the figure
% output coords same as input coords but with corrected x and y values
f = figure;
aH= axes('Xlim', [0,1],'Ylim',[0 1], 'ButtonDownFcn', @startDragFcn);
imshow(Im); title(str);
coords_corr = coords;
for i = 1:nrMar
    h{i} = line([coords.x(i)-5 coords.x(i)-5 coords.x(i)+5 coords.x(i)+5 coords.x(i)-5],...
        [coords.y(i)-5 coords.y(i)+5 coords.y(i)+5 coords.y(i)-5 coords.y(i)-5], ...
        'color','green',...
        'linewidth', 3, ...
        'ButtonDownFcn', @startDragFcn);
end

set(f,'WindowButtonUpFcn', @stopDragFcn);
set(gcf,'CloseRequestFcn',@cp_close);
uiwait(gcf)
    function cp_close(varargin)
        coords = coords_corr;
       delete(gcf)
    end

    function stopDragFcn(varargin)
        set(f,'WindowButtonMotionFcn', '');
        for i = 1:length(h)
            set(h{i},'color','green');
        end
    end

    function startDragFcn(varargin)
        set(f,'WindowButtonMotionFcn', @draggingFcn);
    end

    function draggingFcn(varargin)
        pt = get(aH,'CurrentPoint');
        for i = 1:length(h)
            xc = get(h{i},'XData'); yc = get(h{i},'YData'); Coordh = [mean(xc(2:3)), mean(yc(1:2))];
            dist(i) = norm(Coordh-[pt(1),pt(3)]);
        end
        [~,I] = find(dist==min(dist));
        set(h{I},'XData',[pt(1)-5 pt(1)-5 pt(2)+5 pt(2)+5 pt(1)-5],'YData',[pt(3)-5 pt(4)+5 pt(4)+5 pt(3)-5 pt(3)-5],'color','red');
        coords_corr.x(I) =  pt(1);
        coords_corr.y(I) =  pt(3);
    end

end