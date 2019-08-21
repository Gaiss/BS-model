clear all
discount = [0.032591,0.033751,0.035340,0.035999,0.036493,0.037185;  % ������
    0.046304,0.047977,0.048168,0.049424,0.050393,0.050948;
    0.047304,0.048977,0.049168,0.050524,0.051493,0.052248;
    0.048504,0.050177,0.050568,0.052024,0.053193,0.053948;
    0.050704,0.052377,0.053368,0.054824,0.055993,0.056948;
    0.059504,0.061377,0.064268,0.066624,0.067793,0.069248];
rank = {'�޷���','AAA','AAA-','AA+','AA','AA-'}; % ծȯ����
%% ���תծ 2019.7.16--2023.9.25
% w = windmatlab; % wind�ӿ�
% ��ȡ2019.7.15�������� �ɼۡ��̶�������
% [data_stock,~,~,times_stock,~,~] = w.wsd('002271.SZ','close,annualstdevr_24m','2019-07-15','2019-07-15');
% ��ȡ2019.7.15���תծ�� �����ա������ա����ۿ�ʼ�ա�����ծ��������ת�ɼۡ���һ��Ϣ��
% [data_bond,~,~,times_bond,~,~] = w.wsd('128016.SZ','maturitydate,clause_conversion_2_swapsharestartdate,clause_putoption_conditionalputbackstartenddate,amount,convprice,nxcupn','2019-07-15','2019-07-15');
data_stock = [22.59,35.85];
times_stock = 737621;
data_bond = {'2023/9/25','2018/3/29','2021/9/25','AA+',22.33,'2019/9/25'};
T_end = datenum(cell2mat(data_bond(1))); % ����
T_start = datenum(cell2mat(data_bond(2))); % ����
T_put = datenum(cell2mat(data_bond(3))); % ����
T_nxcup = datenum(cell2mat(data_bond(6))); % ��һ��Ϣ��

S0 = data_stock(1); % 2019.7.15�ɼ�
u = 0.0175; % �޷������� һ�궨��
sigma = data_stock(2)/100; % �̶�������
T = datenum(cell2mat(data_bond(1)))-times_stock-1; % ��������
TD = round(T*250/365); % ���㽻����
N = 1000; % ģ��·����
K = cell2mat(data_bond(5))*ones(1,N); % ת�ɼ�
V = 106; % ��ؼ�&������
t = 1/250;  % ʱ������������
S = zeros(TD+1,N); % ·��
S(1,:) = S0; 
P = zeros(2,N); % [���ڣ�����]��תծ��ֵ
% p = 0.6; % ���޸���
rate = [0.003,0.005,0.01,0.013,0.015,0.018]; % ����
r = [0.06,0.015,0.013,0.01,0.005,0.003];
v = discount(strcmp(rank,cell2mat(data_bond(4))),:); % ������
index1 = zeros(1,N); % ����ʱ��
index2 = []; % ����·��
index3 = []; % ת��·��
index4 = []; % ���·��

for i = 1:TD % ��i��
    for j = 1:N % ��j��ģ��
        
        S(i+1,j) = S(i,j)*min(max(exp((u-0.5*sigma^2)*t + sigma*sqrt(t)*randn()),0.9),1.1); % B-Sģ�ͣ�����10%��ͣ��ͣ
        if (ismember(j,index2) || ismember(j,index3))
            continue
        end
        
        % ����
%         if (i>=29 & sum(S(i-28:i+1,j)<=K(j)*0.8)>=15) % ����������ʮ����������������ʮ��������յ����̼۵��ڵ���ת�ɼ۸��80%
%             fprintf('��%d��·����%d�췢������\n',[j,i+1])
%             K(j) = max(mean(S(i-28:i+1,j)),S(i,j)); % �������ת�ɼ۸�Ӧ�����ڱ��ιɶ�����ٿ���ǰ��ʮ�������չ�˾��Ʊ���׾��ۺ�ǰһ�����վ���֮��Ľϸ���
%             index1(j) = i+1;
%         end
        
        % ����  
        if (i >= T_put - times_stock... % �ѵ�������ʼ��
                && sum(S(i-28:i+1,j)<=K(j)*0.7)==30) % �κ�������ʮ�������յ����̼۸���ڵ���ת�ɼ۸��70%
%             if i+1-index1(j)>=30 % �������ת�ɼ۸������������������������������ʮ�������ա����ת�ɼ۸����֮��ĵ�һ�������������¼���
%                 fprintf('��%d��·����%d�췢������\n',[j,i+1])
                index2 = [index2,j];
                already = times_stock-T_start;  % ��תծ�ѿ�ʼ����
                nxcupn2 = T_nxcup-times_stock;  % ����һ��Ϣ������
                P(2,j) = 100*(1+(already+i+1)/365)*rate(ceil((already+i+1)/365)); % ��ת����˾ծȯ�����˰���ֵ���ϵ���Ӧ����Ϣ�ļ۸���۸���˾
                n = floor((i-nxcupn2)/365)+1;% �ж����˶��ٴ���Ϣ     
                P(1,j) = P(2,j)/(1+v(ceil(i/365)))^(i/365);
                if n > 0
                    P(1,j) = P(1,j) + sum(100*rate(2:2+n-1)./(1+v(1:1+n-1)).^(nxcupn2/365:n-1+nxcupn2/365)); % ����������Ϣ������
                end
%             end
        end
        
        % ת��
        if (i>=29 && sum(S(i-28:i+1,j)>=K(j)*1.3)>=15) % �κ�������ʮ��������������ʮ��������յ����̼۸񲻵��ڵ���ת�ɼ۸��130%����130%��
%             fprintf('��%d��·����%d�췢��ת��\n',[j,i+1])
            index3 = [index3,j];
            nxcupn2 = T_nxcup - times_stock;  % ����һ��Ϣ������
            P(2,j) = S(i+1,j)*100/K(j);
            n = floor((i-nxcupn2)/365)+1;% �ж����˶��ٴ���Ϣ      
            P(1,j) = P(2,j)/(1+v(ceil(i/365)))^(i/365);
            if n > 0
                P(1,j) = P(1,j) + sum(100*rate(2:2+n-1)./(1+v(1:1+n-1)).^(nxcupn2/365:n-1+nxcupn2/365));
            end
        end
    end
end

for t = 1:N
    if P(2,t)==0 % ����
        P(1,t) = sum(r(2:5)./(1+v(2:5)).^(2:5)); % ����ǰ��Ϣ����
        if S(TD+1,t)*100/K(t)>V % ����ת��
            P(1,t) = P(1,t) + S(TD+1,t)*100/K(t)/(1+v(5))^5;
        else % �������
            index4 = [index4,t];
            P(1,t) = P(1,t) + V/(1+v(5))^5;
        end
    end
end
%% ĳ��·���ɼ�����ͼ
S(S == 0) = NaN;
index = randperm(N,1);
figure(),plot(S(:,index),'LineWidth',1.5)
title('�ɼ�Ԥ��','FontSize',20)
xlabel('����')
ylabel('��Ʊ�۸�')
day_start = times_stock; % 2019.07.15����תծ����ʱ��
x = max(find(S(:,index)>0)); % ·������ʱ��
day_end = times_stock + x; % ����/ת��/���
if ismember(index,index2) % ����
    text(x,S(x,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' ����'],['    ��ǰ�ɼ� ',num2str(S(x,index))]})
elseif ismember(index,index3) % ��ǰת��
    text(x,S(x,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' ת��'],['    ��ǰ�ɼ� ',num2str(S(x,index))]})
elseif ismember(index,index4) % ���
    text(TD+1,S(TD+1,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' ���'],['    ��ǰ�ɼ� ',num2str(S(x,index))]})
else
    text(TD+1,S(TD+1,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' ����ת��'],['    ��ǰ�ɼ� ',num2str(S(x,index))]})
end
text('Units','normalized','Position',[0.01,0.95],'String',['����2019-07-16��תծ��ֵ ',num2str(P(1,index))],'color','r','fontsize',12)
%% ռ�ȱ�ͼ
X = [length(index2),length(index4),length(index3),N-length(index2)-length(index3)-length(index4)];
figure()
labels = {['���� ',num2str(X(1)/10),'%'],['��� ',num2str(X(2)/10),'%'],['ת�� ',num2str(X(3)/10),'%'],['����ת�� ',num2str(X(4)/10),'%']};
pie(X,[1,1,1,1],labels)
% title('�����ռ��ͳ��','Fontsize',15)
colormap(cool)

fprintf('��ǰģ���תծ��ֵ��%f\n',mean(P(1,:)))
fprintf('���� %d ��ģ���� ���� %d ��\n',[N,X(1)])
fprintf('���� %d ��ģ���� ת�� %d ��\n',[N,X(2)])
fprintf('���� %d ��ģ���� ��� %d ��\n',[N,X(3)])
fprintf('���� %d ��ģ���� ����ת�� %d ��\n',[N,X(4)])

