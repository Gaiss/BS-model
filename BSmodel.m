clear all
% ���תծ��������磩 2019.7.16--2023.9.25
S0 = 22.59; % 2019.7.15�ɼ�
u = 0.0175; % �޷������� һ�궨��
sigma = 0.3585; % �̶�������
T = 1532; % ��������
TD = round(T*250/365); % ����������
N = 10000; % ģ��·����
K = 22.33*ones(TD+1,N); % ת�ɼ�
V = 106; % ��ؼ�&������
t = 1/250;  % ʱ������������
S = zeros(TD+1,N); % ·��
S(1,:) = S0; 
P = zeros(2,N); % [���ڣ�����]��תծ��ֵ
% p = 0.6; % ���޸���
rate = [0.003,0.005,0.01,0.013,0.015,0.018]; % ����
r = [0.06,0.015,0.013,0.01,0.005,0.003];
v = [0.048504,0.050177,0.050568,0.052024,0.053193,0.053948]; % ������
index1 = zeros(2,N); % [���һ������ʱ�䣬���޴���]
index2 = []; % ����·��
index3 = []; % ת��·��
index4 = []; % ���·��
down_record = []; % ���޼�¼[�ڣ������ڣ��������޺�ת�ɼ�]

for j = 1:N % ��j��ģ��
    for i = 1:TD % ��i��
        if ismember(j,index2) || ismember(j,index3)
            continue
        end       
        S(i+1,j) = S(i,j)*min(max(exp((u-0.5*sigma^2)*t + sigma*sqrt(t)*randn()),0.9),1.1); % B-Sģ�ͣ�����10%��ͣ��ͣ
        
        % ת��
        if i>=29 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*1.3>=0)>=15 % �κ�������ʮ��������������ʮ��������յ����̼۸񲻵��ڵ���ת�ɼ۸��130%����130%��
%             fprintf('��%d��·����%d�췢��ת��\n',[j,i+1])
            index3 = [index3,j];
            P(2,j) = S(i+1,j)*100/K(i+1,j);
            n = floor((i*365/250-72)/365)+1;% �ж����˶��ٴ���Ϣ
            P(1,j) = P(2,j)/(1+v(ceil(i/250)))^(i/250);
            if n
                P(1,j) = P(1,j) + sum(100*rate(2:2+n-1)./(1+v(1:1+n-1)).^(72/365:n-1+72/365));
            end
        end
        
        % ����
%         if i>=29 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*0.7<=0)==30 % ����������ʮ����������������ʮ��������յ����̼۵��ڵ���ת�ɼ۸��80%
%             if rand() > 0.4
% %                 if index1(j)<2
% %                     fprintf('��%d��·����%d�췢������\n',[j,i+1])
%                     K(i+1:end,j) = max(mean(S(i-18:i+1,j)),S(i+1,j)); % �������ת�ɼ۸�Ӧ�����ڱ��ιɶ�����ٿ���ǰ��ʮ�������չ�˾��Ʊ���׾��ۺ�ǰһ�����վ���֮��Ľϸ���
%                     index1(:,j) = [i+1;index1(2,j)+1];
%                     down_record = [down_record;j,i+1,K(i+1,j)];
% %                 end
%             end
%         end
        
        % ����  
        if i>=802 && sum(S(i-28:i+1,j)-K(i-28:i+1,j)*0.7<=0)==30 % �κ�������ʮ�������յ����̼۸���ڵ���ת�ɼ۸��70%
%             if i+1-index1(1,j)>=30 % �������ת�ɼ۸������������������������������ʮ�������ա����ת�ɼ۸����֮��ĵ�һ�������������¼���
%                 fprintf('��%d��·����%d�췢������\n',[j,i+1])
                index2 = [index2,j];
                P(2,j) = 100*(1+rate(ceil((473+i*365/250+1)/365))); % ��ת����˾ծȯ�����˰���ֵ���ϵ���Ӧ����Ϣ�ļ۸���۸���˾
                n = floor((i-72)/365)+1;% �ж����˶��ٴ���Ϣ
                P(1,j) = P(2,j)/(1+v(ceil(i/250)))^(i/250);
                if n
                    P(1,j) = P(1,j) + sum(100*rate(2:2+n-1)./(1+v(1:1+n-1)).^(72/365:n-1+72/365)); % ����������Ϣ������
                end
%             end
        end
        
    end
end

for s = 1:N
    if P(2,s)==0 % ����
        P(1,s) = sum(rate(2:5)./(1+v(2:5)).^(72/365:3+72/365)); % ����ǰ��Ϣ����
        if S(TD+1,s)*100/K(TD+1,s)>V % ����ת��
            P(1,s) = P(1,s) + S(TD+1,s)*100/K(TD+1,s)/(1+v(5))^(T/365);
        else % �������
            index4 = [index4,s];
            P(1,s) = P(1,s) + V/(1+v(5))^(T/365);
        end
    end
end
%% ·��ͼ
S(S == 0) = NaN;
figure()
hold on
% for draw = 1:3
index = randperm(N,1);
plot(S(:,index),'LineWidth',1.5)
title('�ɼ�Ԥ��','FontSize',20)
xlabel('����')
ylabel('��Ʊ�۸�')
plot([TD TD], get(gca, 'YLim'), '--r', 'LineWidth', 1) 
plot([45 45], get(gca, 'YLim'), ':g', 'LineWidth', 1)
plot([295 295], get(gca, 'YLim'), ':g', 'LineWidth', 1)
plot([545 545], get(gca, 'YLim'), ':g', 'LineWidth', 1)
plot([795 795], get(gca, 'YLim'), ':g', 'LineWidth', 1)
day_start = datetime('2019/7/15'); % 2019.07.15����תծ����ʱ��
x = max(find(S(:,index)>0)); % ·������ʱ��
day_end = datetime('2019/7/15')+caldays(x); % ����/ת��/���
if index1(2,index) % ����
    get_down_record = down_record(down_record(:,1)==index,:);
    for m = 1:size(get_down_record,1)
        text(get_down_record(m,2),S(get_down_record(m,2),index),{['\leftarrow ',datestr(day_start+get_down_record(m,2),'yyyy-mm-dd'),' ����'],['    ��ǰ�ɼ� ',num2str(S(get_down_record(m,2),index),'%.2f')],['    ����ת�ɼ� ',num2str(get_down_record(m,3),'%.2f')]})
    end
end
if ismember(index,index2) % ����
    text(x,S(x,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' ����'],['    ��ǰ�ɼ� ',num2str(S(x,index),'%.2f')]})
elseif ismember(index,index3) % ת��
    text(x,S(x,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' ת��'],['    ��ǰ�ɼ� ',num2str(S(x,index),'%.2f')]})
elseif ismember(index,index4) % ���
    text(TD+1,S(TD+1,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' ���'],['    ��ǰ�ɼ� ',num2str(S(x,index),'%.2f')]})
else % ����ת��
    text(TD+1,S(TD+1,index),{['\leftarrow ',datestr(day_end,'yyyy-mm-dd'),' ����ת��'],['    ��ǰ�ɼ� ',num2str(S(x,index),'%.2f')]})
end
% end
% text('Units','normalized','Position',[0.01,0.95],'String',['����2019-07-16��תծ��ֵ ',num2str(P(1,index))],'color','r','fontsize',12)
hold off
%% ռ�ȱ�ͼ
X = [length(index2),length(index3),length(index4),N-length(index2)-length(index3)-length(index4)];
figure()
label1 = {['���� ',num2str(X(1)/100),'%'],['ת�� ',num2str(X(2)/100),'%'],['��� ',num2str(X(3)/100),'%'],['����ת�� ',num2str(X(4)/100),'%']};
pie(X,[1,1,1,1],label1)
% title('�����ռ��ͳ��','Fontsize',15)
colormap(cool)
%% ���޴�����ͼ
% h = hist(index1(2,:),max(unique(index1(2,:)))); % ���޴���ͳ��
% figure()
% labels2 = cellstr(string(0:max(unique(index1(2,:)))-1)+'��');
% pie(h,labels2)
% title('���޴���ͳ��')
%% ���չɼ۷ֲ�ͼ
% ind = sub2ind(size(S),sum(S>0),1:N);
% figure(),histfit(log(S(ind)),20)

fprintf('2019-07-15 ģ���תծ��ֵ��%.2f\n',mean(P(1,:)))
fprintf('���� %d ��ģ���� ��ǰ���� %d ��\n',[N,X(1)])
fprintf('���� %d ��ģ���� ��ǰת�� %d ��\n',[N,X(2)])
fprintf('���� %d ��ģ���� ������� %d ��\n',[N,X(3)])
fprintf('���� %d ��ģ���� ����ת�� %d ��\n',[N,X(4)])