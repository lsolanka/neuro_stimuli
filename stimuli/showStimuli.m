%
% Set up screens for drawing stimuli, draw them, and save the parameter setup
% and stimuli timing details into the output file.
%
% Created for Nathalie Rochefort's lab by Tom Mayo, Summer 2013,
% NeuroInformatics DTC @ Edinburgh
%
% Edited and improved by
%   Lukas Solanka <lukas.solanka@ed.ac.uk>
%   Paolo Puggioni <p.puggioni@sms.ed.ac.uk>
%
function showStimuli(par)
    import stimuli.CustomStimulus;
    
    c=clock;
    stimulusDrawers = par.stimulusDrawers
    screenWidth     = par.screenWidth  
    nCols           = par.nCols
    nRows           = par.nRows

    
    try
        % --------------------------------------------------------------------
        %         This code has to be before the trigger waiting loop
        % --------------------------------------------------------------------
        AssertOpenGL;
        dummy=GetSecs;
        Screen('Preference', 'VisualDebugLevel', 1); % to avoid the white welcome screen
        [white, black, grey] = CustomStimulus.getColors(par.screenNumber);
        [w screenRect] = Screen('OpenWindow', par.screenNumber, grey); %, [0, 0, 400, 400]);

        % Create individual rectangles, depending on the nRows and nCols
        % parameters
        screenWidth  = screenRect(3) - screenRect(1)
        screenHeight = screenRect(4) - screenRect(2)

        if par.splitScreen
            screenWidth = screenWidth / 2
        end

        par.imageSizeX = screenWidth;
        par.imageSizeY = screenHeight;
        
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

        % Initialise the drawers. This should be before the actual drawing
        % begins.
        par.w = w;
        for drawer = stimulusDrawers
            drawer.setDrawingParameters(par);
        end
        % --------------------------------------------------------------------


        % --------------------------------------------------------------------
        % Trigger waiting loop
        if par.waitForTrigger
            s = daq.createSession('ni');
            s.addDigitalChannel('Dev1', 'Port1/Line0:7', 'InputOnly');
            
            a=0;
            
            while a<1 
              %pause(0.0005);
              testt=s.inputSingleScan;
              a=testt(end);
              
            end
        end

        par.Trigger_time=GetSecs;
        % --------------------------------------------------------------------
    

        % --------------------------------------------------------------------
        %                               DRAW
        Seq_time = {};
        ii=0;
        
        for numRect = [1:nRows*nCols]
            dstRect = destRectList(numRect, :);

            % Animationloop:
            for drawer = stimulusDrawers
                ii=ii+1;
                Seq_time{ii}=drawer.draw(dstRect);
            end
        end
        % --------------------------------------------------------------------

        par.End_time=GetSecs;
    catch
        Screen('CloseAll');
        Priority(0);
        psychrethrow(psychlasterror);
    end

    Priority(0);
    Screen('CloseAll');





    % --------------------SAVE THE ORDER AND TIME OF EVENTS------------------
  
    
    formatOut='yymmdd_HHMMSS';
    
    name1=datestr(c,formatOut);
    namefolder=datestr(c,'yymmdd/');
    
    mkdir(par.currentPath,namefolder);
    
    currentPath=cat(2,par.currentPath,namefolder);
    
    file_name = cat(2,currentPath,name1,par.fileSuffix,'.txt');
    file_name_mat=cat(2,currentPath,name1,par.fileSuffix,'.mat');
    fid = fopen (file_name,'w');
 
    
    fprintf(fid,'PARAMETERS:\n');
    if par.numOrient==1  % THESE ARE THE CHRONIC STIMULI
        if par.chronicReversal==0 %grating
            fprintf(fid,'Chronic stimulus\n');   
            printGratingTiming(fid, par)
            fprintf(fid,'Chronic panel, orientation (deg): %.0f\n', ...
                    par.chronicOrient);
        elseif par.chronicReversal==1
            %Seq_time=Seq_time{1}; %phase rev
            fprintf(fid,'Chronic stimulus - Phase Reversal\n');   
            printReversalGratingTiming(fid, par)
            fprintf(fid,'Chronic panel, orientation (deg): %.0f\n',par.chronicOrient);
        end
        
    elseif nRows>1 % THIS IS THE RETINOTROPY
        if par.movingReversal == 0 %grating
            fprintf(fid,'Retinotopy, row x col: %d x %d\n',nRows,nCols);
            printGratingTiming(fid, par)
            printGratingParams(fid, par)
        elseif par.movingReversal == 1 %phase rev
            fprintf(fid,'Retinotopy, row x col: %d x %d - Phase Reversal\n',nRows,nCols);
            printReversalGratingTiming(fid, par)
            printGratingParams(fid, par)
        end   
            
    elseif isfield(par,'Custom_seq') % THIS IS THE CUSTOM SEQUENCY
            if par.Custom_seq==1
               fprintf(fid,'Custom Sequence: %s \n',par.customSeq); 
            end
            printGratingTiming(fid, par)
            printGratingParams(fid, par)
            
            
    else % THIS IS THE ORIENTATION LIST
        if par.movingReversal == 0 %grating
            fprintf(fid,'Moving gratings \n');         
            printGratingTiming(fid, par)
            printGratingParams(fid, par)
        elseif par.movingReversal == 1 %phase reversal
            fprintf(fid,'Phase reversal \n');         
            printReversalGratingTiming(fid, par)
            printGratingParams(fid, par)
        end
    end
    
    fprintf(fid,'\nTime(s)\tOrient.(deg)\tType\n');
     time_vec=[];
     angle_vec=[];
     type_vec={};
     ll=0;
     kk=0;
     while kk<length(Seq_time)
        kk=kk+1;
        
        if isprop(Seq_time{kk},'startTime') % THIS IS FOR UNIFORM GRAY BLACK SCREEN
            time_static=Seq_time{kk}.startTime - par.Trigger_time; 
            fprintf(fid,'%3.4f\t%3.1f\t%s\n',time_static,0,'Uniform');  
            time_vec=[time_vec; time_static];
            type_vec=[type_vec; 'U'];
            angle_vec=[angle_vec;0];
 
        else % THIS IS FOR THE REST
            time_static=Seq_time{kk}.staticStartT - par.Trigger_time;
            fprintf(fid,'%3.4f\t%3.1f\t%s\n',time_static,Seq_time{kk}.angle-90,'Static');
            time_vec=[time_vec; time_static];
            type_vec=[type_vec; 'S'];
            angle_vec=[angle_vec;Seq_time{kk}.angle-90];
        
            time_forward=Seq_time{kk}.forwardStartT - par.Trigger_time;
            fprintf(fid,'%3.4f\t%3.1f\t%s\n',time_forward,Seq_time{kk}.angle-90,'Forward');
            time_vec=[time_vec; time_forward];
            type_vec=[type_vec; 'F'];
            angle_vec=[angle_vec;Seq_time{kk}.angle-90];
        
        
            if Seq_time{kk}.bidirectional==1
                time_backward=Seq_time{kk}.backwardStartT - par.Trigger_time;
                fprintf(fid,'%3.4f\t%3.1f\t%s\n',time_backward,Seq_time{kk}.angle-90,'Backward');
                time_vec=[time_vec; time_backward];
                type_vec=[type_vec; 'B'];
                angle_vec=[angle_vec;Seq_time{kk}.angle-90];
            end
        end
     end
     
     fprintf(fid,'%3.4f\tEnd\n',par.End_time-par.Trigger_time);
     
     data_all.time=time_vec;
     data_all.type=type_vec;
     data_all.angle=angle_vec;
     
     save(file_name_mat,'par','data_all')
     
    fclose(fid);
     

function printGratingTiming(fid, par)
    fprintf(fid, ['Drift time (s): %.1f, ', ...
                  'Static time(s): %.1f, ', ...
                  'Spatial Frequency (cyc/deg):%.2f, ', ...
                  'Temporal Frequency (cyc/s): %.1f\n'], ...
                  par.timeDrift, ...
                  par.timeStatic, ...
                  par.spatFreq, ...
                  par.cyclesPerSecond);

function printReversalGratingTiming(fid, par)
    fprintf(fid, ['Drift time (s): %.1f, ', ...
                  'Static time(s): %.1f, ', ...
                  'Spatial Frequency (cyc/deg):%.2f, ', ...
                  'Reversal Frequency (cyc/s): %.1f\n'], ...
                  par.timeDrift, ...
                  par.timeStatic, ...
                  par.spatFreq, ...
                  par.chronicReversalFreq);

function printGratingParams(fid, par)
    fprintf(fid, ...
            ['N orient.: %d, ', ...
             'Random (1=YES,0=NO): %d, ', ...
             'Bidirectional (1=YES,0=NO): %d, ', ...
             'Stim. Style (1=sin,0=BW): %d, ', ...
             'Gabor (1=YES,0=NO): %d\n'], ...
            par.numOrient, ...
            par.randomOrder, ...
            par.biDirectional, ...
            par.stimStyle, ...
            par.gabor);
