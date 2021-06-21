clear;
close all;

prompt = 'Enter Joint Data:' ;
fileName = input(prompt,'s');
fileName1 = [fileName, '.mat'];
load(fileName,'-mat') 
