function probVec = compFuncWeibExp(tVec, paramsStruct)
% compFuncWeibExp() will calculate values for a piecewise competency
% curve with an exponential gain in competency, an initial Weibull loss in
% competency, and a final exponential loss in competency as described in
% Moneghetti et al. 2019 - "High Frequency Sampling ..."

% inputs:

% tVec - a vector of time values to evaluate the model across
% paramsStruct - a structure holding the relevant parameters a.k.a. a, the
    % exponential rate of competence gain, b1, the lambda parameter for the
    % initial Weibull loss in competence, v1, the nu parameter for the
    % initial Weibull loss in competence, b2, the exponential rate at which
    % competency is lost after Tcp, Tcp, the point at which the loss in
    % competence changes from Weibull to exponential, tc, the earliest time
    % at which competency is gained

% output:

% probVec - the probabilities that a larva is competent at each of the
    % times listed in timeVec

% alright, just essentially going to set things up the way they are in the
% Moneghetti et al. code
earlyInt = @(tau, t) paramsStruct.a * exp(-paramsStruct.a * (tau ...
    - paramsStruct.tc)) .* exp(-((paramsStruct.b1 ...
    * (t - tau)).^paramsStruct.v1));
laterInt1 = @(tau, t) paramsStruct.a * exp(-paramsStruct.a * (tau ...
    - paramsStruct.tc)) .* exp(-((paramsStruct.b1 * (paramsStruct.Tcp ...
    - tau)).^paramsStruct.v1)) .* exp(-paramsStruct.b2 * (t ...
    - paramsStruct.Tcp));
laterInt2 = @(tau, t) paramsStruct.a * exp(-paramsStruct.a * (tau ...
    - paramsStruct.tc)) .* exp(-paramsStruct.b2*(t - tau));

% alright, now let's evaluate
probVec = zeros(size(tVec));
for t = 1:length(tVec)
    if tVec(t) < paramsStruct.tc
        probVec(t) = 0;
    elseif tVec(t) <= paramsStruct.Tcp
        probVec(t) = integral(@(tau) earlyInt(tau, tVec(t)), ...
            paramsStruct.tc, tVec(t));
    else
        probVec(t) = integral(@(tau) laterInt1(tau, tVec(t)), ...
            paramsStruct.tc, paramsStruct.Tcp) + integral(...
            @(tau) laterInt2(tau, tVec(t)), paramsStruct.Tcp, tVec(t));
    end
end

end