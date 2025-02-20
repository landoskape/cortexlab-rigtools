% Checks available disk space and estimates remaining recording time
%
% Inputs:
%   dataPath - Optional path to check (defaults to dat.paths.localRepository)
%   blame - Optional boolean to show detailed usage breakdown (default true)
%
% Displays:
%   - Available space in GB
%   - Table showing estimated recording time left for different configurations:
%     - Resolution: 256x256 to 1024x1024
%     - Channels: 1-4 channels
%   - Opens GUI showing disk usage by mouse/user
%
% Uses diskSpaceBlame or diskSpaceUsed to show detailed usage information

function diskSpaceLeft(dataPath, blame)

if nargin<1
    p = dat.paths;
    dataPath = p.localRepository;
end

if nargin<2
    blame = true;
end

bytesFree = java.io.File(dataPath).getUsableSpace;

nChannels = [1, 2, 3, 4];
nLines = [256, 512, 1024];
resoFrequency = 8e3; % can be replaced with the actual reading from the hSI objects

resolution = {'256x256', '512x512', '1024x1024'};
channels = {'1ch', '2ch', '3ch', '4ch'};

sz = [numel(nLines), numel(nChannels)];
timeLeftTable = table('Size', sz, 'VariableTypes', repmat({'string'}, numel(nChannels), 1));
timeLeftTable.Properties.RowNames = resolution;
timeLeftTable.Properties.VariableNames = channels;

for iCh = 1:numel(nChannels)
    for iL = 1:numel(nLines)
        bytesPerFrame = nLines(iL)^2*2*nChannels(iCh);
        framesPerSecond = resoFrequency/nLines(iL)*2; % assuming bidirectional scanning
        secondsLeft = bytesFree/framesPerSecond/bytesPerFrame;
        hh = floor(secondsLeft/3600);
        mm = floor((secondsLeft - hh*3600)/60);
        ss = secondsLeft - hh*3600 - mm * 60;
        timeLeft = sprintf('%dh:%02dm:%02.0fs', hh, mm, ss);
        timeLeftTable(iL, iCh) = {timeLeft};
    end
end

msg = {sprintf('You have %3.1f GB left on the disk', bytesFree/1024^3);...
    sprintf('Check command window for more info')};

if blame
    usedSpace = diskSpaceBlame;
else
    usedSpace = diskSpaceUsed;
end
disp(usedSpace);
disp(timeLeftTable);
diskSpaceWarning(msg, usedSpace);

    function diskSpaceWarning(msg, diskSpace)
        dboxWidth = 1000;
        dboxHeight = 500;
        tableWidth = 500;
        dbox = dialog('Position',[700 500 dboxWidth dboxHeight],'Name','disk space warning');
        % Display diskSpaceWarning Message
        uicontrol('Parent',dbox,'Style','text','Position',[10 dboxHeight-110 dboxWidth-20 100],'String',msg,'FontSize',24);
        % Display dataused table
        uitable('Parent',dbox,'Data', diskSpace{:, :}, 'Position',[10 10 tableWidth 350],...
            'ColumnName',diskSpace.Properties.VariableNames,'RowName',diskSpace.Properties.RowNames);
        % Button to close box
        uicontrol('Parent',dbox,'Position',[tableWidth+20 10 dboxWidth-tableWidth-30 350],...
            'String','okay','FontSize',24,'Callback',@okayToContinue);
        % Display timeleft table

        uiwait(dbox);
    
        function okayToContinue(~,~)
            delete(dbox)
        end
    end

end





