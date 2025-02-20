% Gets the robocopy command string for copying imaging data between local and server paths
% 
% Inputs:
%   mouseName - Name of the mouse (e.g. 'AB123')
%   datestr - Optional date string in format 'yyyy-MM-dd' 
%   session - Optional session ID
%
% Returns:
%   cmdPromptCommand - Complete robocopy command string for copying data
%
% If no output is requested, copies the command string to clipboard
% Uses dat.paths to get local and server repository paths
% Will copy data from dat.paths.localRepository to dat.paths.mainRepository
function cmdPromptCommand = getCopyString(mouseName, datestr, session)

if nargin<2, datestr=[]; end
if nargin<3, session=[]; end

paths = dat.paths;
sourceString = fullfile(paths.localRepository,mouseName,datestr,session);
targetString = fullfile(paths.mainRepository,mouseName,datestr,session);
cmdPromptCommand = sprintf('robocopy %s %s /s',sourceString,targetString);
disp(cmdPromptCommand);
if nargout==0
    clipboard('copy', cmdPromptCommand);
    clear cmdPromptCommand
end