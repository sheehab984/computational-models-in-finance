clear();

buyers = repmat( struct( 'id', 0, 'profit_per_round', [], "overall_profit", 0, 'bid', 0 ), 10, 1);
sellers = repmat( struct( 'id', 0, 'profit_per_round', [], "overall_profit", 0, 'ask', 0 ), 10, 1);

for t=1:1:10
    buyers(t).id = t;
    sellers(t).id = t;

end

rounds = 10;
trades = 0;

average_difference = zeros(1, 500);

for p=1:1:500
    [tradesCount, buyers, sellers, overall_difference_per_round] = runBook(rounds, buyers, sellers);
    average_difference_pass = mean(overall_difference_per_round);
    average_difference(p) = average_difference_pass;
    trades = trades + tradesCount;
end


 hist(average_difference)
 sprintf('Total trades performed = %.0f',trades)

function [tradesCount, buyers, sellers, overall_difference_per_round] = runBook(rounds, buyers, sellers)
    tradesCount = 0;
    overall_difference_per_round = zeros(1, rounds);
    for t=1:1:rounds
         round_payoff = 0;
         round_profit = 0;
         for i=1:1:size(buyers)
             buyers(i).bid = randi([50, 150]);
             sellers(i).ask = randi([50, 150]);
         end
         
         buyers = sortStruct(buyers, 'bid', "descend");
         sellers = sortStruct(sellers, 'ask', "ascend");
     
         for i=1:1:size(buyers)
             if sellers(i).ask <= buyers(i).bid
                tradesCount = tradesCount + 1;
                trade_price = (buyers(i).bid + sellers(i).ask) / 2;

                buyers_payoff = 150 - trade_price;
                buyers(i).profit_per_round = [buyers(i).profit_per_round, struct('round', i, 'profit', buyers_payoff)];
                buyers(i).overall_profit = buyers(i).overall_profit + buyers_payoff;
                round_payoff = round_payoff + buyers_payoff;

                sellers_profit = trade_price - 50;
                sellers(i).profit_per_round = [sellers(i).profit_per_round, struct('round', i, 'profit', sellers_profit)];
                sellers(i).overall_profit = sellers(i).overall_profit + sellers_profit;
                round_profit = round_profit + sellers_profit;
             else
                 break
             end
         end
         overall_difference_per_round(t) = round_payoff - round_profit;
    end
end


function [sortedStruct] = sortStruct(S, key, direction)
    T = struct2table(S); % convert the struct array to a table 
    sortedT = sortrows(T, key, direction); % sort the table by 'key'
    sortedStruct = table2struct(sortedT); % change it back to struct
end