function [ utvid ] = utvid_init(hMainFigure,utvid)
%UTVID_INIT Summary of this function goes here
%   Detailed explanation goes here
% Version added in utvid struct;
utvid.settings.cdir = pwd;          % save current directory path
if ischar(utvid.settings.dir_data) ~= 1 % check if path is already selected in drow down menu
    utvid.settings.dir_data = uigetdir('..\..','select data folder'); % select data directory with a GUI
    curfold = utvid.settings.historyfolder;
    i = 1;
    while i <= 10 || i == length(curfold)+1 %create list 10 last used folders
        if i == 1
            historyfolder{i} = utvid.settings.dir_data;
            I = find(ismember(curfold,utvid.settings.dir_data)); % find if currently 
            if isempty(I) ~= 1      % selected folder is already in existing list
                curfold(I) = [];    %if existed, clear it from the list
            end
        elseif i <= length(curfold)+1
            historyfolder{i} = curfold{i-1};
        else 
            historyfolder{i} = ' ';
        end
        i = i+1;
    end
    utvid.settings.historyfolder = historyfolder;
    
    save([utvid.settings.cdir '\functions\utility\historyfolder.mat'] ,'historyfolder')
else
    curfold = utvid.settings.historyfolder;
    i = 1;

    while i <= 10 || i == length(curfold)+1 %create list 10 last used folders
        if i == 1
            historyfolder{i} = utvid.settings.dir_data;
            I = find(ismember(curfold,utvid.settings.dir_data)); % find if currently 
            if isempty(I) ~= 1      % selected folder is already in existing list
                curfold(I) = [];    %if existed, clear it from the list
            end
        elseif i <= length(curfold)+1
            historyfolder{i} = curfold{i-1};
        else 
            historyfolder{i} = ' ';
        end
        i = i+1;
    end
    utvid.settings.historyfolder = historyfolder;
    save([utvid.settings.cdir '\Functions\utility\historyfolder.mat'] ,'historyfolder')
end
v = version;
utvid.settings.version = v(end-6:end-2);
cd(utvid.settings.dir_data);        % change directory to data directory
if  exist('init.mat','file') ~=0    % check for existence of init.mat file
    handles = utvid.handle;
    disp('Loading init.mat')
    load('init.mat','utvid')                % load init.mat
    disp('init.mat loaded succesfully')
    utvid.handle = handles;
else                                % if init.mat doesnot exist execute the following:
    %% Sort videos in left , center, and, right camera
    utvid.settings.cam.left = '21301891_';   % string in videofilename of left camera
    utvid.settings.cam.center = '21301287_'; % string in videofilename of center camera
    utvid.settings.cam.right = '21301890_';  % string in videofilename of right camera
    try 
        utvid.movs.calb.left = dir([utvid.settings.dir_data '\Calibration\*' utvid.settings.cam.left '*.avi']);
        utvid.movs.calb.right = dir([utvid.settings.dir_data '\Calibration\*' utvid.settings.cam.right '*.avi']);
        utvid.movs.calb.center = dir([utvid.settings.dir_data '\Calibration\*' utvid.settings.cam.center '*.avi']);
    catch
        disp('Something went wrong with the calibration videos, probably no video files were found')
    end
    
    try
        if isempty(dir([utvid.settings.dir_data '\Video\NEW*.avi'])) == 0;
            movlist = dir([utvid.settings.dir_data '\Video\NEW*.avi']);
            utvid.settings.state = 2;       % set utvid.settings.state to STEP 1 of 8
        else
            utvid.settings.state = 1;       % set utvid.settings.state to STEP 1 of 8
            movlist = dir([utvid.settings.dir_data '\Video\*.avi']); % total list of movies in data directory
        end
        % sort movlist into movs.left, movs.center, and, movs.right
        cL = 1; cM = 1; cR = 1; % count start at 1
        for i = 1:size(movlist,1)
            if strfind(movlist(i).name,utvid.settings.cam.left)
                utvid.movs.left(1,cL) = i; % set current movlist entry in left camera list
                % some recordings encompass multiple videos, in the second row
                % the number of the video is stored, first (0), second (1),
                % third (2), etc.
                utvid.movs.left(2,cL) = str2double(movlist(i).name(strfind(movlist(i).name,utvid.settings.cam.left)+length(utvid.settings.cam.left):end-4));
                cL = cL + 1; % count + 1
            elseif strfind(movlist(i).name,utvid.settings.cam.center)
                utvid.movs.center(1,cM) = i; % set current movlist entry in center camera list
                % some recordings encompass multiple videos, in the second row
                % the number of the video is stored, first (0), second (1),
                % third (2), etc.
                utvid.movs.center(2,cM) = str2double(movlist(i).name(strfind(movlist(i).name,utvid.settings.cam.center)+length(utvid.settings.cam.center):end-4));
                cM = cM + 1; % count + 1
            elseif strfind(movlist(i).name,utvid.settings.cam.right)
                utvid.movs.right(1,cR) = i; % set current movlist entry in right camera list
                % some recordings encompass multiple videos, in the second row
                % the number of the video is stored, first (0), second (1),
                % third (2), etc.
                utvid.movs.right(2,cR) = str2double(movlist(i).name(strfind(movlist(i).name,utvid.settings.cam.right)+length(utvid.settings.cam.right):end-4));
                cR = cR + 1; % count + 1
            end
        end
        % check for number of cameras
        nrcams = 3;
        if cL == 1;nrcams = nrcams-1;end
        if cM == 1;nrcams = nrcams-1;end
        if cR == 1;nrcams = nrcams-1;end
        utvid.settings.nrcams = nrcams;    
        utvid.movs.list = movlist;
        utvid.movs.instrstart = find(utvid.movs.left(2,:)==0);
        clear cL cM cR movlist i 
        save('init.mat');               % save everything to init.mat
    catch
        disp('Something went wrong, probably no video files were found')
    end
end
cd(utvid.settings.cdir);                        % change directory back to current directory path

%% Geeft een error???
% guidata(hMainFigure,utvid); 

end

