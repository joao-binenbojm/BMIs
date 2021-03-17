classdef ldaClassifier < handle
    %LDACLASSIFIER LDA Classifier
    %   Linear discriminant analysis classifier
    
    properties
        model
        pred_angle
        fr_norm
        P
    end
    
    methods
        function obj = ldaClassifier()
            %LDACLASSIFIER Construct an instance of this class
            
        end
        
        function [obj] = pca(obj,x,p)
            %PCA Calculates the principal components 
            % x - preprocessed firing rate in bins
            % p - number of components
            % P - principal components matrix
            
            C = cov(x);
            [V,D] = eig(C);
            [~,I] = maxk(abs(diag(D)),p);
            obj.P = V(:,I);
        end
        
        function [fr_total, fr_avg, obj] = fr_features(obj,data,dt,N)
            %FR_FEATURES Calculates the firing rate of the data in bins of size dt.
            % data - given data struct
            % dt - time bin size
            % N - total number of samples length of
            % fr_total - spiking rate divided in bins
            % fr_avg - average spiking rate across bins

            [T,A] = size(data); %get trial and angle length

            acc = 1;
            fr_avg = zeros(T*A,98); % initialise variables
            fr_total = zeros(T*A,N/dt*98);
            for t=1:1:T
                for a=1:1:A
                    fr = zeros(98,length(0:dt:N)-1);
                    for u=1:1:98
                        var = data(t,a).spikes(u,1:N);
                        var(var==0) = NaN; % make zeros equal to NaN
                        count = histcounts([1:1:N].*var,0:dt:N); % count spikes in every dt bin until N
                        fr(u,:) = count/dt;
                    end
                    fr_avg(acc,:) = mean(fr,2); % get mean firing rate across bins
                    f = reshape(fr,size(fr,1)*size(fr,2),1);
                    fr_total(acc,:) = f; % get all firing rates ordered in 98 blocks of the same bin
                    acc = acc+1;
                end
            end
        end
   
        function [obj] = fit(obj,trainingData)
            %FIT(trainingData) Trains model based on training data
            
            [T,~] = size(trainingData); % get size of training data
    
            N = 560; % define end time

            [~,~,X] = fr_features(trainingData,80,N); % obtaining firing rate feature space from training data
            obj.fr_norm.mean = mean(X,1);
            obj.fr_norm.std = std(X,1);
            X = (X-obj.fr_norm.mean)./obj.fr_norm.std;
            X(isnan(X)) = 0;
            X(isinf(X)) = 0;
            obj.pca(X,10);
            X = X*obj.P;
            
            % LDA classifier training
            Y=repmat([1:1:8]',T,1); % generate labels for classifier 
            obj.model = fitcdiscr(X,Y); % LDA classifier object
        end
        
        function [out,obj] = predict(obj,testData)
            %PREDICT(testData,N) uses trained model to generate labels on
            %test data
            
            N = length(testData.spikes);
            [~,~,X] = fr_features(testData,80,N); % preprocess EEG data
            X = (X-obj.fr_norm.mean)./obj.fr_norm.std;
            X(isnan(X)) = 0;
            X(isinf(X)) = 0;
            X = X*obj.P;
            out = predict(obj.model,X); % classify angle from LDA
            obj.pred_angle = out;
        end
    end
end