# cortexlab-rigtools
A very small package for some rig utilities.

At B2 we built some simple scripts that are very useful for copying imaging data to the server and checking how much disk space is left before running an experiment. This repository contains the template for those scripts.

## Installation
There's no fancy install system. Just copy the files or clone them with:

```bash
git clone https://github.com/landoskape/cortexlab-rigtools
``` 

Then add them to the matlab path, and you're ready. 

## Dependencies
The only dependency is [rigbox](https://github.com/cortex-lab/Rigbox). This is because we use the ``dat.paths`` structure to identify paths. 

> [!WARNING]
> The utilities here will only work as you expect insofar as you set these paths correctly!

Follow the instructions on the rigbox github page to set your dat paths.

## Diskspace Utility
The diskspace utility checks how much diskspace is left and also attempts to report how much time you should be able to image based on the amount of diskspace left. In addition, it opens a window that shows you which mice are responsible for diskspace usage. 

> **NOTE:** ``diskSpaceLeft`` will look in the path set by ``p = dat.paths.localRepository``

To use it, simply run:

  ```matlab
  diskSpaceLeft()
  ```

This will:
1. Show you how many GB are left on your data drive
2. Display a table showing how much recording time you have left for different imaging configurations (256x256 up to 1024x1024, and 1-4 channels)
3. Open a window showing which mice/sessions are using up your disk space
4. Calculate "GB-days" (GB × days since creation) to help identify old data that could be moved to free up space

You can also check disk usage without the GUI:

  ```matlab
  diskSpaceBlame()  % Shows detailed usage by user and mouse
  diskSpaceUsed()   % Shows simple folder sizes
  ```

## Copydata Utility
The copydata utility is an easy way to move data from a local directory to the server after an experiment. 


> [!WARNING]
> The copy data utility will copy data from ``dat.paths.localRepository`` to ``dat.paths.mainRepository``. Make sure you set these correctly, if you don't you might overwrite old data!!

The copydata utility uses Windows' [robocopy](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy) command and will show you progress as it copies. The function will return different status codes to let you know if:
- All files copied successfully
- Some files were skipped (already exist)
- There were mismatches or additional files
- Any errors occurred

The robocopy command is super useful and has lots of special parameterization options for handling specific filetypes etc. You might want to edit your local copy if necessary. See the [documentation](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy) for assistance. 

You can use the copydata utility in one of two ways:

### Completely within matlab
All you have to do is use the following command:

  ```matlab
  copyImagingData(mouse_name, date_string[optional], session_id[optional])
  ```

For example:

  ```matlab
  copyImagingData('AB123')                    % Copies all data from this mouse
  copyImagingData('AB123', '2024-03-21')      % Copies all data from specific mouse and date
  copyImagingData('AB123', '2024-03-21', '1') % Copies specific session
  ```

Running ``copyImagingData`` will open a dialog box to confirm you want to copy the files, showing you exactly what command will be run. This helps prevent accidental copies to wrong locations.

The "within-matlab" system is nice because it's all matlab and you probably already have matlab open. However, it's problematic because it can take a while depending on how much data you are copying, and it will prevent matlab from closing.


### In a dedicated command window
You can also use matlab to get the copy string, then actually do the copying in a dedicated window. Like this:
1. Running `getCopyString(mouse_name, date_string[optional], session_id[optional])` in matlab
2. Opening a command window (for example windows, type "cmd", press enter, should open a command prompt)
3. Ctrl-V (i.e. paste, because `getCopyString` puts the copy string into the clipboard)
4. Press enter
