function probVec = survFuncExpWeibWeib(tVec, paramsStruct, tVec2)
% survFuncExpWeibWeib() will calculate values for a piecewise survivorship
% curve combining first an exponential death probability distribution for
% the first three days based on data from Wilmes et al. 2018, before two
% Weibull shaped death pdfs for the rest of the time, as described in
% Moneghetti et al. 2019 - "High Frequency Sampling ...",
% fitted to data from Pratchett et al. 2017

% inputs:

% tVec - a vector of time values to evaluate the model across
% paramsStruct - a structure holding the fitted parameters a.k.a. u1 and
    % v1, the lambda and nu parameters for the first Weibull function, u2
    % and v2, the lambda and nu parameters for the second Weibull function,
    % and Tcp, the time at which mortality switches between the two Weibull
    % functions
% tVec2 - optional - if specified, use as lower limits for integrations
    % between times - that is, probVec(t) will be the probability that a
    % larva will survive between from tVec2(t) to tVec(t)

% output:

% probVec - the probabilities that a larva is alive at each of the
    % times listed in timeVec

% set a default for tVec2
if nargin < 3 || isempty(tVec2)
    tVec2 = zeros(size(tVec));
end

% alright, just essentially going to set things up the way they are in the
% Moneghetti et al. code
probFuncExp = @(t1, t2) exp(-0.0954 * (t2 - t1));
probFuncEarly = @(t1, t2) exp(-((paramsStruct.u1 * t2).^paramsStruct.w1) ...
    + (paramsStruct.u1 * t1).^paramsStruct.w1);
probFuncLate = @(t1, t2) exp(-((paramsStruct.u2 * t2).^paramsStruct.w2) ...
    + (paramsStruct.u2 * t1).^paramsStruct.w2);

% alright, now let's evaluate
probVec = zeros(size(tVec));
for t = 1:length(tVec)
    if tVec(t) < 3
        probVec(t) = probFuncExp(tVec2(t), tVec(t));
    elseif tVec(t) < paramsStruct.Tcp 
        if tVec2(t) < 3
            probVec(t) = probFuncExp(tVec2(t), 3) ...
                * probFuncEarly(3, tVec(t));
        else
            probVec(t) = probFuncEarly(tVec2(t), tVec(t));
        end
    else
        if tVec2(t) < 3
            probVec(t) = probFuncExp(tVec2(t), 3) ...
                * probFuncEarly(3, paramsStruct.Tcp) ...
                * probFuncLate(paramsStruct.Tcp, tVec(t));
        elseif tVec2(t) <= paramsStruct.Tcp
            probVec(t) = probFuncEarly(tVec2(t), paramsStruct.Tcp) ...
                * probFuncLate(paramsStruct.Tcp, tVec(t));
        else
            probVec(t) = probFuncLate(tVec2(t), tVec(t));
        end
    end

end

end