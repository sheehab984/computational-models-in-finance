clear()
% Failsafe table import for both moodle file name and file name mentioned
% in assignment description.
try
    table = readtable('JustEat6M-close.xlsx');
catch
    table = readtable('JustEat6M.xlsx');
end

% This contains the actual values from excel.
actual_value = table2array(table(:, 2));

% We compute the actual price trend and also the forcast value. 1
% represents price going up and 0 represents price going down. The forcast
% starts from 3rd row.
actual = zeros(size(actual_value, 1), 1);
forcast = zeros(size(actual_value, 1), 1);

for i=2:1:size(actual_value, 1)
    % Generate actual values. if today price rises 1 else 0
    if (actual_value(i-1) <= actual_value(i))
        actual(i) = 1;
    else
        actual(i) = 0;
    end
end

for i=3:1:size(actual)
    % Generate forfast 1 if yesterday price rose else 0
    if (actual_value(i - 2) <= actual_value(i-1))
        forcast(i) = 1;
    else
        forcast(i) = 0;
    end
end


true_positive = zeros(size(actual_value, 1), 1);
true_negative = zeros(size(actual_value, 1), 1);
false_positive = zeros(size(actual_value, 1), 1);
false_negative = zeros(size(actual_value, 1), 1);

% Calculate the confusion matrix.
for i=3:1:size(actual)
    if (actual(i) == 1 && forcast(i) == 1)
        true_positive(i) = 1;
    elseif (actual(i) == 1 && forcast(i) == 0)
            true_negative(i) = 1;
    elseif (actual(i) == 0 && forcast(i) == 1)
            false_positive(i) = 1;
    elseif (actual(i) == 0 && forcast(i) == 0)
        false_negative(i) = 1;
    end
end

TP = sum(true_positive);
TN = sum(true_negative);
FP = sum(false_positive);
FN = sum(false_negative);


Accuracy = (TN+TP)/(TN+FP+FN+TP);
Precision = (TP)/(FP+TP);
Recall = TP/(TP+FN);
FalsePositiveRate = FP/(FP+TN);


sprintf('Accuracy = %.0f%%',Accuracy * 100)
sprintf('Precision = %.0f%%',Precision * 100)
sprintf('Recall = %.0f%%',Recall * 100)
sprintf('False Positive Rate = %.0f%%',FalsePositiveRate * 100)

% We save the share buying price
each_share_buying_price = 8382;
% We initialize the share count.
current_shares = 125;
% Each time we sell bellow the price we bought it for, it is added to loss.
% Else it is added to profit.
profit = 0;
loss = 0;
% This array will hold the current balance for each day after 3rd. On the
% 3rd as there was no sell it will be 0. Whenever a sell is made it will
% update the current balance on that day.
balance_each_day = zeros(size(actual_value, 1), 1);

% The loop start from day 4th becase we buy on day 3rd.
for i=4:1:size(actual_value, 1) - 1
    % If we have predicted that next day is going to be a price decline. A
    % stock is sold.
    if (forcast(i+1) == 0)
        % This ensures we have enough stock reserves.
        if (current_shares > 0)
            % As the conditions are matched, a stock is sold hence the
            % count is decreased by 1. 
            current_shares = current_shares - 1;
            % The balance sheet for this day will be updated with previous
            % balance and currently sold stock price.
            balance_each_day(i) = balance_each_day(i - 1) + actual_value(i);
            % We check if the current day selling price is greater than our
            % buying price. If so we add the difference to profit.
            if actual_value(i) > each_share_buying_price
                profit = profit + actual_value(i) - each_share_buying_price;
            else
                % If not we add it to loss.
                loss = loss + each_share_buying_price - actual_value(i);
            end
        end
    else
        % If no condition is matched, yesterday's balance is forwarded to
        % today.
        balance_each_day(i) = balance_each_day(i - 1);
    end
end

% If loss is greater than profit we print the loss difference else we print
% the profit.
if (loss > profit)
    sprintf('Total loss = %.0f£', loss - profit)
else
    sprintf('Total profit = %.0f£', profit - loss)
end




