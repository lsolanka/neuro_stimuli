%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
%                 Created for Nathalie Rochefort's lab                   %
%                       by Tom Mayo, Summer 2013                         %
%                  NeuroInformatics DTC @ Edinburgh                      %
%                                                                        %
%         (Using Matlab Version R2012a 64-bit on Mac OSX)                %
%                    please record and date edits here:                  %
%                                                                        %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function retinotopy4x3(numOrient, cyclesPerSecond, spatFreq, gabor, ...
    imageSize, stimStyle, timeIntro, timeStatic, timeDrift, biDirectional,...
    randomOrder, screenNumber, screenDist, gaussStDev, gaussTrim, screenWidth)

% THIS USES THE MAKESTIM2 FUNCTION, WITH DIFFERENT DEFAULT PARAMETERS, AND
% CREATES 12 SCREENS (4 ACROSS, 3 DOWN) TO SHOW THEM ON)



%----------LONG LIST OF DEFAULT PARAMETERS CODE, NON-ESSENTIAL ------------

if nargin < 16
    screenWidth = [];
end

if isempty(screenWidth)
    % By default we have a 34cm wide screen (used in calculating
    % frequencies)
	screenWidth=34;
end


if nargin < 14
    gaussStDev = [];
end

if isempty(gaussStDev)
    % By default standard deviation of the Gaussian (used in the Gabor) is 40 pixels
	gaussStDev=40;
end

if nargin < 13
    screenDist = [];
end

if isempty(screenDist)
    % By default the screen is 30cm away from the mouse
	screenDist=30;
end

if nargin < 12
    screenNumber = [];
end

if isempty(screenNumber)
    % By default we choose the maximum screen number
    screens=Screen('Screens');
	screenNumber=max(screens);
end

if nargin < 11
    randomOrder = [];
end

if isempty(randomOrder)
    % By default we permute the orientation display order
    randomOrder = 1;
end

if nargin < 10
    biDirectional = [];
end

if isempty(biDirectional)
    % By default we move in both directions (biDirectional = 1)
    biDirectional = 1;
end


if nargin < 9
    timeDrift = [];
end

if isempty(timeDrift)
    % By default the drifing time 1 second
    timeDrift = 1;
end

if nargin < 8
    timeStatic = [];
end

if isempty(timeStatic)
    % By default the static time before movement is 0.5 seconds
    timeStatic = 0;
end

if nargin < 7
    timeIntro = [];
end

if isempty(timeIntro)
    % By default the intro time is 0.5 seconds
    timeIntro = 0.5;
end 

if nargin < 6
    stimStyle = [];
end

if isempty(stimStyle)
    % By default the stim is Black and White = 0, rather than Sinusiodal, 1:
    stimStyle = 0;
end

if nargin < 5
    imageSize = [];
end

if isempty(imageSize)
    % By default the visible grating is 400 pixels by 400 pixels in size:
    imageSize = 800;
end

if nargin < 4
    gabor = [];
end

if isempty(gabor)
    % By default, we don't mask the grating (uses gaussian transparency
    % mask)
    gabor=0;
end;

if nargin < 3
    spatFreq = [];
end

if isempty(spatFreq)
    % Spatial Frequency in cycles per degree, default 0.05
    spatFreq=0.05;
end;

if nargin < 2
    cyclesPerSecond = [];
end

if isempty(cyclesPerSecond)
    % Speed of grating in cycles per second: 1 cycle per second by default.
    cyclesPerSecond=1;
end;

if nargin < 1
    numOrient = [];
end

if isempty(numOrient)
    % number of orientations to cycle: default is 8.
    numOrient=8;
end;


% some parameters to define:

% Define Half-Size of the grating image.
texsize=imageSize / 2;

% current path, to save the data
currentPath = '/Users/Tom/Desktop/Testing Visual Stim/'; % set path to save files


%-------------------------- END OF SECTION -------------------------------

%---------------------- CREATE ORIENTATION ORDER -------------------------


% calculate the orientations
incOrient = 360/numOrient;
orientList = [0:numOrient-1]*incOrient;

% if there is random order selected, permute the order
if randomOrder == 1
    newOrder = randperm(numOrient);
    newList = [];
    for i = [1:numOrient]
        newList(i) = orientList(newOrder(i));
    end
    orientList = newList;
end

%-------------------------- END OF SECTION -------------------------------

%------------------ CALCULATE THE SPATIAL FREQUENCY IN PIXELS--------------

% if the mouse is looking forward, the angle from the centre of the screen
% to the edge is:

theta = atand(screenWidth*0.5/screenDist);     % we want this is degs
totalCycles = spatFreq*2*theta;                % total cycles on the screen
cyclesPerPixel = totalCycles/imageSize;        % cycles per pixel

orientList

% if this is confusing, it helps to draw the diagram

%-------------------------- END OF SECTION -------------------------------

% the next bits use Psychtoolbox code, so to avoid errors freezing the screen,
% we use a try-catch set up

%-----------OPEN A WINDOW AND DEFINE STIMULI------------------

try
    % This script calls Psychtoolbox commands available only in OpenGL-based 
	% versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
	% only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
	% an error message if someone tries to execute this script on a computer without
	% an OpenGL Psychtoolbox
	AssertOpenGL;
    
    % Define white, black, gray and the increment value in the standard way
    white=WhiteIndex(screenNumber);
	black=BlackIndex(screenNumber);
	gray=round((white+black)/2);        % round it to avoid fraction errors
    
    % this is a recommended safety trick, makes sure we get a well defined
    % gray on floating point buffers
    if gray == white
		gray=white / 2;
    end
    inc=white-gray;
    
    
    % open a window
    [w screenRect]=Screen('OpenWindow',screenNumber, gray);
    
    % CREATE THE SCREENS FOR THE RETINOTOPY-------------------------------
    width = floor(screenRect(3)/4);
    height = floor(screenRect(4)/3);
    % since we can't have a list of matrices, make a list of co-orindates,
    % in the order they appear in screenRect
    destRectList = zeros(1,4*12);
    for row = [1:3]
        for col = [1:4]
            currentRect = (row-1)*4 + col - 1; % goes from 0 to 11 for ease
            % define top left corner, then bottom right
            destRectList(currentRect*4 + 1) = (col-1)*width;
            destRectList(currentRect*4 + 2) = (row-1)*height;
            destRectList(currentRect*4 + 3) = (col)*width;
            destRectList(currentRect*4 + 4) = (row)*height;
        end
    end
    
    % --------------------------------------------------------------------

            
    
    
    
    if gabor == 1
        % ""Enable alpha blending for proper combination of the gaussian aperture
        % with the drifting sine grating:"" - this means we just draw the
        % pictures on top of each other, matlab does the rest
        Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end
    

    % need to compute pixels per cycle, rounded up to full pixels
    p = ceil(1/cyclesPerPixel);
    
    % frequency (per pixel) in radians
    fr = cyclesPerPixel*2*pi;
    
    % This is the visible size of the grating. It is twice the half-width
    % of the texture plus one pixel to make sure it has an odd number of
    % pixels and is therefore symmetric around the center of the texture:
    visiblesize=2*texsize+1;
    
    gratingtexList = zeros(1,numOrient);
    % Create one single static grating image, per orientation:
    for i = [1:numOrient]
        orient = orientList(i);
    % Here we differ from the Demo(2), we need to create the whole 2-D
    % image
    %
    % We only need a texture with a single row of pixels(i.e. 1 pixel in height) to
    % define the whole grating! If the 'srcRect' in the 'Drawtexture' call
    % below is "higher" than that (i.e. visibleSize >> 1), the GPU will
    % automatically replicate pixel rows. This 1 pixel height saves memory
    % and memory bandwith, ie. it is potentially faster on some GPUs.
    %
    % However it does need 2 * texsize + p columns, i.e. the visible size
    % of the grating extended by the length of 1 period (repetition) of the
    % sine-wave in pixels 'p':
        [x,y] = meshgrid(-texsize - p:texsize + 2*p, -texsize - p:texsize + 2*p);

        % Compute actual cosine grating and rotate it by appropriate angle in radians
        orientRad = orient*2*pi/360;
        canvas = x * cos(orientRad) + y * sin(orientRad);
        if stimStyle == 0 % Black and White
            grating = white*round(0.5 + 0.5*cos(fr*canvas));

        else % sinusoidal
            grating = gray + inc*cos(fr*canvas);
        end
        % Store the 2-D grating in texture:
        gratingtexList(i)=Screen('MakeTexture', w, grating);
    end

     % Create a single gaussian transparency mask and store it to a texture:
    % The mask must have the same size as the visible size of the grating
    % to fully cover it. 
    %
    % We create a  two-layer texture: One unused luminance channel which we
    % just fill with the same color as the background color of the screen
    % 'gray'. The transparency (aka alpha) channel is filled with a
    % gaussian (exp()) aperture mask:
    mask=ones(2*texsize+1, 2*texsize+1, 2) * gray;
    [x,y]=meshgrid(-1*texsize:1*texsize,-1*texsize:1*texsize);
    mask(:, :, 2)=white * (1 - exp(-((x/90).^2)-((y/90).^2)));
    masktex=Screen('MakeTexture', w, mask);

    % Query maximum useable priorityLevel on this system:
	priorityLevel=MaxPriority(w); %#ok<NASGU>

    % We don't use Priority() in order to not accidentally overload older
    % machines that can't handle a redraw every 40 ms. If your machine is
    % fast enough, uncomment this to get more accurate timing.
    % Priority(priorityLevel);
    
    
    % We don't use Priority() in order to not accidentally overload older
    % machines that can't handle a redraw every 40 ms. If your machine is
    % fast enough, uncomment this to get more accurate timing.
    %Priority(priorityLevel);
    
    % Definition of the drawn rectangle on the screen
    % Compute it to  be the visible size of the grating, centered on the
    % screen:
    dstRect=[0 0 visiblesize visiblesize];
    dstRect=screenRect;

    % Query duration of one monitor refresh interval:
    ifi=Screen('GetFlipInterval', w);
    
    % Translate that into the amount of seconds to wait between screen
    % redraws/updates:
    
    % waitframes = 1 means: Redraw every monitor refresh. If your GPU is
    % not fast enough to do this, you can increment this to only redraw
    % every n'th refresh. All animation paramters will adapt to still
    % provide the proper grating. However, if you have a fine grating
    % drifting at a high speed, the refresh rate must exceed that
    % "effective" grating speed to avoid aliasing artifacts in time, i.e.,
    % to make sure to satisfy the constraints of the sampling theorem
    % (See Wikipedia: "Nyquist?Shannon sampling theorem" for a starter, if
    % you don't know what this means):
    waitframes = 1;
    
    % Translate frames into seconds for screen update interval:
    waitduration = waitframes * ifi;
    
    % Recompute p, this time without the ceil() operation from above.
    % Otherwise we will get wrong drift speed due to rounding errors!
    p=1/cyclesPerPixel;  % pixels/cycle    

    % Translate requested speed of the grating (in cycles per second) into
    % a shift value in "pixels per frame", for given waitduration: This is
    % the amount of pixels to shift our srcRect "aperture" in horizontal
    % directionat each redraw:
    shiftperframe= cyclesPerSecond * p * waitduration;
    
    % here we loop through the dest rects -------------------------------
    for numRect = [1:12]
        dstRect = [destRectList((numRect-1)*4 + 1) destRectList((numRect-1)*4 + 2)...
            destRectList((numRect-1)*4 + 3) destRectList((numRect-1)*4 + 4)];
    
    %--------------------------------------------------------------------


        % Perform initial Flip to sync us to the VBL and for getting an initial
        % VBL-Timestamp as timing baseline for our redraw loop:
        vbl=Screen('Flip', w);

        % We run at most 'timeStatic + timeDrift' seconds if user doesn't abort via keypress.
        vblendtime = vbl + timeStatic + timeDrift;
        vblStaticTime = vbl + timeStatic;
        j=0;

        % trick for keeping it smooth when using bidirectional stimuli
        count=0;

        % record times and order of presentation of stimuli (for a .txt file)
        timeSeq = [];
        eventSeqDummy = {};
        tic;
        % Animationloop:
        for i = [1:numOrient]
            timeSeq(length(timeSeq)+1) = toc;

            angle = orientList(i);
            angleRad = angle*2*pi/360;      % angle in radians
            vbl=Screen('Flip', w);
            vblendtime = vbl + timeStatic + timeDrift;
            vblhalftime = vbl + timeStatic + timeDrift/2;
            vblStaticTime = vbl + timeStatic;

            timerDrift = 0;

                % trick for keeping it smooth when rolling the other way
            count=0;




            while(vbl < vblendtime)

            % Shift the grating by "shiftperframe" pixels per frame:
            % the mod'ulo operation makes sure that our "aperture" will snap
            % back to the beginning of the grating, once the border is reached.
            % Fractional values of 'xoffset' are fine here. The GPU will
            % perform proper interpolation of color values in the grating
            % texture image to draw a grating that corresponds as closely as
            % technical possible to that fractional 'xoffset'. GPU's use
            % bilinear interpolation whose accuracy depends on the GPU at hand.
            % Consumer ATI hardware usually resolves 1/64 of a pixel, whereas
            % consumer NVidia hardware usually resolves 1/256 of a pixel. You
            % can run the script "DriftTexturePrecisionTest" to test your
            % hardware...
                if vbl >= vblStaticTime
                    if timerDrift == 0
                        timeSeq(length(timeSeq)+1) = toc;
                        timerDrift = 1;
                        j=0;
                    end
                    if biDirectional == 1                

                        if vbl < vblhalftime
                            if angle ~= 90 & angle ~= 270
                                xOffset = mod(j*shiftperframe/cos(angleRad),p/abs(cos(angleRad)));
                                yOffset = 0;
                            else
                                yOffset = mod(j*shiftperframe,p);
                                xOffset = 0;
                            end
                        else
                            if count == 0                            
                                k = j;
                                j=0;
                                count = 1;
                                timeSeq(length(timeSeq)+1) = toc; %record time                             
                            end
                            if angle ~= 90 & angle ~= 270                    
                                xOffset = mod((k-j)*shiftperframe/cos(angleRad),abs(p/cos(angleRad)));
                                yOffset = 0;
                            else
                                yOffset = mod((k-j)*shiftperframe,p);
                                xOffset = 0;
                            end

                        end
                        j=j+1;
                    else
                        if vbl < vblendtime
                            if angle ~= 90 & angle ~= 270
                                xOffset = mod(j*shiftperframe/cos(angleRad),p/abs(cos(angleRad)));
                                yOffset = 0;
                            else
                                yOffset = mod(j*shiftperframe,p);
                                xOffset = 0;
                            end
                        end
                        j = j+1;
                    end
                end


            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture: We cut out the range 0 to visiblesize in
            % the vertical direction although the texture is only 1 pixel in
            % height! This works because the hardware will automatically
            % replicate pixels in one dimension if we exceed the real borders
            % of the stored texture. This allows us to save storage space here,
            % as our 2-D grating is essentially only defined in 1-D:
                if vbl < vblStaticTime
                    srcRect=[0 0 visiblesize visiblesize];
                else               
                    srcRect=[xOffset yOffset xOffset + visiblesize yOffset + visiblesize];
                end
            % Draw grating texture:
                Screen('DrawTexture', w, gratingtexList(i), srcRect, dstRect);

                if gabor==1
                % Draw gaussian mask over grating:
                    Screen('DrawTexture', w, masktex, [0 0 visiblesize visiblesize], dstRect);
                end;

            % Flip 'waitframes' monitor refresh intervals after last redraw.
            % Providing this 'when' timestamp allows for optimal timing
            % precision in stimulus onset, a stable animation framerate and at
            % the same time allows the built-in "skipped frames" detector to
            % work optimally and report skipped frames due to hardware
            % overload:
                vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);

        % Abort demo if any key is pressed:
            if KbCheck
                break;
            end;
            end
        end
        timeSeq(length(timeSeq)+1) = toc;

    end

    % Restore normal priority scheduling in case something else was set
    % before:
    Priority(0);
	
	%The same commands wich close onscreen and offscreen windows also close
	%textures.
	Screen('CloseAll');


catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Priority(0);
    psychrethrow(psychlasterror);
end %try..catch..

%-------------------------- END OF SECTION -------------------------------



% --------------------SAVE THE ORDER AND TIME OF EVENTS------------------


% add the order of orientations, with & without drifts to the eventSeq list

% if biDirectional == 0    
%     orientEventList = cell(1,2*numOrient+1);
%     for i =[1:numOrient]
%         orientEventList{2*i-1} = strcat(num2str(orientList(i)),'-Static');
%         orientEventList{2*i} = strcat(num2str(orientList(i)),'-Drift');
%     end
%     orientEventList{2*numOrient+1} = 'End';
% else
%     orientEventList = cell(1,3*numOrient+1);
%     for i =[1:numOrient]
%         orientEventList{3*i-2} = strcat(num2str(orientList(i)),'-Static');
%         orientEventList{3*i-1} = strcat(num2str(orientList(i)),'-Drift');
%         orientEventList{3*i} = strcat(num2str(orientList(i)),'-Reverse');
%     end
%     
%     orientEventList{3*numOrient+1} = 'End';
% end
% 
% % combine order or orientations with other events
% total = length(eventSeqDummy)+length(orientEventList);
% eventSeq = cell(1,total);
% for i = [1:total]
%     if i <= length(eventSeqDummy)
%         eventSeq{i} = eventSeqDummy{i};
%     else
%         eventSeq{i} = orientEventList{i-length(eventSeqDummy)};
%     end
% end
% 
% % write eventSeq and timeSeq to a .txt file
% % this has the form 'eventSeq', new line, a line with all the events in
% % order, then new line, 'timeSeq', and a line with all times in order
% file_name = cat(2,currentPath,'visual_stim_prtcl.txt');
% fid = fopen (file_name,'w');
% C = eventSeq.';
% fprintf(fid,'%s\n','eventSeq');
% fprintf(fid, '"%s"\t', C{:});
% fprintf(fid,'\n%s\n','timeSeq');
% fprintf(fid,'%3.4f\t',timeSeq);
% fclose(fid);
% 

% We're done!
return;