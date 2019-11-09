function [ output_args ] = SetAPM( channel, trial_interval )
%SETAPM Summary of this function goes here
%  Detailed explanation goes here
global APMParam

clear functions;

channel

try
    APMParam.channel=channel;
end

try
    APMParam.trial_interval=trial_interval;
end
