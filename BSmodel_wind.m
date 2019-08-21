clear all
discount = [0.032591,0.033751,0.035340,0.035999,0.036493,0.037185;  % 贴现率
    0.046304,0.047977,0.048168,0.049424,0.050393,0.050948;
    0.047304,0.048977,0.049168,0.050524,0.051493,0.052248;
    0.048504,0.050177,0.050568,0.052024,0.053193,0.053948;
    0.050704,0.052377,0.053368,0.054824,0.055993,0.056948;
    0.059504,0.061377,0.064268,0.066624,0.067793,0.069248];
rank = {'无风险','AAA','AAA-','AA+','AA','AA-'}; % 债券评级
%% 雨虹转债 2019.7.16--2023.9.25
% w = windmatlab; % wind接口
% 获取2019.7.15东方雨虹的 股价、固定波动率
% [data_stock,~,~,times_stock,~,~] = w.wsd('002271.SZ','close,annualstdevr_24m','2019-07-15','2019-07-15');
% 获取2019.7.15雨虹转债的 到期日、发行日、回售开始日、最新债项评级、转股价、下一付息日
% [data_bond,~,~,times_bond,~,~] = w.wsd('128016.SZ','maturitydate,clause_conversion_2_swapsharestartdate,clause_putoption_conditionalputbackstartenddate,amount,convprice,nxcupn','2019-07-15','2019-07-15');
data_stock = [22.59,35.85];
times_stock = 737621;
data_bond = {'2023/9/25','2018/3/29','2021/9/25','AA+',22.33,'2019/9/25'};
T_end = datenum(cell2mat(data_bond(1))); % 到期
T_start = datenum(cell2mat(data_bond(2))); % 发行
T_put = datenum(cell2mat(data_bond(3))); % 回售
T_nxcup = datenum(cell2mat(data_bond(6))); % 下一付息日

S0 = data_stock(1); % 2019.7.15股价
u = 0.0175; % 无风险利率 一年定存
sigma = data_stock(2)/100; % 固定波动率
T = datenum(cell2mat(data_bond(1)))-times_stock-1; % 到期天数
TD = round(T*250/365); % 折算交易日
N = 1000; % 模拟路径数
K = cell2mat(data_bond(5))*ones(1,N); % 转股价
V = 106; % 赎回价&偿还价
t = 1/250;  % 时间间隔（步长）
S = zeros(TD+1,N); % 路径
S(1,:) = S0; 
P = zeros(2,N); % [现期，到期]可转债价值
% p = 0.6; % 下修概率
rate = [0.003,0.005,0.01,0.013,0.015,0.018]; % 利率
r = [0.06,0.015,0.013,0.01,0.005,0.003];
v = discount(strcmp(rank,cell2mat(data_bond(4))),:); % 贴现率
index1 = zeros(1,N); % 下修时间
index2 = []; % 回售路径
index3 = []; % 转股路径
index4 = []; % 赎回路径

for i = 1:TD % 第i步
    for j = 1:N % 第j条模拟
        
        S(i+1,j) = S(i,j)*min(max(exp((u-0.5*sigma^2)*t + sigma*sqrt(t)*randn()),0.9),1.1); % B-S模型，控制10%涨停跌停
        if (ismember(j,index2) || ismember(j,index3))
            continue
        end
        
        % 下修
%         if (i>=29 & sum(S(i-28:i+1,j)<=K(j)*0.8)>=15) % 任意连续三十个交易日中至少有十五个交易日的收盘价低于当期转股价格的80%
%             fprintf('第%d条路径第%d天发生下修\n',[j,i+1])
%             K(j) = max(mean(S(i-28:i+1,j)),S(i,j)); % 修正后的转股价格应不低于本次股东大会召开日前二十个交易日公司股票交易均价和前一交易日均价之间的较高者
%             index1(j) = i+1;
%         end
        
        % 回售  
        if (i >= T_put - times_stock... % 已到回售起始日
                && sum(S(i-28:i+1,j)<=K(j)*0.7)==30) % 任何连续三十个交易日的收盘价格低于当期转股价格的70%
%             if i+1-index1(j)>=30 % 如果出现转股价格向下修正的情况，则上述“连续三十个交易日”须从转股价格调整之后的第一个交易日起重新计算
%                 fprintf('第%d条路径第%d天发生回售\n',[j,i+1])
                index2 = [index2,j];
                already = times_stock-T_start;  % 可转债已开始天数
                nxcupn2 = T_nxcup-times_stock;  % 距下一付息日天数
                P(2,j) = 100*(1+(already+i+1)/365)*rate(ceil((already+i+1)/365)); % 可转换公司债券持有人按面值加上当期应计利息的价格回售给公司
                n = floor((i-nxcupn2)/365)+1;% 判断拿了多少次利息     
                P(1,j) = P(2,j)/(1+v(ceil(i/365)))^(i/365);
                if n > 0
                    P(1,j) = P(1,j) + sum(100*rate(2:2+n-1)./(1+v(1:1+n-1)).^(nxcupn2/365:n-1+nxcupn2/365)); % 加上已拿利息的折现
                end
%             end
        end
        
        % 转股
        if (i>=29 && sum(S(i-28:i+1,j)>=K(j)*1.3)>=15) % 任何连续三十个交易日中至少十五个交易日的收盘价格不低于当期转股价格的130%（含130%）
%             fprintf('第%d条路径第%d天发生转股\n',[j,i+1])
            index3 = [index3,j];
            nxcupn2 = T_nxcup - times_stock;  % 距下一付息日天数
            P(2,j) = S(i+1,j)*100/K(j);
            n = floor((i-nxcupn2)/365)+1;% 判断拿了多少次利息      
            P(1,j) = P(2,j)/(1+v(ceil(i/365)))^(i/365);
            if n > 0
                P(1,j) = P(1,j) + sum(100*rate(2:2+n-1)./(1+v(1:1+n-1)).^(nxcupn2/365:n-1+nxcupn2/365));
            end
        end
    end
end

for t = 1:N
    if P(2,t)==0 % 到期
        P(1,t) = sum(r(2:5)./(1+v(2:5)).^(2:5)); % 到期前利息折现
        if S(TD+1,t)*100/K(t)>V % 到期转股
            P(1,t) = P(1,t) + S(TD+1,t)*100/K(t)/(1+v(5))^5;
        else % 到期赎回
            index4 = [index4,t];
            P(1,t) = P(1,t) + V/(1+v(5))^5;
        end
    end
end
%% 某条路径股价走势图
S(S == 0) = NaN;
index = randperm(N,1);
figure(),plot(S(:,index),'LineWidth',1.5)
title('股价预测','FontSize',20)
xlabel('天数')
ylabel('股票价格')
day_start = times_stock; % 2019.07.15，可转债买入时间
x = max(find(S(:,index)>0)); % 路径结束时间
day_end = times_stock + x; % 回售/转股/赎回
if ismember(index,index2) % 回售
    text(x,S(x,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' 回售'],['    当前股价 ',num2str(S(x,index))]})
elseif ismember(index,index3) % 提前转股
    text(x,S(x,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' 转股'],['    当前股价 ',num2str(S(x,index))]})
elseif ismember(index,index4) % 赎回
    text(TD+1,S(TD+1,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' 赎回'],['    当前股价 ',num2str(S(x,index))]})
else
    text(TD+1,S(TD+1,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' 到期转股'],['    当前股价 ',num2str(S(x,index))]})
end
text('Units','normalized','Position',[0.01,0.95],'String',['折现2019-07-16可转债价值 ',num2str(P(1,index))],'color','r','fontsize',12)
%% 占比饼图
X = [length(index2),length(index4),length(index3),N-length(index2)-length(index3)-length(index4)];
figure()
labels = {['回售 ',num2str(X(1)/10),'%'],['赎回 ',num2str(X(2)/10),'%'],['转股 ',num2str(X(3)/10),'%'],['到期转股 ',num2str(X(4)/10),'%']};
pie(X,[1,1,1,1],labels)
% title('各情况占比统计','Fontsize',15)
colormap(cool)

fprintf('当前模拟可转债价值：%f\n',mean(P(1,:)))
fprintf('本次 %d 条模拟中 回售 %d 条\n',[N,X(1)])
fprintf('本次 %d 条模拟中 转股 %d 条\n',[N,X(2)])
fprintf('本次 %d 条模拟中 赎回 %d 条\n',[N,X(3)])
fprintf('本次 %d 条模拟中 到期转股 %d 条\n',[N,X(4)])

