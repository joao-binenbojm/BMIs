function [model] = positionEstimatorTraining(training_data, bw, delay)
  % Arguments:
  
  % - training_data:
  %     training_data(n,k)              (n = trial id,  k = reaching angle)
  %     training_data(n,k).trialId      unique number of the trial
  %     training_data(n,k).spikes(i,t)  (i = neuron id, t = time)
  %     training_data(n,k).handPos(d,t) (d = dimension [1-3], t = time)
  model = KalmanModel(bw, delay);
  model = model.fit(training_data);
  
  % Return Value:
  
  % - model object:
  %     single model object that represents the trained model with
  %     appropriate model parameters
  
end