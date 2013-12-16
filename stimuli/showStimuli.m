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

    %chronicOrient   = par.chronicOrient
    %cyclesPerSecond = par.cyclesPerSecond
    %spatFreq        = par.spatFreq     
    %gabor           = par.gabor        
    %imageSize       = par.imageSize    
    %stimStyle       = par.stimStyle    
    %timeIntro       = par.timeIntro    
    %timeStatic      = par.timeStatic   
    %timeDrift       = par.timeDrift    
    %biDirectional   = par.biDirectional
    %randomOrder     = par.randomOrder  
    %screenNumber    = par.screenNumber 
    %screenDist      = par.screenDist   
    %gaussStDev      = par.gaussStDev   
    %gaussTrim       = par.gaussTrim    
    screenWidth     = par.screenWidth  
    %currentPath     = par.currentPath
    %fileSuffix      = par.fileSuffix
    nCols           = par.nCols
    nRows           = par.nRows

    
    %orientList_print=orientList-90; %to print correct values in the file

    try
        AssertOpenGL;
        dummy=GetSecs;
        Screen('Preference', 'VisualDebugLevel', 1); % to avoid the white welcome screen
        [white, black, grey] = CustomStimulus.getColors(par.screenNumber);
        [w screenRect] = Screen('OpenWindow', par.screenNumber, grey); %, [0, 0, 400, 400]);
        
        % ADD THE TRIGGER HERE - Paolo. (Comment this if it runs on our
        % laptops!
        
%          s = daq.createSession('ni');
%          s.addDigitalChannel('Dev1', 'Port1/Line0:7', 'InputOnly');
%          
%          a=0;
%          
%          while a<1 
%            %pause(0.0005);
%            testt=s.inputSingleScan;
%            a=testt(end);
%            
%          end

        par.Trigger_time=GetSecs;
    
        par.w = w;
        
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
        
        for drawer = stimulusDrawers
            drawer.setDrawingParameters(par);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %                         Actual drawing

        Seq_time = {};
        eventSeqDummy = {};
        ii=0;
        
        tic;
        
        currentrect = 0;
        for numRect = [1:nRows*nCols]
            currentrect = currentrect+1;
            currentrow  = mod(currentrect,nCols) +1;
            currentcol  = currentrect-(currentrow-1)*nRows;
            
            dstRect = destRectList(numRect, :);

            % Animationloop:
            for drawer = stimulusDrawers
                ii=ii+1;
                Seq_time{ii}=drawer.draw(dstRect);
            end

        end
        par.End_time=GetSecs;
    catch
        Screen('CloseAll');
        Priority(0);
        psychrethrow(psychlasterror);
    end

    Priority(0);
    Screen('CloseAll');


    %-------------------------- END OF SECTION -------------------------------



    % --------------------SAVE THE ORDER AND TIME OF EVENTS------------------
  
    
    formatOut='yymmdd_HHMMSS';
    
    name1=datestr(c,formatOut);
    namefolder=datestr(c,'yymmdd/');
    
    mkdir(par.currentPath,namefolder);
    
    currentPath=cat(2,par.currentPath,namefolder);
    
    file_name = cat(2,currentPath,name1,par.fileSuffix,'.txt');
    fid = fopen (file_name,'w');
 
    
    fprintf(fid,'PARAMETERS:\n');
    if par.numOrient==1
       fprintf(fid,'Chronic stimulus\n');   
       fprintf(fid,'Drift time (s): %.1f, Static time(s): %.1f, Spatial Frequency (cyc/deg):%.2f, Temporal Frequency (cyc/s): %.1f\n',par.timeDrift,par.timeStatic,par.spatFreq,par.cyclesPerSecond);
       fprintf(fid,'Chronic panel, orientation (deg): %.0f\n',par.chronicOrient);
    else
        if nRows>1
            fprintf(fid,'Retinotopy, row x col: %d x %d\n',nRows,nCols);
        elseif isfield(par,'Custom_seq')
            if par.Custom_seq==1
               fprintf(fid,'Custom Sequence: %s \n',par.customSeq); 
            end
        else
           fprintf(fid,'Moving gratings \n'); 
        end
        fprintf(fid,'Drift time (s): %.1f, Static time(s): %.1f, Spatial Frequency (cyc/deg):%.2f, Temporal Frequency (cyc/s): %.1f\n',par.timeDrift,par.timeStatic,par.spatFreq,par.cyclesPerSecond);
        fprintf(fid,'N orient.: %d, Random (1=YES,0=NO): %d, Bidirectional (1=YES,0=NO): %d, Stim. Style (1=sin,0=BW): %d, Gabor (1=YES,0=NO): %d\n', par.numOrient, par.randomOrder,par.biDirectional,par.stimStyle,par.gabor);
    end
    
    fprintf(fid,'\nTime(s)\tOrient.(deg)-Type\n');
    
     kk=0;
     while kk<length(Seq_time)
        kk=kk+1;
        
        if isprop(Seq_time{kk},'startTime')
          time_static=Seq_time{kk}.startTime - par.Trigger_time; 
          fprintf(fid,'%3.4f\t%3.1f\t%s\n',time_static,0,'Uniform');  
            
        else
        time_static=Seq_time{kk}.staticStartT - par.Trigger_time;
        fprintf(fid,'%3.4f\t%3.1f\t%s\n',time_static,Seq_time{kk}.angle-90,'Static');
        time_forward=Seq_time{kk}.forwardStartT - par.Trigger_time;
        fprintf(fid,'%3.4f\t%3.1f\t%s\n',time_forward,Seq_time{kk}.angle-90,'Forward');
        
        if Seq_time{kk}.bidirectional==1
           time_backward=Seq_time{kk}.backwardStartT - par.Trigger_time;
           fprintf(fid,'%3.4f\t%3.1f\t%s\n',time_backward,Seq_time{kk}.angle-90,'Backward');
        end
        end
     end
     
     fprintf(fid,'%3.4f\tEnd\n',par.End_time-par.Trigger_time);
     
    fclose(fid);
     

