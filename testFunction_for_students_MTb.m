% Test Script to give to the students, March 2015
%% Continuous Position Estimator Test Script
% This function first calls the function "positionEstimatorTraining" to get
% the relevant modelParameters, and then calls the function
% "positionEstimator" to decode the trajectory. 

function [RMSE,elapsedTime,modelParameters] = testFunction_for_students_MTb(teamName,opt,percentage)

load monkeydata0.mat

% Set random number generator
if ~opt
    rng(2013);
end
ix = randperm(length(trial));

addpath(teamName);

% Select training and testing data (you can choose to split your data in a different way if you wish)
trainingData = trial(ix(1:50),:);
testData = trial(ix(51:end),:);

fprintf('Testing the continuous position estimator...')

meanSqError = 0;
n_predictions = 0;  

if ~opt
    figure
    hold on
    axis square
    grid
end
% Train Model
timerVal = tic;
modelParameters = positionEstimatorTraining(trainingData);
if percentage
    modelParameters.count = 0;
    modelParameters.percentage = 0;
end

for tr=1:size(testData,1)
    if ~opt
        display(['Decoding block ',num2str(tr),' out of ',num2str(size(testData,1))]);
        pause(0.001)
    end
    for direc=randperm(8) 
        decodedHandPos = [];

        times=320:20:size(testData(tr,direc).spikes,2);
        
        for t=times
            past_current_trial.trialId = testData(tr,direc).trialId;
            past_current_trial.spikes = testData(tr,direc).spikes(:,1:t); 
            past_current_trial.decodedHandPos = decodedHandPos;

            past_current_trial.startHandPos = testData(tr,direc).handPos(1:2,1); 
            if percentage
                past_current_trial.angle = direc;
            end
            if nargout('positionEstimator') == 3
                [decodedPosX, decodedPosY, newParameters] = positionEstimator(past_current_trial, modelParameters);
                modelParameters = newParameters;
            elseif nargout('positionEstimator') == 2
                [decodedPosX, decodedPosY] = positionEstimator(past_current_trial, modelParameters);
            end
            
            decodedPos = [decodedPosX; decodedPosY];
            decodedHandPos = [decodedHandPos decodedPos];
            
            meanSqError = meanSqError + norm(testData(tr,direc).handPos(1:2,t) - decodedPos)^2;
            
        end
        n_predictions = n_predictions+length(times);
        if ~opt
            hold on
            plot(decodedHandPos(1,:),decodedHandPos(2,:), 'r');
            plot(testData(tr,direc).handPos(1,times),testData(tr,direc).handPos(2,times),'b')
        end
    end
end
elapsedTime = toc(timerVal);

if ~opt
    legend('Decoded Position', 'Actual Position')
end

RMSE = sqrt(meanSqError/n_predictions); 

rmpath(genpath(teamName))
end