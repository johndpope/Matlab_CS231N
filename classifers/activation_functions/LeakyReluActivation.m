classdef LeakyReluActivation < BaseActivationFunction
    %RELUACTIVATION Leaky-Relu Activation function (Standard for DNN)  
    % The idea is to solve the dying neuron
    % http://mochajl.readthedocs.org/en/latest/user-guide/neuron.html
    % http://arxiv.org/pdf/1505.00853.pdf
    methods(Static)
        function [result] = forward_prop(x)
            result = max(0.01*x,x);
        end
        
        function [result] = back_prop(x)
            if x>0
                result = 1;
            else
                result = 0.01;
            end            
        end
    end
    
end

