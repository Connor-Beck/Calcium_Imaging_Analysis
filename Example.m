clear
clc

%Path with all the functions in them
addpath('/Users/connorbeck/Library/CloudStorage/OneDrive-MontanaStateUniversity/Manuscript - iNMF - calcium/Data/Sorted Calcium Data/Scripts');
%% Single Signal Input
filename1='Dataset_A.csv';

[Data,Parameters]=AnalyzeCalcium(filename1,'Plot Calcium',true,'Plot Events',true);
%% Multi-phase Input

filepath2='';
filenames2={'Dataset_C_Part1.csv','Dataset_C_Part2.csv'};

[Data2,Parameters2]=AnalyzeCalcium(filepath2, ...
    'Multifile',filenames2,'Plot Calcium',true,'Plot Events',true);
