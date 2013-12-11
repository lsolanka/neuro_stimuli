%
% Created for Nathalie Rochefort's lab by Tom Mayo, Summer 2013,
% NeuroInformatics DTC @ Edinburgh
%
% Edited and improved by
%   Lukas Solanka <lukas.solanka@ed.ac.uk>
%   Paolo Puggioni <p.puggioni@sms.ed.ac.uk>
%

function showStimuli(par)
    
    c=clock;

    numOrient       = par.numOrient
    chronicOrient   = par.chronicOrient
    cyclesPerSecond = par.cyclesPerSecond
    spatFreq        = par.spatFreq     
    gabor           = par.gabor        
    imageSize       = par.imageSize    
    stimStyle       = par.stimStyle    
    timeIntro       = par.timeIntro    
    timeStatic      = par.timeStatic   
    timeDrift       = par.timeDrift    
    biDirectional   = par.biDirectional
    randomOrder     = par.randomOrder  
    screenNumber    = par.screenNumber 
    screenDist      = par.screenDist   
    gaussStDev      = par.gaussStDev   
    gaussTrim       = par.gaussTrim    
    screenWidth     = par.screenWidth  
    currentPath     = par.currentPath
    fileSuffix      = par.fileSuffix
    nCols           = par.nCols
    nRows           = par.nRows

    

    % Define Half-Size of the grating image.
    texsize = imageSize / 2;


    %---------------------- CREATE ORIENTATION ORDER -------------------------
    incOrient = 360/numOrient;
    orientList = 90+[0:numOrient-1]*incOrient+chronicOrient; %offset 90 deg to have zero up

    
    
    % if there is random order selected, permute the order
    if randomOrder == 1
        newOrder = randperm(numOrient);
        newList = [];
        for i = [1:numOrient]
            newList(i) = orientList(newOrder(i));
        end
        orientList = newList;
    end
    
    orientList_print=orientList-90; %to print correct values in the file

    %------------------ CALCULATE THE SPATIAL FREQUENCY IN PIXELS--------------
    % if the mouse is looking forward, the angle from the centre of the screen
    % to the edge is:
    theta = atand(screenWidth*0.5/screenDist);     % we want this is degs
    totalCycles = spatFreq*2*theta;                % total cycles on the screen
    cyclesPerPixel = totalCycles/imageSize;        % cycles per pixel

    try
        AssertOpenGL;
        
        white=WhiteIndex(screenNumber);
        black=BlackIndex(screenNumber);
        gray=round((white+black)/2);        % round it to avoid fraction errors
        
        if gray == white
            gray=white / 2;
        end
        
        Screen('Preference', 'VisualDebugLevel', 1); % to avoid the white welcome screen
        [w screenRect] = Screen('OpenWindow', screenNumber, gray);

        
        % ADD THE TRIGGER HERE - Paolo. (Comment this if it runs on our
        % laptops!
        
%         s = daq.createSession('ni');
%         s.addDigitalChannel('Dev1', 'Port1/Line0:7', 'InputOnly');
%         while (s.inputSingleScan < 1) 
%           pause(0.001);
%         end
        
        % Create individual rectangles for the retinotopy
        screenWidth  = screenRect(3) - screenRect(1)
        screenHeight = screenRect(4) - screenRect(2)
        width        = floor(screenWidth / nCols);
        height       = floor(screenHeight / nRows);

        destRectList = zeros(nRows * nCols, 4);
        it = 1;
        for row = [1:nRows]
            for col = [1:nCols]
                destRectList(it, 1) = (col-1) * width;
                destRectList(it, 2) = (row-1) * height;
                destRectList(it, 3) = (col) * width;
                destRectList(it, 4) = (row) * height;
                it = it + 1;
            end
        end
        
        
        % Alpha blending for a Gabor patch
        if gabor == 1
            Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        end
        

        % This is the visible size of the grating. It is twice the half-width
        % of the texture plus one pixel to make sure it has an odd number of
        % pixels and is therefore symmetric around the center of the texture:
        visiblesize=2*texsize+1;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Create one single static grating image, per orientation:
        p = ceil(1/cyclesPerPixel); % pixels per cycle, rounded up to full pixels
        fr = cyclesPerPixel*2*pi; % frequency (per pixel) in radians
        
        
        gratingtexList = zeros(1,numOrient);
        inc = white - gray;
        for i = [1:numOrient]
            orient = orientList(i);

            [x,y] = meshgrid(-texsize - p:texsize + 2*p, -texsize - p:texsize + 2*p);

            % Compute actual cosine grating and rotate it by appropriate angle
            % in radians
            orientRad = orient *2*pi/360;
            canvas = x * cos(orientRad) + y * sin(orientRad);

            if stimStyle == 0
                % Black and White
                grating = white*round(0.5 + 0.5*cos(fr*canvas));
            else
                % sinusoidal
                grating = gray + inc*cos(fr*canvas);
            end

            gratingtexList(i) = Screen('MakeTexture', w, grating);
        end


        % Create a single gaussian transparency mask and store it to a texture:
        % The mask must have the same size as the visible size of the grating
        % to fully cover it. 
        %
        % We create a  two-layer texture: One unused luminance channel which we
        % just fill with the same color as the background color of the screen
        % 'gray'. The transparency (aka alpha) channel is filled with a
        % gaussian (exp()) aperture mask:
        mask          = ones(2*texsize+1, 2*texsize+1, 2) * gray;
        [x , y]       = meshgrid(-1*texsize:1*texsize, -1*texsize:1*texsize);
        mask(:, :, 2) = white * (1 - exp(-((x/90).^2)-((y/90).^2)));
        masktex       = Screen('MakeTexture', w, mask);

        % Query maximum useable priorityLevel on this system:
        priorityLevel=MaxPriority(w); %#ok<NASGU>
        %Priority(priorityLevel);
        
        % Query duration of one monitor refresh interval:
        % Translate that into the amount of seconds to wait between screen
        % redraws/updates:
        ifi          = Screen('GetFlipInterval', w);
        waitframes   = 1;
        waitduration = waitframes * ifi;
        


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %                         Actual drawing

        % Recompute p, this time without the ceil() operation from above.
        % Otherwise we will get wrong drift speed due to rounding errors!
        p=1/cyclesPerPixel;  % pixels/cycle    

        % Translate requested speed of the grating (in cycles per second) into
        % a shift value in "pixels per frame", for given waitduration: This is
        % the amount of pixels to shift our srcRect "aperture" in horizontal
        % directionat each redraw:
        shiftperframe= cyclesPerSecond * p * waitduration;
        
        for numRect = [1:nRows*nCols]
            stop = false;
            %if stop
            %    break;
            %end

            dstRect = destRectList(numRect, :);

            % Initial Flip to sync us to the VBL
            vbl = Screen('Flip', w);

            % We run at most 'timeStatic + timeDrift' seconds if user doesn't abort via keypress.
            vblendtime = vbl + timeStatic + timeDrift;
            vblStaticTime = vbl + timeStatic;

            % record times and order of presentation of stimuli (for a .txt file)
            timeSeq = [];
            eventSeqDummy = {};
            tic;

            % Animationloop:
            for i = [1:numOrient]
                if stop
                    break;
                end

                timeSeq(length(timeSeq)+1) = toc;

                angle    = orientList(i);
                angleRad = angle*2*pi/360;      % angle in radians

                vbl           = Screen('Flip', w);
                vblendtime    = vbl + timeStatic + timeDrift;
                vblhalftime   = vbl + timeStatic + timeDrift/2;
                vblStaticTime = vbl + timeStatic;

                timerDrift = 0;

                % trick for keeping it smooth when rolling the other way
                count=0;

                j = 0;
                while(vbl < vblendtime)
                    % Shift the grating by "shiftperframe" pixels per frame:
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


                    if vbl < vblStaticTime
                        srcRect = [0 0 visiblesize visiblesize];
                    else               
                        srcRect = [xOffset yOffset xOffset + visiblesize yOffset + visiblesize];
                    end

                    Screen('DrawTexture', w, gratingtexList(i), srcRect, dstRect);

                    if gabor==1
                        % Draw gaussian mask over grating:
                        Screen('DrawTexture', w, masktex, [0 0 visiblesize visiblesize], dstRect);
                    end;

                    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);

                    % Abort demo if any key is pressed:
                    if KbCheck
                        stop = true;
                        break;
                    end
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
        Screen('CloseAll');
        Priority(0);
        psychrethrow(psychlasterror);
    end

    %-------------------------- END OF SECTION -------------------------------



    % --------------------SAVE THE ORDER AND TIME OF EVENTS------------------


    % add the order of orientations, with & without drifts to the eventSeq list

     if biDirectional == 0    
         orientEventList = cell(1,2*numOrient+1);
         for i =[1:numOrient]
             orientEventList{2*i-1} = strcat(num2str(orientList_print(i)),' -Static');
             orientEventList{2*i} = strcat(num2str(orientList_print(i)),' -Drift');
         end
         orientEventList{2*numOrient+1} = 'End';
     else
         orientEventList = cell(1,3*numOrient+1);
         for i =[1:numOrient]
             orientEventList{3*i-2} = strcat(num2str(orientList_print(i)),'\tStatic');
             orientEventList{3*i-1} = strcat(num2str(orientList_print(i)),'\tDrift');
             orientEventList{3*i} = strcat(num2str(orientList_print(i)),'\tReverse');
         end
         
         orientEventList{3*numOrient+1} = 'End';
     end
     
     % combine order or orientations with other events
     total = length(eventSeqDummy)+length(orientEventList);
     eventSeq = cell(1,total);
     for i = [1:total]
         if i <= length(eventSeqDummy)
             eventSeq{i} = eventSeqDummy{i};
         else
             eventSeq{i} = orientEventList{i-length(eventSeqDummy)};
         end
     end
     
     % write eventSeq and timeSeq to a .txt file
     % this has the form 'eventSeq', new line, a line with all the events in
     % order, then new line, 'timeSeq', and a line with all times in order
     
     formatOut='yymmdd_HHMMSS';
     
     name1=datestr(c,formatOut);
     namefolder=datestr(c,'yymmdd/');
     
     mkdir(currentPath,namefolder);
     
     currentPath=cat(2,currentPath,namefolder);
     
     file_name = cat(2,currentPath,name1,fileSuffix,'.txt');
     fid = fopen (file_name,'w');
     
     fprintf(fid,'Time(s)\tOrient.(deg)-Type\n');
     
     kk=0;
     while kk<length(timeSeq)
        kk=kk+1;
        fprintf(fid,'%3.4f\t%s\n',timeSeq(kk),eventSeq{kk});
     end
     

     fclose(fid);
     

    % We're done!
    return;
