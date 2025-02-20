% Analyzes disk usage by user and mouse, calculating "GB-days" metric
%
% Inputs:
%   dataPath - Optional path to analyze (defaults to dat.paths.localRepository)
%
% Returns:
%   dataTable - Table with columns:
%     - User: User initials from mouse name
%     - MouseName: Full mouse ID
%     - Date: Recording date
%     - Size_GB: Folder size in gigabytes
%     - DaysSinceCreation: Days since folder was created
%     - GB_Days: Size_GB × DaysSinceCreation
%
% If no output requested, displays summary by user and detailed usage table
function dataTable = diskSpaceBlame(dataPath)

if nargin<1
    p = dat.paths;
    dataPath = p.localRepository;
end

mouseFolders = dir(dataPath);
mouseFolders = mouseFolders([mouseFolders.isdir]);
mouseFolders = mouseFolders(~ismember({mouseFolders.name}, {'.', '..'}));

userGBDays = containers.Map();
allData = cell(0, 6);

currentDate = datetime('now');

for i = 1:numel(mouseFolders)
    mouseName = mouseFolders(i).name;
    
    userMatch = regexp(mouseName, '^([A-Za-z]{2,3})\d', 'tokens', 'once');
    if isempty(userMatch)
        warning('Invalid mouse name format: %s. Skipping this folder.', mouseName);
        continue;
    end
    user = userMatch{1};
    
    % Get date folders for this mouse
    dateFolders = dir(fullfile(dataPath, mouseName));
    dateFolders = dateFolders([dateFolders.isdir]);
    dateFolders = dateFolders(~ismember({dateFolders.name}, {'.', '..'}));

    for j = 1:numel(dateFolders)
        dateFolder = dateFolders(j).name;
        folderPath = fullfile(dataPath, mouseName, dateFolder);
        
        % Calculate folder size in GB
        folderSize = dirSize(folderPath) / 1024^3;
        
        % Calculate days since folder creation
        folderDate = datetime(dateFolder, 'InputFormat', 'yyyy-MM-dd');
        daysSinceCreation = floor(days(currentDate - folderDate)) + 1;
        
        % Calculate GB-days
        gbDays = folderSize * daysSinceCreation;

        % Add to user's total GB-days
        if isKey(userGBDays, user)
            userGBDays(user) = userGBDays(user) + gbDays;
        else
            userGBDays(user) = gbDays;
        end

        % Store detailed information
        allData = cat(1, allData, {user, mouseName, dateFolder, folderSize, daysSinceCreation, gbDays});
    end
end

% Convert allData to table
dataTable = cell2table(allData, 'VariableNames', {'User', 'MouseName', 'Date', 'Size_GB', 'DaysSinceCreation', 'GB_Days'});

% Sort the table by user and GB-days (descending order)
[~, userOrder] = sort(cell2mat(values(userGBDays)), 'descend');
sortedUsers = keys(userGBDays);
sortedUsers = sortedUsers(userOrder);

% Create the final sorted table
sortedDataTable = table();
for i = 1:numel(sortedUsers)
    user = sortedUsers{i};
    userData = dataTable(strcmp(dataTable.User, user), :);
    userData = sortrows(userData, 'GB_Days', 'descend');
    sortedDataTable = cat(1, sortedDataTable, userData);
end

% Display results
if nargout == 0
    % Display summary by user
    fprintf('\nSummary by User (Total GB-Days):\n');
    for i = 1:numel(sortedUsers)
        user = sortedUsers{i};
        fprintf('%s: %.2f GB-Days\n', user, userGBDays(user));
    end

    % Display detailed table
    fprintf('\nDetailed Usage:\n');
    disp(sortedDataTable);
    clear sortedDataTable;
else
    dataTable = sortedDataTable(:, 4:end);
    namePerFolder = cellfun(@(n,d) sprintf('%s / %s', n, d), sortedDataTable{:, 2}, sortedDataTable{:, 3}, 'uni', 0);
    dataTable.Properties.RowNames = namePerFolder;
end

end

% Recursively measure size of a directory
function out = dirSize(dataPath)
    topDir = dir(dataPath);
    out = 0;
    for subDir = 1:1:numel(topDir)
        if ~strcmp(topDir(subDir).name,'.')&&~strcmp(topDir(subDir).name,'..')
            out = out + topDir(subDir).bytes;
            if topDir(subDir).isdir 
                out = out + dirSize(fullfile(dataPath,topDir(subDir).name));
            end
        end
    end
end


