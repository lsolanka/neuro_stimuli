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
        
        % ADD THE TRIGGER HERE - Paolo. (Comment this if it runs on our
        % laptops!
        
%          s = daq.createSession('ni');
%          s.addDigitalChannel('Dev1', 'Port1/Line0:7', 'InputOnly');
%          
%          a=0;
%          
%          while a<1 
%            pause(0.0005);
%            testt=s.inputSingleScan;
%            a=testt(end);
%            
%          end

        Screen('Preference', 'VisualDebugLevel', 1); % to avoid the white welcome screen
        [white, black, grey] = CustomStimulus.getColors(par.screenNumber);
        [w screenRect] = Screen('OpenWindow', par.screenNumber, grey); %, [0, 0, 400, 400]);
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

        timeSeq = [];
        eventSeqDummy = {};
        tic;
        
        currentrect = 0;
        for numRect = [1:nRows*nCols]
            currentrect = currentrect+1;
            currentrow  = mod(currentrect,nCols) +1;
            currentcol  = currentrect-(currentrow-1)*nRows;
            
            dstRect = destRectList(numRect, :);

            % Animationloop:
            for drawer = stimulusDrawers
                drawer.draw(dstRect);
            end

        end

    catch
        Screen('CloseAll');
        Priority(0);
        psychrethrow(psychlasterror);
    end

    Priority(0);
    Screen('CloseAll');


    %-------------------------- END OF SECTION -------------------------------



    % --------------------SAVE THE ORDER AND TIME OF EVENTS------------------


    %% add the order of orientations, with & without drifts to the eventSeq list

    % if biDirectional == 0    
    %     orientEventList = cell(1,2*numOrient+1);
    %     for i =[1:numOrient]
    %         orientEventList{2*i-1} = strcat(num2str(orientList_print(i)),' -Static');
    %         orientEventList{2*i} = strcat(num2str(orientList_print(i)),' -Drift');
    %     end
    %     orientEventList{2*numOrient+1} = sprintf('End');
    % else
    %     orientEventList = cell(1,3*numOrient+1);
    %     for i =[1:numOrient]
    %         orientEventList{3*i-2} = strcat(num2str(orientList_print(i)),'\tStatic');
    %         orientEventList{3*i-1} = strcat(num2str(orientList_print(i)),'\tDrift');
    %         orientEventList{3*i} = strcat(num2str(orientList_print(i)),'\tReverse');
    %     end
    %     
    %     orientEventList{3*numOrient+1} = sprintf('End');
    % end
    % 
    % % combine order or orientations with other events
    % 
    % orientEventList=repmat(orientEventList,[1,numRect]);
    % 
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
    % 
    % formatOut='yymmdd_HHMMSS';
    % 
    % name1=datestr(c,formatOut);
    % namefolder=datestr(c,'yymmdd/');
    % 
    % mkdir(currentPath,namefolder);
    % 
    % currentPath=cat(2,currentPath,namefolder);
    % 
    % file_name = cat(2,currentPath,name1,fileSuffix,'.txt');
    % fid = fopen (file_name,'w');
    % 
    % fprintf(fid,'PARAMETERS:\n');
    % if numOrient==1
    %    fprintf(fid,'Chronic stimulus\n');   
    %    fprintf(fid,'Drift time (s): %.1f, Static time(s): %.1f, Spatial Frequency (cyc/deg):%.2f, Temporal Frequency (cyc/s): %.1f\n',timeDrift,timeStatic,spatFreq,cyclesPerSecond);
    %    fprintf(fid,'Chronic panel, orientation (deg): %.0f\n',chronicOrient);
    % else
    % if nRows>1
    %    fprintf(fid,'Retinotopy, row x col: %d x %d\n',nRows,nCols);       
    % end
    % fprintf(fid,'Drift time (s): %.1f, Static time(s): %.1f, Spatial Frequency (cyc/deg):%.2f, Temporal Frequency (cyc/s): %.1f\n',timeDrift,timeStatic,spatFreq,cyclesPerSecond);
    % fprintf(fid,'N orient.: %d, Random (1=YES,0=NO): %d, Bidirectional (1=YES,0=NO): %d, Stim. Style (1=sin,0=BW): %d, Gabor (1=YES,0=NO): %d\n', numOrient, randomOrder,biDirectional,stimStyle,gabor);
    % end
    % 
    % fprintf(fid,'\nTime(s)\tOrient.(deg)-Type\n');
    % 
    % kk=0;
    % while kk<length(timeSeq)
    %    kk=kk+1;
    %    fprintf(fid,'%3.4f\t%s\n',timeSeq(kk),eventSeq{kk});
    % end
    % 

    % fclose(fid);
     

