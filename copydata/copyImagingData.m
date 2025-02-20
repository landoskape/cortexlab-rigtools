% Copies imaging data from local machine to server using robocopy
%
% Inputs:
%   mouseName - Name of the mouse (e.g. 'AB123')
%   datestr - Optional date string in format 'yyyy-MM-dd'
%   session - Optional session ID
%
% Returns:
%   status - Robocopy exit code indicating copy status
%   cmdout - Command output text from robocopy
%
% Shows a confirmation dialog before copying and displays status message after completion.
% Uses robocopy's exit codes to provide detailed feedback about the copy operation.

function [status,cmdout] = copyImagingData(mouseName,datestr,session)

if nargin<2, datestr=[]; end
if nargin<3, session=[]; end

cmdPromptCommand = getCopyString(mouseName,datestr,session);
[status,cmdout] = runCommandDialog(cmdPromptCommand);

switch status
    case -1
        msg = 'Closed without copying.';
    case 0
        msg = 'No files were copied. No failure was encountered. No files were mismatched. The files already exist in the destination directory; therefore, the copy operation was skipped.';
    case 1
        msg = 'All files were copied successfully.';
    case 2
        msg = 'There are some additional files in the destination directory that are not present in the source directory. No files were copied.';
    case 3
        msg = 'Some files were copied. Additional files were present. No failure was encountered.';
    case 5
        msg = 'Some files were copied. Some files were mismatched. No failure was encountered.';
    case 6
        msg = 'Additional files and mismatched files exist. No files were copied and no failures were encountered meaning that the files already exist in the destination directory.';
    case 7
        msg = 'Files were copied, a file mismatch was present, and additional files were present.';
    case 8
        msg = 'Several files did not copy.';
    otherwise
        msg = 'Unknown message -- probably error. For more information, check: \nhttps://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy';
end
disp(cmdout);
fprintf([msg,'\n\n']);

if nargout==0
    clear('status','cmdout')
end

    % Dialog box handler for running robocopy command
    % Shows command preview and handles copy operation
    function [status,cmdout] = runCommandDialog(cmdPromptCommand)
        dboxWidth = 1000;
        dbox = dialog('Position',[50 100 dboxWidth 130],'Name','copy imaging data');
        closeBtn = uicontrol('Parent',dbox,'Position',[10 10 dboxWidth-20 50],...
            'String','close without copying','FontSize',18,'Callback',@closeDialog);
        uicontrol('Parent',dbox,'Position',[10 70 dboxWidth-20 50],...
            'String',sprintf('run: %s',cmdPromptCommand),'FontSize',18,'Callback',@runCommand);
        status = -1;
        cmdout = [];

        uiwait(dbox);
    
        function runCommand(cmdbtn,~)
            % prevent premature closing
            closeBtn.Enable = 'off';
            closeBtn.String = 'cannot close until robocopy is finished...';
            dbox.CloseRequestFcn = '';
            % prevent user from running this command twice
            cmdbtn.Enable = 'off'; 
            drawnow; % Adding this to force screen to update (not sure if it is necessary)
            [status,cmdout] = system(cmdPromptCommand); % run robocopy
            dbox.CloseRequestFcn = 'closereq';
            closeDialog() % close dialog box
        end

        function closeDialog(~,~)
            delete(dbox)
        end
    end

end



