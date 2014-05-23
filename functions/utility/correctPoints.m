function [coords] = correctPoints(Im,nrMar,coords,str,mins,maxs)
f = figure; 

% axes(h1)
aH= axes('ButtonDownFcn', @startDragFcn);
hold on
imshow(Im,[]); title(str); 
xlim([mins(1)-25 maxs(1)+25]);
ylim([mins(2)-25 maxs(2)+25]);

for i = 1:nrMar
    h{i} = line([coords(i,1)-5 coords(i,1)-5 coords(i,1)+5 coords(i,1)+5 coords(i,1)-5],...
        [coords(i,2)-5 coords(i,2)+5 coords(i,2)+5 coords(i,2)-5 coords(i,2)-5], ...
        'color','green','linewidth', 3, ...
        'ButtonDownFcn', @startDragFcn);
end

set(f,'WindowButtonUpFcn', @stopDragFcn);
% coords
uiwait(f)
    function stopDragFcn(varargin)
        set(f,'WindowButtonMotionFcn', '');
%         coords
        for i = 1:length(h)
            set(h{i},'color','green');
        end
        guidata(f,coords)
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
        coords(I,1) = pt(1); coords(I,2) = pt(3);
    end

end