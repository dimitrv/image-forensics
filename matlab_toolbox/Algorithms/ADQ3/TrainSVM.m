% This script implements training of the SVM models according to
% Amerini, Irene, Rudy Becarelli, Roberto Caldelli, and Andrea Del Mastio.
% "Splicing forgeries localization through the use of first digit features."
% In Information Forensics and Security (WIFS), 2014 IEEE International
% Workshop on, pp. 143-148. IEEE, 2014.

% Copyright (C) 2016 Markos Zampoglou
% Information Technologies Institute, Centre for Research and Technology Hellas
% 6th Km Harilaou-Thermis, Thessaloniki 57001, Greece

clear all;
close all;
% TrainingFeature.mat contains the features from the artificial dataset
% created according to the specifications in the paper. The code that
% produced TrainingFeature.mat is in ExtractTrainingFeatures.m
load('TrainingFeature.mat');

TrainRatio=1;

for QualityInd=1:length(SingleFeatures)
    nDoubleExamples=length(DoubleFeatures{QualityInd});
    nSingleExamples=length(SingleFeatures{QualityInd});
    nTrainSingle=ceil(nSingleExamples*TrainRatio);
    nTrainDouble=ceil(nDoubleExamples*TrainRatio);
    
    %---Train by replicating Single Compression Examples
    %ClassRatio=floor(nDoubleExamples/nSingleExamples);
    %TrainData=[DoubleFeatures{QualityInd}(1:nTrainDouble,:);repmat(SingleFeatures{QualityInd}(1:nTrainSingle,:),ClassRatio,1)];
    %TrainLabels=[ones(nTrainDouble,1);zeros(ClassRatio*nTrainSingle,1)];
    %EvalData=[DoubleFeatures{QualityInd}(nTrainDouble+1:end,:);repmat(SingleFeatures{QualityInd}(nTrainSingle+1:end,:),ClassRatio,1)];
    %EvalLabels=[ones(nDoubleExamples-nTrainDouble,1);zeros(ClassRatio*(nSingleExamples-nTrainSingle),1)];
    
    %---Train by subsampling Double Compression Examples
    DoublesRandomizer=randperm(length(DoubleFeatures{QualityInd}));
    TrainData=[DoubleFeatures{QualityInd}(DoublesRandomizer(1:nTrainSingle),:);SingleFeatures{QualityInd}(1:nTrainSingle,:)];
    TrainLabels=[ones(nTrainSingle,1);zeros(nTrainSingle,1)];
    EvalData=[DoubleFeatures{QualityInd}(DoublesRandomizer(nTrainSingle+1:length(SingleFeatures{QualityInd})),:);SingleFeatures{QualityInd}(nTrainSingle+1:length(SingleFeatures{QualityInd}),:)];
    EvalLabels=[ones(nSingleExamples-nTrainSingle,1);zeros(nSingleExamples-nTrainSingle,1)];
    
    
    %RandInd=randperm(length(TrainLabels));
    %TrainData=TrainData(RandInd,:)/64;
    %TrainLabels=TrainLabels(RandInd,:);
    TrainData=TrainData/64;
    EvalData=EvalData/64;
    options.MaxIter=50000;
    
    Model = svmtrain(TrainData,TrainLabels,'autoscale',false,'kernel_function','mlp','options',options);
    %[~,BestModel]=min(Performance);
    SVMStruct{QualityInd} = Model;
    %[TrainRun, TrainDists] = svmclassify_dist(SVMStruct{QualityInd},TrainData);
    %[EvalRun, EvalDists] = svmclassify_dist(SVMStruct{QualityInd},EvalData);
    %disp([mean(TrainRun==TrainLabels) mean(TrainLabels) mean(EvalRun==EvalLabels) mean(EvalLabels)])
end