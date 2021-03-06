function [ output_args ] = utvid_init(hMainFigure,utvid)
%UTVID_INIT Summary of this function goes here
%   Detailed explanation goes here

utvid.settings.dir_data = uigetdir('..\..','select data folder'); % select data directory with a GUI
savepwd = pwd;                      % save current directory path
cd(utvid.settings.dir_data);        % change directory to data directory
if  exist('init.mat','file') ~=0    % check for existence of init.mat file
    load('init.mat')                % load init.mat
else                                % if init.mat doesnot exist execute the following:
    %% Sort videos in left , center, and, right camera
    utvid.settings.cam.left = '21301891_';   % string in videofilename of left camera
    utvid.settings.cam.center = '21301287_'; % string in videofilename of center camera
    utvid.settings.cam.right = '21301890_';  % string in videofilename of right camera
    
    movlist = dir([utvid.settings.dir_data '\Video\*.avi']); % total list of movies in data directory
    % sort movlist into movs.left, movs.center, and, movs.right
    cL = 1; cM = 1; cR = 1; % count start at 1
    for i = 1:size(movlist,1)
        if strfind(movlist(i).name,utvid.settings.cam.left)
            movs.left(1,cL) = i; % set current movlist entry in left camera list
            % some recordings encompass multiple videos, in the second row
            % the number of the video is stored, first (0), second (1),
            % third (2), etc.
            movs.left(2,cL) = str2double(movlist(i).name(strfind(movlist(i).name,utvid.settings.cam.left)+length(utvid.settings.cam.left):end-4));
            cL = cL + 1; % count + 1
        elseif strfind(movlist(i).name,utvids.settings.cam.center)
            movs.center(1,cM) = i; % set current movlist entry in center camera list
            % some recordings encompass multiple videos, in the second row
            % the number of the video is stored, first (0), second (1),
            % third (2), etc.
            movs.center(2,cM) = str2double(movlist(i).name(strfind(movlist(i).name,utvid.settings.cam.center)+length(utvid.settings.cam.center):end-4));     
            cM = cM + 1; % count + 1
        elseif strfind(movlist(i).name,utvids.settings.cam.right)
            movs.right(1,cR) = i; % set current movlist entry in right camera list
            % some recordings encompass multiple videos, in the second row
            % the number of the video is stored, first (0), second (1),
            % third (2), etc.
            movs.right(2,cR) = str2double(movlist(i).name(strfind(movlist(i).name,utvid.settings.cam.right)+length(utvid.settings.cam.right):end-4));
            cR = cR + 1; % count + 1
        end
    end
    
    utvid.settings.state = 1;       % set utvid.settings.state to STEP 1 of 8
    save('init.mat');               % save everything to init.mat
end

cd(savepwd);                        % change directory back to current directory path

guidata(hMainFigure,utvid);

end

