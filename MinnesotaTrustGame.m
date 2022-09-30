function [MTG] = FinalProject
    % HELP : EMMA HERMS This experiment runs the Minnesota Trust Game. The on screen
    % instructions are minimal because participants will go through
    % practice trials before this in scanner task. No parameters are
    % input for this task to run. The task automatically changes based on screen
    % size. (However, text size is not dynamic currently). Also, there is
    % no penalty for holding down a key. (If I temporarily stop the
    % task due to someone holding down a key and that increases taks length how
    % does that interact with the length of the scan?)
    
%% Asking Researcher who Participant Is

ID = input('What is the participants ID?   ','s'); % takes numbers or letters as input

%% Opening psychotoolbox window and setting up output structure 

[w1, rect] = Screen('OpenWindow', 0, [0 0 0]);
outputData = [] ; % empty matrix to hold trial data
colNames = {'block', 'ad', 't', 'choice'}; % creating headers for our outputTable, NOT CURRENTLY SAVING TIME OF DECISION 

%% creating 3d matrix for three blocks with 18 distinct trials - NOT RANDOMIZED becuase old script wasn't (check with Krista later)

block1 = [-6 -8 7 1 20 16 15 13 12 11 -5 5 7 6 -4 0 3 -1; 25 15 15 25 15 25 25 15 25 15 15 25 25 15 25 15 15 25]; % first row represents ad, second row represents t
block2 = [ 4 2 12 14 2 6 18 16 9 14 -2 -8 -3 10 -10 -2 -5 9; 15 25 15 15 15 25 25 15 25 25 25 25 15 25 15 15 25 15];
block3 = [ 8 -3 15 3 -4 20 18 13 8 -6 0 5 -10 11 4 1 -1 10; 25 25 15 25 15 25 15 25 15 15 25 15 25 25 25 15 15 15];
dataIn = cat(3,block1, block2,block3); %3D matrix where 1st dimension = ad, t (trial variables), 2nd dimension = trial number and 3rd dimension = blocks

%% Text used throughout experiment

scanner = 'Please wait while we set up the scanner.\n Dan, press the tilda key!';
instructions = 'You will now play the game in which another player decides how much money you will win.\nPlease remember to look at all of the dollar values on the screen before making your choice.\nUse the up arrow key to select the top card and the down arrow key to select the bottom card.\nYou will have 6 seconds for each decision.';
takeTen = 'You take 10'; % this never changes on bottom card
otherPlayer = 'Other Player Decides';
twenty = '20'; % this never changes on top card

%% Key presses allowed for experiment

targetKeys ={'up', 'down'};
for ii = 1:length(targetKeys)
    allowedKey(ii) = KbName(targetKeys{ii});
end

%scanner simulation key
tilda = KbName('`'); 

%% Finding Screen dimensions and calculating "card" placement

%splitting the height of screen into 15ths 
fifteenthHeight = rect(4)/15;
%splitting the width of screen into thirds
quarterWidth = rect(3)/4;

%used in FillRect function to create black rectangles
cardMatrix = [quarterWidth quarterWidth; fifteenthHeight (fifteenthHeight*8); (quarterWidth*3) (quarterWidth*3); (fifteenthHeight*7) fifteenthHeight*14];

%% location of text and numbers on "cards" based on screen dimensions

%top card main text locations
xOtherPlayer = (quarterWidth*2)-400;
yOtherPlayer = (fifteenthHeight*4)-31;

%top card number locations
xNum = (quarterWidth*2)-144;
xTwenty = (quarterWidth*2)+100;
yTopNum = yOtherPlayer-150;
yBottomNum = yOtherPlayer+150;

%bottom card text locations
xTakeTen = (quarterWidth*2)-225;
yTakeTen = (fifteenthHeight*11)-31;

%% color used for card text and numbers 

grey = [204 198 194];
otherPlayerColor = [0 255 255];
participantColor = [255 255 0];

%% Wait for scanner

Screen('TextSize', w1, 60); % setting text size for wait for scanner
DrawFormattedText(w1, scanner,'center', 'center', [250 250 250]);
Screen('Flip', w1); % flip to see wait for scanner text

% useless while loop to simulate scanner :)
while 1 
    [~, ~, keyCode] = KbCheck(-1); 
    if any(keyCode(tilda)) % checking if any keyCode is the tilda to end wait for scanner tiral
        break;
    end
end

%% Present Task Instructions

Screen('TextSize', w1, 60); % setting text size for instructions
DrawFormattedText(w1, instructions,'center', 'center', [250 250 250]);
Screen('Flip', w1); % flip to see Instructions
pause(15); % pause so subjects can read instructions

%% loop - first for loop is for blocks, second for loop is for trials

for ii = 1:size(dataIn,3) % fixed number of blocks from dataIn matrix
    for jj = 1:size(dataIn,2) %trials from dataIn matrix
        %%fixation before trials
        Screen('DrawLine', w1, [250 0 0], (rect(3)/2), (rect(4)/2-50), (rect(3)/2), (rect(4)/2+50), 10);
        Screen('DrawLine', w1, [250 0 0], (rect(3)/2-50), (rect(4)/2), (rect(3)/2+50), (rect(4)/2), 10);
        Screen('Flip', w1); %show red fixation
        pause(2)
        
        %% trial code
        Screen('TextSize', w1, 85); % setting text size for cards
        %formatting of cards
        Screen('FrameRect', w1, [otherPlayerColor; participantColor]', cardMatrix, 10); %create outline for cards
        Screen('DrawText', w1, otherPlayer, xOtherPlayer, yOtherPlayer, otherPlayerColor); % creates top card text
        Screen('DrawText', w1, twenty, xTwenty, yTopNum, participantColor); % creates top card right side numbers
        Screen('DrawText', w1, twenty, xTwenty, yBottomNum, otherPlayerColor); % creates top card right side numbers
        Screen('DrawText', w1, num2str(dataIn(1,jj,ii)), xNum, yTopNum, participantColor); % creates top card left side numbers
        Screen('DrawText', w1, num2str(dataIn(2,jj,ii)), xNum, yBottomNum, otherPlayerColor); % creates top card left side numbers
        Screen('DrawText', w1, takeTen, xTakeTen,yTakeTen, participantColor); % creates bottom card text
        Screen('Flip', w1); % presenting trial
        
        start = GetSecs; % starting timmer after flip
        while GetSecs-start < 6 % hard coding six seconds becuase timer needs to be consistent across sites
            [~, ~, keyCode] = KbCheck(-1); % checking if any keyCode is an allowedKey to end tiral
            if any(keyCode(allowedKey))
                break ;
            end
        end
        
        %% Making Cards Grey after 6 seconds or decision
        if isempty(KbName(keyCode)) || ~any(keyCode(allowedKey)) %checking to see if no key pressed or any key that is not allowed
            Screen('FrameRect', w1, [grey;grey]', cardMatrix, 10);% creats outline for cards
            Screen('DrawText', w1, otherPlayer, xOtherPlayer, yOtherPlayer, grey);
            Screen('DrawText', w1, twenty, xTwenty, yTopNum, grey);% creates top card right side numbers
            Screen('DrawText', w1, twenty, xTwenty, yBottomNum, grey);% creates top card right side numbers
            Screen('DrawText', w1, num2str(dataIn(1,jj,ii)), xNum, yTopNum, grey);% creates top card left side numbers
            Screen('DrawText', w1, num2str(dataIn(2,jj,ii)), xNum, yBottomNum, grey);% creates top card left side numbers
            Screen('DrawText', w1, takeTen, xTakeTen,yTakeTen, grey); %creates text for bottom card
            keyValue = "NA"; %using to store choice in outputData
            
        elseif KbName(keyCode) == "up"
            Screen('FrameRect', w1, grey, [cardMatrix(:,1)'], 10);% creats outline for cards
            Screen('DrawText', w1, otherPlayer, xOtherPlayer, yOtherPlayer, grey);
            Screen('DrawText', w1, twenty, xTwenty, yTopNum, grey);% creates top card right side numbers
            Screen('DrawText', w1, twenty, xTwenty, yBottomNum, grey);% creates top card right side numbers
            Screen('DrawText', w1, num2str(dataIn(1,jj,ii)), xNum, yTopNum, grey);% creates top card left side numbers
            Screen('DrawText', w1, num2str(dataIn(2,jj,ii)), xNum, yBottomNum, grey);% creates top card left side numbers
            keyValue = "up"; %using to store choice in outputData
            
        elseif KbName(keyCode) == "down"
            Screen('FrameRect', w1, grey, [cardMatrix(:,2)'], 10); % creats outline for cards
            Screen('DrawText', w1, takeTen, xTakeTen,yTakeTen, grey); %creates text for bottom card
            keyValue = "down"; %using to store choice in outputData
        end
        Screen('Flip', w1); % shows either one card or both cards greyed out depending on conditional above
        pause(2) % allows time for particpant to recieve feedback
        
        %% Getting Trial data and adding to existing outputData
        % {'block', 'ad', 't', 'choice'}
        trialData = [ii dataIn(1,jj,ii) dataIn(2,jj,ii) keyValue]; % individual trial data
        outputData = [outputData; trialData]; % Add trial data to all of participants data
    end
end

Screen('CloseAll')

%% Saving 2D data matrix and ID to MTG cell array 

outputTable = array2table(outputData,'VariableNames',colNames); %creating table with outputData and colNames specified at beginning
MTG = {ID, outputTable}; %saving participants outputTable to a cell array with ID
