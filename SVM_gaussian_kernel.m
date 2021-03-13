function predict = SVM_gaussian_kernel(fr_avg,labels,C,s)
    % predict = SVM_GAUSSIAN_KERNEL(X,labels,C,sigma)
    % fr_avg - samples*features matrix
    % labels - angle number column vector (includes all angles)
    % C - regularization (SVM parameter)
    % s - variance (SVM parameter)
    
    % CLASSIFICATION 1
    % right(0): 3, 4, 5, 6 - left(1): 1, 2, 7, 8
    l = or((labels<=2),(labels>=7));
    model1 = svmTrain(fr_avg, double(l), C, @(x1, x2) gaussianKernel(x1, x2, s));
    
    % CLASSIFICATION 2
    % 3, 4 (1) - 5, 6 (0)
    l2_low = labels(~l);
    l2_low_log = labels(l2_low)<5;
    test = [3:6]';
    test = repmat(test,1,101);
    Test = test+repmat([0:8:800],size(test,1),1);
    Test = reshape(Test,1,101*size(test,1));
    Test(Test>800) = []; 
    model2_low = svmTrain(fr_avg(Test,:), double(l2_low_log), C, @(x1, x2) gaussianKernel(x1, x2, s));
    
    % 1, 2 (1) - 7, 8 (0)
    l2_high = labels(l);
    l2_high_log = labels(l2_high)<3;
    test = [1,2,7,8]';
    test = repmat(test,1,101);
    Test = test+repmat([0:8:800],size(test,1),1);
    Test = reshape(Test,1,101*size(test,1));
    Test(Test>800) = []; 
    model2_high = svmTrain(fr_avg(Test,:), double(l2_high_log), C, @(x1, x2) gaussianKernel(x1, x2, s));
    
    % CLASSIFICATION 3
    % 1 (1) - 2 (0)
    l3_high_low = l2_high(l2_high_log); 
    l3_high_low_log = l2_high(l3_high_low)<2;
    test = [1,2]';
    test = repmat(test,1,101);
    Test = test+repmat([0:8:800],size(test,1),1);
    Test = reshape(Test,1,101*size(test,1));
    Test(Test>800) = []; 
    model3_high_low = svmTrain(fr_avg(Test,:), double(l3_high_low_log), C, @(x1, x2) gaussianKernel(x1, x2, s));
    
    % 7 (1) - 8 (0)
    l3_high_high = l2_high(~l2_high_log); 
    l3_high_high_log = l2_high(l3_high_high)<8;
    test = [7,8]';
    test = repmat(test,1,101);
    Test = test+repmat([0:8:800],size(test,1),1);
    Test = reshape(Test,1,101*size(test,1));
    Test(Test>800) = []; 
    model3_high_high = svmTrain(fr_avg(Test,:), double(l3_high_high_log), C, @(x1, x2) gaussianKernel(x1, x2, s));
    
    % 3 (1) - 4 (0)
    l3_low_low = l2_low(l2_low_log);
    l3_low_low_log = l2_low(l3_low_low)<4;
    test = [3,4]';
    test = repmat(test,1,101);
    Test = test+repmat([0:8:800],size(test,1),1);
    Test = reshape(Test,1,101*size(test,1));
    Test(Test>800) = []; 
    model3_low_low = svmTrain(fr_avg(Test,:), double(l3_low_low_log), C, @(x1, x2) gaussianKernel(x1, x2, s));
    
    % 5 (1) - 6 (0)
    l3_low_high = l2_low(~l2_low_log); 
    l3_low_high_log = l2_low(l3_low_high)<8;
    test = [5,6]';
    test = repmat(test,1,101);
    Test = test+repmat([0:8:800],size(test,1),1);
    Test = reshape(Test,1,101*size(test,1));
    Test(Test>800) = []; 
    model3_low_high = svmTrain(fr_avg(Test,:), double(l3_low_high_log), C, @(x1, x2) gaussianKernel(x1, x2, s));
    
    predict.model1 = model1;
    predict.model2_low = model2_low;
    predict.model2_high = model2_high;
    predict.model3_high_low = model3_high_low;
    predict.model3_high_high = model3_high_high;
    predict.model3_low_low = model3_low_low;
    predict.model3_low_high = model3_low_high;
    
end