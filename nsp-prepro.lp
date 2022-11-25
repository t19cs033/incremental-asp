%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% シフトの種類
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 勤務シフト
working_shift("日";"N";"J";"S";"★";"☆";"P").
% 夜勤シフト
night_working_shift("J";"S";"★";"☆").
% 休日シフト
weekly_holiday_shift("○").
% 祝日シフト
national_holiday_shift("◎"). 
% ソフト休暇シフト
soft_holiday_shift("年";"健").
% ハード休暇シフト
hard_holiday_shift("特";"/";"研").
% ビジネスシフト
%business_shift("研").
% 休日・祝日シフト
regular_holiday_shift(S) :- weekly_holiday_shift(S).
regular_holiday_shift(S) :- national_holiday_shift(S).
% 休暇シフト
requested_holiday_shift(S) :- soft_holiday_shift(S).
requested_holiday_shift(S) :- hard_holiday_shift(S).

% シフト名のチェック
unknown_shift(S) :- staff_request(N, D, S), not shift(S).

% 作成するシフト表の横幅（日数）
table_width(X) :- X = { date(_,_) }.
% 週休の数
default_weekly_holidays(8).
% 祝日の数
default_national_holidays(X) :- X = { national_holiday(D,_) }.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 各看護師・各シフトごとの上限・下限の算出
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 看護師ごとの勤務日数の上下限
working_dates_bounds(N, LB, UB) :-
    staff(N),
    table_width(WIDTH),
    %num_weekly_holiday_dates(N, WH),    % 幅固定
    weekly_holiday_bounds(N, WH_LB, WH_UB),
    num_national_holiday_dates(N, NH),
    num_soft_holiday_dates(N, SH),      
    num_hard_holiday_dates(N, HH),      % 幅固定
    num_business_dates(N, B),           % 幅固定
    UB = WIDTH - WH_LB - HH - B,
    LB = WIDTH - WH_UB - HH - B - NH - SH.
    % UB = WIDTH - WH - HH - B,
    % LB = WIDTH - WH - HH - B - NH - SH.

% 看護師ごとの週休の数
num_weekly_holiday_dates(N, WH) :-
    staff(N), table_width(WIDTH), num_hard_holiday_dates(N, HH),
    default_weekly_holidays(DWH),
    WH = @num_weekly_holidays(WIDTH, HH, DWH).
weekly_holiday_bounds(N, LB, UB) :-
    staff(N), table_width(WIDTH), num_hard_holiday_dates(N, HH),
    default_weekly_holidays(DWH),
    LB = @weekly_holidays_lb(WIDTH, HH, DWH),
    UB = @weekly_holidays_ub(WIDTH, HH, DWH).

% 看護師ごとの祝日の数
national_holiday_date(N, D, W) :- 
    staff(N), date(D, W), national_holiday(D, W), 
    not soft_holiday_date(N, D, W), not hard_holiday_date(N, D, W).
num_national_holiday_dates(N, X) :-
    staff(N), X = { national_holiday_date(N, D, W) }.

% 看護師ごとのソフト休暇シフトの数
soft_holiday_date(N, D, W) :- 
    staff(N), date(D, W), staff_request(N, D, S), soft_holiday_shift(S).
num_soft_holiday_dates(N, X) :-
    staff(N), X = { soft_holiday_date(N, D, W) }.

% 看護師ごとのハード休暇シフトの数
hard_holiday_date(N, D, W) :- 
    staff(N), date(D, W), staff_request(N, D, S), hard_holiday_shift(S).
num_hard_holiday_dates(N, X) :-
    staff(N), X = { hard_holiday_date(N, D, W) }.

% 看護師ごとのビジネスシフトの数
business_date(N, D, W) :- 
    staff(N), date(D, W), staff_request(N, D, S), business_shift(S).
num_business_dates(N, X) :-
    staff(N), X = { business_date(N, D, W) }.

% 勤務シフトを割り当て可能な日
workable_date(N, D, W) :-
    staff(N), date(D, W), not hard_holiday_date(N, D, W), not business_date(N, D, W).

% 確実に勤務シフトを割り当て可能な日（workable から soft_holiday と national_holiday を除いたもの）
strict_workable_date(N, D, W) :-
    staff(N), workable_date(N, D, W), not soft_holiday_date(N, D, W), not national_holiday_date(N, D, W).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 曜日に関する制約を日付に展開
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: もともと ICU の人数制約を緩和するために導入しているが正しいか？
% 前日可能シフトを１つだけ持つシフト S （月末に PS が k 個あれば初日も k 個に制限する必要がある）
uniq_pred_shift(PS, S) :- pred_shift(PS, S), not pred_shift(QS, S) : shift(QS), QS != PS.
uniq_pred_shift(S) :- uniq_pred_shift(_, S).

% グループ G が先月末に PS を割り当てている回数 X 
% PS の後続シフトは X 回しか割り当てられない（例えば S など）
last_day_shifts(G, PS, X) :- 
    uniq_pred_shift(PS, _), first_date(D+1), group(G), X = { assigned(N, D, PS) : group(G, N) }.

%% 人数
% 初日以外
staff_bounds(G, S, D, LB, UB) :-
    date(D, W), not first_date(D), not national_holiday(D), staff_dweek_bounds(G, S, W, LB, UB).
staff_bounds(G, S, D, LB, UB) :-
    date(D, W), not first_date(D), national_holiday(D), staff_dweek_bounds(G, S, "祝日", LB, UB).
% 初日＆ unique な前日シフトなし
staff_bounds(G, S, D, LB, UB) :-
    date(D, W), first_date(D), not uniq_pred_shift(S), not national_holiday(D), staff_dweek_bounds(G, S, W, LB, UB).
staff_bounds(G, S, D, LB, UB) :-
    date(D, W), first_date(D), not uniq_pred_shift(S), national_holiday(D), staff_dweek_bounds(G, S, "祝日", LB, UB).
% 初日＆ unique な前日シフトあり
staff_bounds(G, S, D, X, X) :-
    date(D, W), first_date(D), uniq_pred_shift(PS, S), last_day_shifts(G, PS, X), staff_dweek_bounds(G, S, _, _, _).

staff_sg_bounds(G, SG, D, LB, UB) :-
    date(D, W), not national_holiday(D), staff_sg_dweek_bounds(G, SG, W, LB, UB).
staff_sg_bounds(G, SG, D, LB, UB) :-
    date(D, W), national_holiday(D), staff_sg_dweek_bounds(G, SG, "祝日", LB, UB).

%% 点数
% 初日以外
point_bounds(G, S, D, LB, UB) :-
    date(D, W), not first_date(D), not national_holiday(D), point_dweek_bounds(G, S, W, LB, UB).
point_bounds(G, S, D, LB, UB) :-
    date(D, W), not first_date(D), national_holiday(D), point_dweek_bounds(G, S, "祝日", LB, UB).
% 初日＆ unique な前日シフトなし
point_bounds(G, S, D, LB, UB) :-
    date(D, W), first_date(D), not uniq_pred_shift(S), not national_holiday(D), point_dweek_bounds(G, S, W, LB, UB).
point_bounds(G, S, D, LB, UB) :-
    date(D, W), first_date(D), not uniq_pred_shift(S), national_holiday(D), point_dweek_bounds(G, S, "祝日", LB, UB).
% 初日＆ unique な前日シフトあり
point_bounds(G, S, D, X, X) :-
    date(D, W), first_date(D), uniq_pred_shift(PS, S), last_day_shifts(G, PS, X), point_dweek_bounds(G, S, _, _, _).

point_sg_bounds(G, SG, D, LB, UB) :-
    date(D, W), not national_holiday(D), point_sg_dweek_bounds(G, SG, W, LB, UB).
point_sg_bounds(G, SG, D, LB, UB) :-
    date(D, W), national_holiday(D), point_sg_dweek_bounds(G, SG, "祝日", LB, UB).

pos_def_request(N, D, S) :- 
    pos_shift(N, W, S), date(D, W), not national_holiday(D).
pos_def_request(N, D, S) :-
    pos_shift(N, "祝", S), date(D), national_holiday(D).
neg_def_request(N, D, S) :- 
    neg_shift(N, W, S), date(D, W), not national_holiday(D).
neg_def_request(N, D, S) :-
    neg_shift(N, "祝", S), date(D), national_holiday(D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 翌日勤務シフトがあるシフト
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
consecutive_working_shift(S) :-
    succ_shift(S, _), working_shift(NS) : succ_shift(S, NS).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 簡略形の定義
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 曜日なし日付の定義
base_date(D) :- base_date(D, W).
prev_date(D) :- prev_date(D, W).
date(D) :- date(D, W).
next_date(D) :- next_date(D, W).
national_holiday(D) :- national_holiday(D, W).
workable_date(N, D) :- workable_date(N, D, W).
strict_workable_date(N, D) :- strict_workable_date(N, D, W).
hard_holiday_date(N, D) :- hard_holiday_date(N, D, W).
soft_holiday_date(N, D) :- soft_holiday_date(N, D, W).

% 作成するシフト表の開始日と最終日
first_date(X) :- X = #min { D : date(D, _) }.
last_date(X)  :- X = #max { D : date(D, _) }.

% スタッフ ID, 点数
staff(ID) :- staff(ID, _,  _, _, _).
point(ID, P) :- staff(ID,  _, _, _, P).

% スタッフの希望シフトがある日
staff_request(N, D) :- staff_request(N, D, _).
% スタッフの希望休暇シフトがある日
staff_holiday_request(N, D) :- staff_request(N, D, S), requested_holiday_shift(S).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 前月・翌月勤務の前処理
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 前月勤務表に対して，working shift ならば assigned/2 を定義
assigned(N, D) :- prev_date(D), assigned(N, D, S), working_shift(S).
% 翌月勤務シフト希望があれば assigned/3, assigned/2 を定義
assigned(N, D, S) :- next_date(D), staff_request(N, D, S), working_shift(S).
assigned(N, D) :- next_date(D), assigned(N, D, S).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% utilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#script (python)
import clingo
import math

N = clingo.Number

def num_weekly_holidays(width, hh, dwh):
    width = width.number
    hh    = hh.number
    dwh   = dwh.number
    return N(round(float(width - hh) / float(width) * dwh))

def weekly_holidays_lb(width, hh, dwh):
    width = width.number
    hh    = hh.number
    dwh   = dwh.number
    return N(math.floor(float(width - hh) / float(width) * dwh))

def weekly_holidays_ub(width, hh, dwh):
    width = width.number
    hh    = hh.number
    dwh   = dwh.number
    return N(math.ceil(float(width - hh) / float(width) * dwh))

#end.

% #show num_target_dates/1.
% #show num_holidays/1.
% #show num_national_holidays/1.