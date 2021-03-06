classdef DeepLearningModel < handle
    %DEEPLEARNINGMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        layers
        lossFunction
    end
    
    methods
        function [obj] = DeepLearningModel(layers)
            obj.layers = layers;
            obj.inititializeWeights();
        end
        
        function numLayers = getNumLayersWithWeight(obj)
            numLayers = 0;
            for idxLayer=1:obj.layers.getNumLayers
                currLayer = obj.layers.getLayer(idxLayer);
                if ~isempty(currLayer.weights)
                    numLayers = numLayers + 1;
                end
            end
        end
        
        function params = getModelParameters(obj)
            params = {};
            for idxLayer=1:obj.layers.getNumLayers
                currLayer = obj.layers.getLayer(idxLayer);
                if ~isempty(currLayer.weights)
                    params{idxLayer} = {currLayer.weights,currLayer.biasWeights};
                end
            end
        end
        
        function setModelParams(obj,params)
            for idxLayer=1:obj.layers.getNumLayers
                currLayer = obj.layers.getLayer(idxLayer);
                if ~isempty(currLayer.weights)
                    paramsLayer = params{idxLayer};
                    currLayer.weights = paramsLayer{1};
                    currLayer.biasWeights = paramsLayer{2};
                end
            end
        end
        
        % Can be used to predict or during training
        function [scores, grads, computedLoss] = loss(obj, X_vec, varargin)
            isTraining = 0;
            scores = 0;
            grads = {};
            
            % More than 2 parameters given, so we're o trainning
            if nargin > 2
                Y_vec = varargin{1};
                isTraining = 1;
            else
                isTraining = 0;
            end
            
            % Iterate on all layers after the input layer
            inLayer = obj.layers.getLayer(1);
            inLayer.setActivations(X_vec);
            for idxLayer=1:obj.layers.getNumLayers
                currLayer = obj.layers.getLayer(idxLayer);
                activations = currLayer.getActivations;
                % Get next layer if available
                if (idxLayer+1) <= obj.layers.getNumLayers
                    nextLayer = obj.layers.getLayer(idxLayer+1);
                    nextLayer.activations = nextLayer.fp(activations);
                end
            end
            lastLayerIndex = obj.layers.getNumLayers;
            scores = obj.layers.getLayer(lastLayerIndex).activations;
            if ~isTraining
                return;
            else
                % If we're on trainning we should calculate the loss and
                % the whole backpropagation(Get dW and dB for every layer)
                [computedLoss, dout] = obj.lossFunction.getLoss(scores,Y_vec);
                
                for idxLayer=obj.layers.getNumLayers:-1:2
                    curLayer = obj.layers.getLayer(idxLayer);
                    if isempty(curLayer.weights)
                        % Layer with no weights
                        dout = curLayer.backPropagate(dout);
                    else
                        % Layers with weights
                        [dout, dw, db] = curLayer.backPropagate(dout);
                        grads{idxLayer} = {dw,db};
                    end;
                end
            end
        end
    end
    
    methods (Access = 'private')
        %% Set the height and bias of all weights
        % Notice that not all layers have weights/bias
        function inititializeWeights(obj)
            countWeights = 1;
            
            % Iterate on all layers after the input layer
            for idxLayer=2:obj.layers.getNumLayers
                curLayer = obj.layers.getLayer(idxLayer);
                if curLayer.typeLayer == LayerType.InnerProduct
                    
                    % Look back for layers that have parameters
                    for idxBackLayer=(idxLayer-1):-1:1
                        backLayer = obj.layers.getLayer(idxBackLayer);
                        if backLayer.typeLayer == LayerType.InnerProduct || backLayer.typeLayer == LayerType.Input
                            sizePrevVector = backLayer.numOutputs;
                            break;
                        end
                    end
                    
                    curLayer.weights = rand(sizePrevVector,curLayer.numOutputs);
                    curLayer.biasWeights = rand(1,curLayer.numOutputs);
                    countWeights = countWeights + 1;
                end
            end
        end
    end
    
end

