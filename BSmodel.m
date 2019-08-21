clear all
% 雨虹转债（东方雨虹） 2019.7.16--2023.9.25
S0 = 22.59; % 2019.7.15股价
u = 0.0175; % 无风险利率 一年定存
sigma = 0.3585; % 固定波动率
T = 1532; % 到期天数
TD = round(T*250/365); % 交易日天数
N = 10000; % 模拟路径数
K = 22.33*ones(TD+1,N); % 转股价
V = 106; % 赎回价&偿还价
t = 1/250;  % 时间间隔（步长）
S = zeros(TD+1,N); % 路径
S(1,:) = S0; 
P = zeros(2,N); % [现期，到期]可转债价值
% p = 0.6; % 下修概率
rate = [0.003,0.005,0.01,0.013,0.015,0.018]; % 利率
r = [0.06,0.015,0.013,0.01,0.005,0.003];
v = [0.048504,0.050177,0.050568,0.052024,0.053193,0.053948]; % 贴现率
index1 = zeros(2,N); % [最后一次下修时间，下修次数]
index2 = []; % 回售路径
index3 = []; % 转股路径
index4 = []; % 赎回路径
down_record = []; % 下修记录[第？条，第？步，下修后转股价]

for j = 1:N % 第j条模拟
    for i = 1:TD % 第i步
        if ismember(j,index2) || ismember(j,index3)
            continue
        end       
        S(i+1,j) = S(i,j)*min(max(exp((u-0.5*sigma^2)*t + sigma*sqrt(t)*randn()),0.9),1.1); % B-S模型，控制10%涨停跌停
        
        % 转股
        if i>=29 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*1.3>=0)>=15 % 任何连续三十个交易日中至少十五个交易日的收盘价格不低于当期转股价格的130%（含130%）
%             fprintf('第%d条路径第%d天发生转股\n',[j,i+1])
            index3 = [index3,j];
            P(2,j) = S(i+1,j)*100/K(i+1,j);
            n = floor((i*365/250-72)/365)+1;% 判断拿了多少次利息
            P(1,j) = P(2,j)/(1+v(ceil(i/250)))^(i/250);
            if n
                P(1,j) = P(1,j) + sum(100*rate(2:2+n-1)./(1+v(1:1+n-1)).^(72/365:n-1+72/365));
            end
        end
        
        % 下修
%         if i>=29 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*0.7<=0)==30 % 任意连续三十个交易日中至少有十五个交易日的收盘价低于当期转股价格的80%
%             if rand() > 0.4
% %                 if index1(j)<2
% %                     fprintf('第%d条路径第%d天发生下修\n',[j,i+1])
%                     K(i+1:end,j) = max(mean(S(i-18:i+1,j)),S(i+1,j)); % 修正后的转股价格应不低于本次股东大会召开日前二十个交易日公司股票交易均价和前一交易日均价之间的较高者
%                     index1(:,j) = [i+1;index1(2,j)+1];
%                     down_record = [down_record;j,i+1,K(i+1,j)];
% %                 end
%             end
%         end
        
        % 回售  
        if i>=802 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*0.7<=0)==30 % 任何连续三十个交易日的收盘价格低于当期转股价格的70%
%             if i+1-index1(1,j)>=30 % 如果出现转股价格向下修正的情况，则上述“连续三十个交易日”须从转股价格调整之后的第一个交易日起重新计算
%                 fprintf('第%d条路径第%d天发生回售\n',[j,i+1])
                index2 = [index2,j];
                P(2,j) = 100*(1+rate(ceil((473+i*365/250+1)/365))); % 可转换公司债券持有人按面值加上当期应计利息的价格回售给公司
                n = floor((i-72)/365)+1;% 判断拿了多少次利息
                P(1,j) = P(2,j)/(1+v(ceil(i/250)))^(i/250);
                if n
                    P(1,j) = P(1,j) + sum(100*rate(2:2+n-1)./(1+v(1:1+n-1)).^(72/365:n-1+72/365)); % 加上已拿利息的折现
                end
%             end
        end
        
    end
end

for s = 1:N
    if P(2,s)==0 % 到期
        P(1,s) = sum(rate(2:5)./(1+v(2:5)).^(72/365:3+72/365)); % 到期前利息折现
        if S(TD+1,s)*100/K(TD+1,s)>V % 到期转股
            P(1,s) = P(1,s) + S(TD+1,s)*100/K(TD+1,s)/(1+v(5))^(T/365);
        else % 到期赎回
            index4 = [index4,s];
            P(1,s) = P(1,s) + V/(1+v(5))^(T/365);
        end
    end
end
%% 路径图
S(S == 0) = NaN;
figure()
hold on
% for draw = 1:3
index = randperm(N,1);
plot(S(:,index),'LineWidth',1.5)
title('股价预测','FontSize',20)
xlabel('天数')
ylabel('股票价格')
plot([TD TD], get(gca, 'YLim'), '--r', 'LineWidth', 1) 
plot([45 45], get(gca, 'YLim'), ':g', 'LineWidth', 1)
plot([295 295], get(gca, 'YLim'), ':g', 'LineWidth', 1)
plot([545 545], get(gca, 'YLim'), ':g', 'LineWidth', 1)
plot([795 795], get(gca, 'YLim'), ':g', 'LineWidth', 1)
day_start = datetime('2019/7/15'); % 2019.07.15，可转债买入时间
x = max(find(S(:,index)>0)); % 路径结束时间
day_end = datetime('2019/7/15')+caldays(x); % 回售/转股/赎回
if index1(2,index) % 下修
    get_down_record = down_record(down_record(:,1)==index,:);
    for m = 1:size(get_down_record,1)
        text(get_down_record(m,2),S(get_down_record(m,2),index),{['\leftarrow ',datestr(day_start+get_down_record(m,2),'yyyy-mm-dd'),' 下修'],['    当前股价 ',num2str(S(get_down_record(m,2),index),'%.2f')],['    下修转股价 ',num2str(get_down_record(m,3),'%.2f')]})
    end
end
if ismember(index,index2) % 回售
    text(x,S(x,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' 回售'],['    当前股价 ',num2str(S(x,index),'%.2f')]})
elseif ismember(index,index3) % 转股
    text(x,S(x,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' 转股'],['    当前股价 ',num2str(S(x,index),'%.2f')]})
elseif ismember(index,index4) % 赎回
    text(TD+1,S(TD+1,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' 赎回'],['    当前股价 ',num2str(S(x,index),'%.2f')]})
else % 到期转股
    text(TD+1,S(TD+1,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' 到期转股'],['    当前股价 ',num2str(S(x,index),'%.2f')]})
end
% end
% text('Units','normalized','Position',[0.01,0.95],'String',['折现2019-07-16可转债价值 ',num2str(P(1,index))],'color','r','fontsize',12)
hold off
%% 占比饼图
X = [length(index2),length(index3),length(index4),N-length(index2)-length(index3)-length(index4)];
figure()
label1 = {['回售 ',num2str(X(1)/100),'%'],['转股 ',num2str(X(2)/100),'%'],['赎回 ',num2str(X(3)/100),'%'],['到期转股 ',num2str(X(4)/100),'%']};
pie(X,[1,1,1,1],label1)
% title('各情况占比统计','Fontsize',15)
colormap(cool)
%% 下修次数饼图
% h = hist(index1(2,:),max(unique(index1(2,:)))); % 下修次数统计
% figure()
% labels2 = cellstr(string(0:max(unique(index1(2,:)))-1)+'次');
% pie(h,labels2)
% title('下修次数统计')
%% 最终股价分布图
% ind = sub2ind(size(S),sum(S>0),1:N);
% figure(),histfit(log(S(ind)),20)

fprintf('2019-07-15 模拟可转债价值：%.2f\n',mean(P(1,:)))
fprintf('本次 %d 条模拟中 提前回售 %d 条\n',[N,X(1)])
fprintf('本次 %d 条模拟中 提前转股 %d 条\n',[N,X(2)])
fprintf('本次 %d 条模拟中 到期赎回 %d 条\n',[N,X(3)])
fprintf('本次 %d 条模拟中 到期转股 %d 条\n',[N,X(4)])