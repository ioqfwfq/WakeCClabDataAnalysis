function GeneralizedCutterStepAutosave(force)

%========================================
% GeneralizedCutterStepAutosave(force)
% steps autosave using global variable MClust_autosave
% if force is true then autosaves anyway

if nargin == 0; force = 0; end

global MClust_Autosave
MClust_Autosave = MClust_Autosave-1;
autosaveCounterHandle = findobj('Tag', 'Autosave');

if MClust_Autosave == 0 | force
    set(autosaveCounterHandle, 'String', 'Autosaving ...');
    % get components
    global MClust_Colors MClust_TTfn MClust_Clusters MClust_FeatureNames MClust_ChannelValidity
	global MClust_ClusterFileNames featureindex featuresToUse
    [basedn, basefn, ext] = fileparts(MClust_TTfn);
    featureToUseHandle = findobj('Tag', 'FeaturesUseListbox');
    featuresToUse = get(featureToUseHandle, 'String');
    % save defaults
    save(fullfile(basedn,'autodflts.mclust'), 'MClust_Colors', 'featuresToUse', '-mat');
    % save clusters
    global MClust_Clusters
    save(fullfile(basedn,'autosave.clusters'), 'MClust_Clusters', 'MClust_FeatureNames', ...
         'MClust_ChannelValidity','MClust_Colors','MClust_ClusterFileNames','featuresToUse','featureindex','-mat');
    % reset counter
    global MClust_Autosave
    MClust_Autosave = 10;
    set(autosaveCounterHandle, 'String', 'Autosaved');
end

set(autosaveCounterHandle, 'String', ['Autosave in ' num2str(MClust_Autosave)]);