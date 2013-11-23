function [or_seq,timing_seq] = grating_orientation(trig_dev,Grat_typ,RndSel,orient_8,mode_moving,moving_duration,pause_duration,spatial_period,speed,which_seq,usr_seq,black_time,gray_time,gray_scr_pos)

warning('off','MATLAB:dispatcher:InexactMatch');
%print the wait text
Screen('Preference','SkipSyncTests', 1);
%screens=Screen('Screens');
whichScreen=0;
current_window=Screen('OpenWindow',whichScreen, 0,[2560,0,3584,768],32); %coordinates for extended desktop [5120,0,6144,768]
res = Screen('Rect',current_window);

size = 76.3*spatial_period;
speed = 1/speed;

if (orient_8==1)
    num_orient = 8;
else num_orient = 16;
end

patchsz=128;
patchsz_x = patchsz*5/4;
patchsz_y = patchsz;
corr_fact = 1.1; %correction factor for beamer x/y ratio

rr=res;

r = [0 0 patchsz_x patchsz_y];



white_id=WhiteIndex(current_window);
black_id=BlackIndex(current_window);
gray_id=(white_id+black_id)/5*3.5;

inc=white_id-black_id;
%Screen('FillRect',current_window,white_id);
%Screen('TextSize',current_window,14);
%Screen('DrawText',current_window,'Computing the movie ...',10,30);



  
% compute each frame of the movie


frames=ceil(speed*FrameRate(current_window))  ; % temporal period, in frames, of the drifting grating
p=pause_duration; %time (seconds) to wait before moving grating


if (mode_moving == 1) % one-way moving
    if (RndSel == 1)
        or_seq = randperm(num_orient); % create a random permutated sequence
    else
        or_seq = 1:num_orient;
    end
    for i=1:num_orient
        if (RndSel==0)
            or = ceil((num_orient-i+1)/num_orient*360-90);
        else or = (num_orient-or_seq(i)+1)/num_orient*360-90;
        end
        for j=1:frames
            phase=((i-1)*frames+j)/frames*2*pi;
            if (Grat_typ==1)
                m=MakeGratingsino(size,or,patchsz_x,patchsz_y,phase,corr_fact);
            else
                m=MakeGratingBW(size,or,patchsz_x,patchsz_y,phase,corr_fact);
            end
            w((i-1)*frames+j)=Screen('MakeTexture', current_window, black_id+inc*m);     
        end
    end
else % two-way moving
    moving_duration=moving_duration/2;
    frames=round(moving_duration*FrameRate(current_window));
    if (RndSel == 1)
        or_seq = randperm(num_orient/2); % create a random permutated sequence
    else
        or_seq = 1:(num_orient/2);
    end
    for i=1:num_orient/2
        if (RndSel==0)
            or = ceil((num_orient-i+1)/num_orient*360-90);
        else or = (num_orient-or_seq(i)+1)/num_orient*360-90;
        end
        for j=1:frames
            phase=((i-1)*frames+j)/frames*2*pi;
            if (Grat_typ==1)
                m=MakeGratingsino(size,or,patchsz_x,patchsz_y,phase,corr_fact);
            else
                m=MakeGratingBW(size,or,patchsz_x,patchsz_y,phase,corr_fact);
            end
            w((i-1)*frames+j)=Screen('MakeTexture', current_window, black_id+inc*m);
        end
    end    
end



%Screen('Screens');	% Make sure all Rushed functions are in memory.

i=0;				% Allocate all Rushed variables.
m=1;
n=round(moving_duration*FrameRate(current_window));



%Screen(current_window,'DrawText','Computing the movie ... ready! Waiting for trigger to start movie sequence',10,30);
%priorityLevel=MaxPriority(current_window,'WaitBlanking');


Screen('FillRect',current_window,black_id);
Screen('Flip', current_window);
 % wait for trigger
%if (trig_dev == 0)
   dio = digitalio('nidaq','Dev1');
   %addline(dio,7,0,'in');
   addline(dio,4,2,'out');
    %HideCursor;
   % while ((getvalue(dio)) < 1) 
  %      pause(0.001);
 %   end
%else
    ai = analoginput('nidaq','dev1');
    ch = addchannel(ai,0);
    set(ai,'TriggerType','HwDigital');
    set(ai,'TriggerRepeat', 0);
    set(ai,'SamplesPerTrigger',10);
    set(ai,'TriggerCondition', 'PositiveEdge')
    start(ai); % wait for trigger
    HideCursor;
    while (ai.TriggersExecuted == 0)
        pause(0.0005);
    end
%end
%if (trig_dev == 0)
 %   delete(dio);
  %  clear dio;
%else
    stop(ai);
    clear ai;
%end
t0 = clock; % start timing

t=1;
tic;
%putvalue(dio.line(2),0);
if (mode_moving == 1)  % one-way moving
    if (which_seq == 1)% complete sequence
        tmp_seq = 0;
        timing_seq(t) = toc;
        t=t+1;
          putvalue(dio.line(1),1);
          putvalue(dio.line(1),0);
        Screen('FillRect',current_window,black_id);
        Screen('Flip', current_window);
        pause (black_time);
        tmp_seq = cat(2,tmp_seq,-17);
        timing_seq(t) = toc;
        t=t+1;
          putvalue(dio.line(1),1);
          putvalue(dio.line(1),0);
        Screen('FillRect',current_window,gray_id);
        Screen('Flip', current_window);
        pause (gray_time);
%        Screen('FillRect',current_window,black_id);
        tmp_seq = cat(2,tmp_seq,0);
        for q=1:num_orient
            timing_seq(t) = toc;
            t=t+1;    
              putvalue(dio.line(1),1);
              putvalue(dio.line(1),0);
       
            if(gray_scr_pos==1)
                Screen('DrawTexture',current_window,w(m+mod(1,frames)),r,rr);
                Screen('Flip', current_window);
                pause(p-0.005);
                tmp_seq = cat(2,tmp_seq,or_seq(q));
            else
                Screen('FillRect',current_window,gray_id);
                Screen('Flip', current_window);
                pause(p-0.005);
                tmp_seq = cat(2,tmp_seq,0);
            end
            timing_seq(t) = toc;
            t=t+1;
             putvalue(dio.line(1),1);
             putvalue(dio.line(1),0);
            for i=1:n;
                Screen('DrawTexture', current_window, w(m+mod(i,frames)),r,rr);
                Screen('Flip', current_window);  
            end;
            tmp_seq = cat(2,tmp_seq,or_seq(q));
            m=m+frames;
        end
        timing_seq(t) = toc;
        t=t+1;
         putvalue(dio.line(1),1);
         putvalue(dio.line(1),0);
        Screen('FillRect',current_window,gray_id);
        Screen('Flip', current_window);
        pause (gray_time);
        tmp_seq = cat(2,tmp_seq,0);
        timing_seq(t) = toc;
        t=t+1;
         putvalue(dio.line(1),1);
         putvalue(dio.line(1),0);
        Screen('FillRect',current_window,black_id);
        Screen('Flip', current_window);
        pause (black_time);  
        tmp_seq = cat(2,tmp_seq,-17);
        or_seq = tmp_seq(2:end);
    else % selected sequence
        tmp_seq = 0;
        if (length(usr_seq)==0)     
            
        else
            for q=1:length(usr_seq)
                if (usr_seq(q)== -17)
                    timing_seq(t) = toc;
                    t=t+1;
          %putvalue(dio.line(2),1);
       % putvalue(dio.line(2),0);
                    Screen('FillRect',current_window,black_id);
                    Screen('Flip', current_window);
                    pause (black_time);
                    tmp_seq = cat(2,tmp_seq,-17);
                elseif (usr_seq(q)==0)
                    timing_seq(t) = toc;
                    t=t+1;
         % putvalue(dio.line(2),1);
      %  putvalue(dio.line(2),0);
                    Screen('FillRect',current_window,gray_id);
                    Screen('Flip', current_window);
                    pause (gray_time);
                    tmp_seq = cat(2,tmp_seq,0);
                else
                    timing_seq(t) = toc;
                    t=t+1;
       %    putvalue(dio.line(2),1);
     %   putvalue(dio.line(2),0);
                    m = frames*(usr_seq(q)-1)+1;
                    if(gray_scr_pos==1)
                        Screen('DrawTexture',current_window,w(m+mod(1,frames)),r,rr);
                        Screen('Flip', current_window);
                        pause(p-0.005);
                        tmp_seq = cat(2,tmp_seq,usr_seq(q));
                    else
                        Screen('FillRect',current_window,gray_id);
                        Screen('Flip', current_window);
                        pause(p-0.005);
                        tmp_seq = cat(2,tmp_seq,0);
                    end
                        timing_seq(t) = toc;
                        t=t+1;
     %    putvalue(dio.line(2),1);
    %    putvalue(dio.line(2),0);
                    for i=1:n;
                        Screen('DrawTexture', current_window, w(m+mod(i,frames)),r,rr);
                        Screen('Flip', current_window);      
                    end; 

                    tmp_seq = cat(2,tmp_seq,usr_seq(q));
                end
            end

            if (length(tmp_seq)==1)
                or_seq = NaN;
            else
                or_seq = tmp_seq(2:end);
            end
        end
    end
   
else % two-way moving
    n=round(moving_duration*FrameRate(current_window));
    if (which_seq == 1)% complete sequence
        tmp_seq=0;
        timing_seq(t) = toc;
        t=t+1;
        %   putvalue(dio.line(2),1);
    %    putvalue(dio.line(2),0);
        Screen('FillRect',current_window,black_id);
        Screen('Flip', current_window);
        pause (black_time);
        tmp_seq = cat(2,tmp_seq,-17);
        timing_seq(t) = toc;
        t=t+1;
     %    putvalue(dio.line(2),1);
     %   putvalue(dio.line(2),0);
        Screen('FillRect',current_window,gray_id);
        Screen('Flip', current_window);
        pause (gray_time);
        tmp_seq = cat(2,tmp_seq,0);
        for q=1:(num_orient/2)
            timing_seq(t) = toc;
            t=t+1;
      %    putvalue(dio.line(2),1);
     %   putvalue(dio.line(2),0);
            if(gray_scr_pos==1)
                Screen('DrawTexture', current_window, w(m+mod(1,frames)),r,rr);
                Screen('Flip', current_window);
                pause(p-0.005);
                tmp_seq = cat(2,tmp_seq,or_seq(q));
            else
                Screen('FillRect',current_window,gray_id);
                Screen('Flip', current_window);
                pause(p-0.005);
                tmp_seq = cat(2,tmp_seq,0);
            end
            timing_seq(t) = toc;
            t=t+1;
      %  putvalue(dio.line(2),1);
      %  putvalue(dio.line(2),0);
            for i=1:n;
                Screen('DrawTexture', current_window, w(m+mod(i,frames)),r,rr);
                Screen('Flip', current_window);      
            end;
            for i=1:n;
                Screen('DrawTexture', current_window, w(m+mod(n-i+1,frames)),r,rr);
                Screen('Flip', current_window);      
            end;
            tmp_seq = cat(2,tmp_seq,-or_seq(q));
            m=m+frames;
        end
        timing_seq(t) = toc;
        t=t+1;
     %   putvalue(dio.line(2),1);
      %  putvalue(dio.line(2),0);
        Screen('FillRect',current_window,gray_id);
        Screen('Flip', current_window);
        pause (gray_time);
        tmp_seq = cat(2,tmp_seq,0);
        timing_seq(t) = toc;
        t=t+1;
      %  putvalue(dio.line(2),1);
      %  putvalue(dio.line(2),0);
        Screen('FillRect',current_window,black_id);
        Screen('Flip', current_window);
        pause (black_time);  
        tmp_seq = cat(2,tmp_seq,-17);
        or_seq = tmp_seq(2:end);
    else % selected sequence
        tmp_seq = 0;
        if (length(usr_seq)==0)
      %do nothing      
        else
            for q=1:length(usr_seq)
                if (usr_seq(q)== -17)
                    timing_seq(t) = toc;
                    t=t+1;
          %  putvalue(dio.line(2),1);
    %    putvalue(dio.line(2),0);
                    Screen('FillRect',current_window,black_id);
                    Screen('Flip', current_window);
                    pause (black_time);
                    tmp_seq = cat(2,tmp_seq,-17);
                elseif (usr_seq(q)==0)
                    timing_seq(t) = toc;
                    t=t+1;
    %      putvalue(dio.line(2),1);
     %   putvalue(dio.line(2),0);
                    Screen('FillRect',current_window,gray_id);
                    Screen('Flip', current_window);
                    pause (gray_time);
                    tmp_seq = cat(2,tmp_seq,0);
                else
                    m = frames*((usr_seq(q)-1))+1;
                    timing_seq(t) = toc;
                    t=t+1;
      %     putvalue(dio.line(2),1);
     %   putvalue(dio.line(2),0);
                    if(gray_scr_pos==1)
                        Screen('DrawTexture',current_window,w(m+mod(1,frames)),r,rr);
                        Screen('Flip', current_window);
                        pause(p-0.005);
                        tmp_seq = cat(2,tmp_seq,usr_seq(q));
                    else
                        Screen('FillRect',current_window,gray_id);
                        Screen('Flip', current_window);
                        pause(p-0.005);
                        tmp_seq = cat(2,tmp_seq,0);
                    end
                    timing_seq(t) = toc;
                    t=t+1;
       %   putvalue(dio.line(2),1);
     %   putvalue(dio.line(2),0);
                    for i=1:n;
                        Screen('DrawTexture', current_window, w(m+mod(i,frames)),r,rr);
                        Screen('Flip', current_window);      
                    end;
                    for i=1:n;
                        Screen('DrawTexture', current_window, w(m+mod(n-i+1,frames)),r,rr);
                        Screen('Flip', current_window);      
                    end;
                    tmp_seq = cat(2,tmp_seq,-usr_seq(q));
                end
            end
        end

        if (length(tmp_seq)==1)
            or_seq = NaN;
        else
            or_seq = tmp_seq(2:end);
        end
    end
end


delete(dio);
clear dio;
  
or_seq = or_seq' ;
timing_seq = timing_seq' ;
ShowCursor;

Screen('CloseAll');
