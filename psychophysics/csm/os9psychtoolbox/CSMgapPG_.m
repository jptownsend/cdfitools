% This program alternates between square-wave CSM and a fixed-disparity plane, with intervening gray gaps% For CSM1, the fixed-disparity plane is at zero disparity% For CSM2, the fixed-disparity plane is at a disparity matching one or other of the CSM planes% For CSM3, the fixed-disparity plane is at random depths over the range of% the sin csm stim%% init clear all% stimGating = 0; %=- set to 0 to show the stim all the time, not 0 to gate using digital one on activewiresterzShift = [ 1 0 1 0 ]*60; %%%=- msb to shift displays nasal or temporal ( global disparity )%% active wire setup for TTL fixation input% activewire(1,'OpenDevice') % open device 1% activewire(1,'SetDirection',[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]) % set all I/O lines to input%% timinghalfPeriod = 32; %Half-period of CSM2 but a full period of CSM due to four-phase cycle					%24 gives 10 sec CSM, 2 sec gray, 10 sec fixed-disparity, 2 sec graynCycles = 3; % 6 gives 12 cycles of CSM, six of the null depth alternation in CSM2%=- duration is 2*halfPeriod*nCyclessecsToDiscard = 9 ;dTPlan = 0.005; planFreq = round(1/dTPlan); %time sampling in the experimental plandT = 0.125;	% must not be changed !!!! gap=2; % duration of zero-disparity gap (sec)nonGap = halfPeriod/2-gap; % residual non-gap durationgapL=0.3; % luminance of the gap%% user input and defaults% choice = menu('Frequency', '0.33 Hz','1 Hz', '2 Hz', '4 Hz');% switch choice% case 1, period = 3, sizeDot = 4, disparity=24  % case 2, period = 1,  sizeDot = 4, disparity=20% case 3, period = 0.5,  sizeDot = 4, disparity=16% case 4, period = 0.25,  sizeDot = 4, disparity=12% endperiod = 1;  sizeDot = 4; disparity=10; %defaultchoice = menu('Frequency', '0.33 Hz','1 Hz', '2 Hz', '4 Hz');switch choicecase 1, period = 3, sizeDot = 4, disparity=10  case 2, period = 1,  sizeDot = 4, disparity=10case 3, period = 0.5,  sizeDot = 4, disparity=10case 4, period = 0.25,  sizeDot = 4, disparity=10enddispMagn=disparity/sizeDot;sizeX = 128;sizeY = 128;sizeFix = 2;sizePat = 4;dens = 0.1;sterRect = [0,0,sizeDot*sizeX,sizeDot*sizeY];sizeXY = sizeX*sizeY;centerInd = (sizeX/2+0.5)*sizeY;surfaceType = 1;nullType=2; fixType = 1; % defaultchoice = menu('Stimulus','CSM1 ','CSM2','csm1stat','csm2stat','csm3stat');switch choice	case 1,  nullType=1, fixType = 1; 	case 2,  nullType=2, fixType = 1;	case 3,  nullType=1, fixType = 4; 	case 4,  nullType=2, fixType = 4;    case 5,  nullType=3, fixType = 4;endmotionType = menu('Motion Type', 'step','sin');fixMov = 0;nHalfPeriodPlan = round(halfPeriod*planFreq);%% stimulus calculations% exp plan sampled every dTPlan=5 msexpPlan = [+(1:nHalfPeriodPlan), -(1:nHalfPeriodPlan)]; % 1 cycleexpPlan = expPlan * halfPeriod/nHalfPeriodPlan;expPlan = kron(ones(1,nCycles+1),expPlan); % nCycles+1 cyclesexpPlan = expPlan((2*nHalfPeriodPlan+1-planFreq*secsToDiscard):end); % nCycles + secsToDiscard upfrontMexpPlan=max(expPlan)/2; %precomputes max for gap insertionshift=0;gapPlan=[expPlan(end-shift+1:end) expPlan(1:end-shift)]; %shifts gapPlan FORWARD relative to expPlan% show the planEPL = length(expPlan);plot((1:EPL),expPlan,'.',[0 EPL],[1 1]*MexpPlan,[0 EPL],[1 1]*-MexpPlan,(1:EPL),gapPlan );% white dots, color fixationplaneClut{1} = 255*[0,0,0; 1, 1, 1];planeClut{2} = 255*[0,0,0; 1, 1, 1];planeClut{3} = 255*[0,0,0; 1, 0.8, 0.2]; %=-  gold% planeClut{3} = 255*[0,0,0; 1, 1, 1]; %=- white% ????plane0 = zeros(sizeY,sizeX);plane1 = ones(sizeY,sizeX);plane2 = plane1; plane2(round(sizeY*2/5)+1:round(sizeY*3/5),:) = 0;%% making cluts for the movieclut{1} = CombineCluts(planeClut,[1,0,2]);clut{2} = CombineCluts(planeClut,[0,1,2]);%% screens%Screen('Preference','Backgrounding',0)screenNumber=[1,2];for n = 1:2 %#ok<FORPF>	window(n) = Screen(screenNumber(n),'OpenWindow',0);	%%%Screen(window(n),'Preference','AskSetClutDriverToWaitForBlanking',1);	Screen(window(n),'Preference','DacBits',8);end%% defining rectangleswindowRect = Screen(window(1),'Rect');sterRect = CenterRect(sterRect,windowRect);%% preparing fixations%tmp = zeros(sizeY,sizeX);%tmp(sizeY/2-sizeFix/2+1:sizeY/2+sizeFix/2,sizeX/2-sizeFix/2+1:sizeX/2+sizeFix/2)=1;%fixInds{1} = find(tmp(:));	%squaretmp = zeros(sizeY,sizeX);tmp(sizeY/2, sizeX/2-sizeFix:sizeX/2+sizeFix)=1;tmp(sizeY/2-sizeFix:sizeY/2+sizeFix, sizeX/2)=1;fixInds{1} = find(tmp(:));	%=- msb  cross fixationtmp = zeros(sizeY,sizeX);tmp(sizeY/2-2*sizeFix:sizeY/2-1,sizeX/2) = 1;fixInds{2} = find(tmp(:));	% nonius lefttmp = flipud(tmp);fixInds{3} = find(tmp(:));	% nonius rightfixInds{4} = union(fixInds{1},2*sizeFix*sizeY+fixInds{2}); % square+nonius leftfixInds{5} = union(fixInds{1},2*sizeFix*sizeY+fixInds{3}); % square+nonius right%%=-  dots surroundtmp = zeros(sizeY,sizeX); %=- make empty planetmp( sizeY/2-sizePat*2:sizeY/2+sizePat*2 , sizeX/2-sizePat*2:sizeX/2+sizePat*2 )=1; %=- make a square masktmp2 = round(rand(sizeY,sizeX)-.5+dens); %=- make a plane of random dotsfixInds{6} = find(tmp(:)); %=- save the mask tmp( sizeY/2-sizeFix*2:sizeY/2+sizeFix*2 , sizeX/2-sizeFix*2:sizeX/2+sizeFix*2 )=0; %=- blank area around the cross fixtmp = tmp2.*tmp; %=- apply mask to random dotsfixInds{7} = find(tmp(:)); % save the random dotsplaneToBe{1} = plane0; planeToBe{2} = plane0;%% mainScreen('MatlabToFront')disp('Press any key to start');pausetictime0 = GetSecs;t0 = time0;for k=1:1000000000	planeBeen{1} = planeToBe{1}; planeBeen{2} = planeToBe{2};	t1 = GetSecs;	t = t1 - t0;		nT = ceil(t*planFreq);	if nT > length(expPlan), break, end		planeToChange = rem(k,2);		switch motionType;	case 1, % step CSM stereomotion: CWT		if abs(expPlan(nT)) > MexpPlan  % Select for stereomotion for high values of expPlan			if surfaceType == 1 				if nullType==1 % CSM1					dispMod = 0;				else % nullType=2; CSM2					dispMod = sign(expPlan(nT));				end			else				dispMod = 1;			end		else			dispMod = mod(expPlan(nT), period);			if dispMod < period/2				dispMod = 1;			else				dispMod = -1;			end		end		dFactor = round(dispMagn*dispMod);		if surfaceType == 1			disp = dFactor*plane1;		else			disp = dFactor*plane2;		end	case 2,  %sinusoidal stereomotion		if abs(expPlan(nT)) > MexpPlan			if surfaceType == 1                switch nullType                    case 1                        dispMod = 0;                    case 2                        dispMod = sign(expPlan(nT));                    case 3                        dispMod = (2*rand) - 1;                end			else				dispMod = 1;			end		else 			dispMod = sin(2*pi*expPlan(nT)/period);		end		dFactor = round(dispMagn*dispMod);		if surfaceType == 1			disp = dFactor*plane1;		else			disp = dFactor*plane2;		end	end	if fixMov			dispFix = round(dispMagn*dispMod);	else		dispFix = 0;%		dispFix = -8; %%%=- msb : move fix disparity here -=%%%	end	% about .02-.03 s	planeToBe{1} = round(rand(sizeY,sizeX)-.5+dens);	planeToBe{2} = round(rand(sizeY,sizeX)-.5+dens);	inds0 = (1:sizeXY)';    inds1 = inds0 - sizeY*disp(:);    inds1 = max(inds1,1);    inds1 = min(inds1,sizeXY);	planeToBe{2}(inds1) = planeToBe{1}(inds0);			% about 0.01 s	for n=1:2		% add plane		ster{n} = planeBeen{n}*2^planeToChange+planeToBe{n}*2^(1-planeToChange);		switch fixType; %=- set the fixation type		case 1, %=- simple cross			if n == 1 				ster{n}(fixInds{1}+floor(dispFix/2)*sizeY) = 4;			else				ster{n}(fixInds{1}-ceil(dispFix/2)*sizeY) = 4;			end		case 2,			if n == 1				ster{n}(fixInds{2}+floor(dispFix/2)*sizeY) = 4;			else				ster{n}(fixInds{3}-ceil(dispFix/2)*sizeY) = 4;			end		case 3,			if n == 1				ster{n}(fixInds{4}+floor(dispFix/2)*sizeY) = 4;			else				ster{n}(fixInds{5}-ceil(dispFix/2)*sizeY) = 4;			end		case 4, %=- cross with static dots surround			if n == 1 %=- static surround				ster{n}(fixInds{6}+floor(dispFix/2)*sizeY) = 0;			else				ster{n}(fixInds{6}-ceil(dispFix/2)*sizeY) = 0;			end			if n == 1 %=- static dots in surround				ster{n}(fixInds{7}+floor(dispFix/2)*sizeY) = 3;			else				ster{n}(fixInds{7}-ceil(dispFix/2)*sizeY) = 3;			end			if n == 1 %=- simple cross				ster{n}(fixInds{1}+floor(dispFix/2)*sizeY) = 4;			else				ster{n}(fixInds{1}-ceil(dispFix/2)*sizeY) = 4;			end		end		end	% about 0.08 s	% 	if stimGating == 0% 		portValue(1)=1; %%%=- to disable stimulus gating -=%%%% 	else% 		portValue= activewire(1,'GetPort'); % is monkey fixating?% 	end		for n=1:2				ep = abs(gapPlan(nT)) - MexpPlan; gep = ep - MexpPlan/2*(sign(ep)-1); % generates a double-frequency ramp				if gep > nonGap; % Changes display at end of each phase "gaps"			ster{n} = (1-gapL)*200*plane1;			if n == 1				ster{n}(fixInds{1}+floor(dispFix/2)*sizeY) = 4;			else				ster{n}(fixInds{1}-ceil(dispFix/2)*sizeY) = 4;			end		end			if k*dT<secsToDiscard % Changes display at beginning of run			ster{n} = (1-gapL)*200*plane1;			if n == 1				ster{n}(fixInds{1}+floor(dispFix/2)*sizeY) = 4;			else				ster{n}(fixInds{1}-ceil(dispFix/2)*sizeY) = 4;			end		end		%%%%=- stimulus gating based on TTL input line -=%%%%% 		if portValue(1) == 1 % if the digital input line is high%				Screen(window(n), 'PutImage', ster{n}, sterRect+sterzShift*((n-1.5)*2)); % show the stuff =- msb shift in or out by sterzShift% 		else% 				Screen(window(n), 'FillRect',0); % dont show stuff% 		end			Screen(window(n), 'PutImage', ster{n}, sterRect+sterzShift*((n-1.5)*2));	end		time1 = GetSecs;% 	if time1 - time0 > dT% 			error('rate too fast')% 	else% 		while 1% 			time1 = GetSecs;% 			if time1 - time0 > dT% 				time0 = time1;% 				break% 			end% 		end% 	end	% less than 1 ms	%if k*dT>secsToDiscard % Changes display at beginning of run	if k*dT>0 % never Changes display at beginning of run		if gep < nonGap; % blocks flickering by showing dots only before gap			Screen(window(1),'SetClut',clut{2-planeToChange});			Screen(window(2),'SetClut',clut{2-planeToChange});		end	endend%% clean uptocclear allScreen('MatlabToFront')