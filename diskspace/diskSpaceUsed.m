% Shows disk usage by folder in a simple format
%
% Inputs:
%   dataPath - Optional path to analyze (defaults to dat.paths.localRepository)
%
% Returns:
%   dataTable - Table with folder names and their sizes in GB
%
% If no output requested, displays the table directly
%
% Helper function dirSize recursively calculates directory sizes
function dataTable = diskSpaceUsed(dataPath)

if nargin<1
    p = dat.paths;
    dataPath = p.localRepository;
end

dataFolders = dir(dataPath);
dataFolders = dataFolders(logical([dataFolders(:).isdir]));
dataFolders = dataFolders(3:end);
namePerFolder = {dataFolders(:).name};
gbPerFolder = cellfun(@(dname) round(10*dirSize(fullfile(dataPath,dname))/1024^3)/10, namePerFolder, 'uni', 1);
% gbPerFolder = [dataFolders(:).bytes]/1024^3;
sz = [numel(namePerFolder), 1];
dataTable = table('Size', sz, 'VariableTypes', {'double'});
dataTable.Properties.RowNames = namePerFolder;
dataTable.Properties.VariableNames = {'Size (in GB)'};
dataTable(:,1) = num2cell(gbPerFolder)';
if nargout==0
    fprintf('\n')
    disp(dataTable)
    clear dataTable
    return
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


