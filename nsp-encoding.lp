% TODO
% * ソフト制約の効率的解法
% * 希望シフトのうち，どれがハードでどれかソフトか区別したい
% * デバッグ用に小さなインスタンスを生成したい（難しい）
% - JSJS 後に２連休（独自なので要検討）
% - 土日連休の最大化
% 要問合せ
% - 希望勤務のうち，ハードとソフトな希望を指定してほしい（Ruby roo では色などのスタイルの取得はできない）
%   - 例えは (O) のようにカッコを付けるとソフト，なければハードなど
% - 常に勤務表の長さは28日か？そうでない場合休日の数は8でよいのか？
% - 研修の取り扱い
% - 休日（○）を８回とする制約がそもそも満たせない看護師がいる
%   - No.8 村松さんはすべての日の希望シフトが記述されているが，○が５個しかない -> 産休のためのようだ
%   - 現在は 8 * (28 - /,特) / 28 を四捨五入した値を週休の数としている

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 看護師ごとのシフトの上下限制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 勤務シフト
LB { assigned(N,D) : workable_date(N,D) } UB :- 
    staff(N), working_dates_bounds(N, LB, UB).
% 各看護師 N, 各日 D に勤務シフト S を１つだけ割当
{ assigned(N,D,S) : working_shift(S) } = 1 :- assigned(N,D), date(D).

% 週休シフト
LB { not assigned(N,D) : strict_workable_date(N,D) } UB :- 
    weekly_holiday_bounds(N, LB, UB).

% 祝日シフト
penalty(national_holiday(N, D, S), national_holiday_penalty, national_holiday_priority) :-
    staff_request(N, D, S), national_holiday_shift(S), assigned(N, D).

% ソフト休暇シフト
penalty(soft_holiday(N, D, S), soft_holiday_penalty, soft_holiday_priority) :-
    staff_request(N, D, S), soft_holiday_shift(S), assigned(N, D).

% ハード休暇シフト
:- staff_request(N, D, S), hard_holiday_shift(S), assigned(N, D).

% ビジネスシフト
:- staff_request(N, D, S), business_shift(S), assigned(N, D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 各日 D，各シフト S，各看護師グループ G ごとの人数制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 各日 D，各シフト S，各グループ G に属する看護師数の下限制約
penalty(staff_lb(D, S, G, LB, X), staff_lb_penalty * (LB - X) * (LB - X), staff_lb_priority) :-     
    staff_bounds(G, S, D, LB, UB), X = { assigned(N, D, S) : group(G, N) }, X < LB.
:- hard_staff_lb(G, S, M),
    staff_bounds(G, S, D, LB, UB), not LB - M { assigned(N, D, S) : group(G, N) }.

% 各日 D，各シフト S，各グループ G に属する看護師数の上限制約
penalty(staff_ub(D, S, G, UB, X), staff_ub_penalty * (X - UB) * (X - UB), staff_ub_priority) :-     
    staff_bounds(G, S, D, LB, UB), X = { assigned(N, D, S) : group(G, N) }, UB < X.
:- hard_staff_ub(G, S, M),
    staff_bounds(G, S, D, LB, UB), not { assigned(N, D, S) : group(G, N) } UB + M.

% 各日 D，各シフトグループ SG，各看護師グループ G に属する看護師数の下限制約
penalty(staff_sg_lb(D, SG, G, LB, X), staff_sg_lb_penalty * (LB - X) * (LB - X), staff_sg_lb_priority) :-     
    staff_sg_bounds(G, SG, D, LB, UB), X = { assigned(N, D, S) : group(G, N), shift_group(SG, S) }, X < LB.
:- hard_staff_sg_lb(G, SG, M),
    staff_sg_bounds(G, SG, D, LB, UB), not LB - M { assigned(N, D, S) : group(G, N), shift_group(SG, S) }.

% 各日 D，各シフトグループ SG，各看護師グループ G に属する看護師数の上限制約
penalty(staff_sg_ub(D, SG, G, UB, X), staff_ub_penalty * (X - UB) * (X - UB), staff_ub_priority) :-     
    staff_sg_bounds(G, SG, D, LB, UB), X = { assigned(N, D, S) : group(G, N), shift_group(SG, S) }, UB < X.
:- hard_staff_sg_ub(G, SG, M),
    staff_sg_bounds(G, SG, D, LB, UB), not { assigned(N, D, S) : group(G, N), shift_group(SG, S) } UB + M.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 各日 D，各シフト S，各看護師グループ G ごとの点数制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 各日 D，各シフト S，各グループ G に属する看護師の点数和の下限制約
penalty(point_lb(D, S, G, LB, X), point_lb_penalty * (LB - X) * (LB - X), point_lb_priority) :-     
    point_bounds(G, S, D, LB, UB), X = #sum{ P, N : point(N, P), assigned(N, D, S), group(G, N) }, X < LB.
:- hard_point_lb(G, S, M),
    point_bounds(G, S, D, LB, UB), LB - M > #sum{ P, N : point(N, P), assigned(N, D, S), group(G, N) }.

% 各日 D，各シフト S，各グループ G に属する看護師の点数和の上限制約
penalty(point_ub(D, S, G, UB, X), point_ub_penalty * (X - UB) * (X - UB), point_ub_priority) :-     
    point_bounds(G, S, D, LB, UB), X = #sum{ P, N : point(N, P), assigned(N, D, S), group(G, N) }, UB < X.
:- hard_point_ub(G, S, M),
    point_bounds(G, S, D, LB, UB), #sum{ P, N : point(N, P), assigned(N, D, S), group(G, N) } > UB + M.

% 各日 D，各シフトグループ SG，各看護師グループ G に属する看護師の点数和の下限制約
penalty(point_sg_lb(D, SG, G, LB, X), point_lb_penalty * (LB - X) * (LB - X), point_lb_priority) :-     
    point_sg_bounds(G, SG, D, LB, UB), X = #sum{ P, N : point(N, P), assigned(N, D, S), group(G, N), shift_group(SG, S) }, X < LB.
:- hard_point_sg_lb(G, SG, M),
    point_sg_bounds(G, SG, D, LB, UB), LB - M > #sum{ P, N : point(N, P), assigned(N, D, S), group(G, N), shift_group(SG, S) }.

% 各日 D，各シフトグループ SG，各看護師グループ G に属する看護師の点数和の上限制約
penalty(point_sg_ub(D, SG, G, UB, X), point_ub_penalty * (X - UB) * (X - UB), point_ub_priority) :-     
    point_sg_bounds(G, SG, D, LB, UB), X = #sum{ P, N : point(N, P), assigned(N, D, S), group(G, N), shift_group(SG, S) }, UB < X.
:- hard_point_sg_ub(G, SG, M),
    point_sg_bounds(G, SG, D, LB, UB), #sum{ P, N : point(N, P), assigned(N, D, S), group(G, N), shift_group(SG, S) } > UB + M.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 各看護師の担当するシフト数に関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 各看護師 N，各シフト S の担当回数の下限制約
penalty(shift_lb(N, S, LB, X), shift_lb_penalty * (LB - X), shift_lb_priority) :-
    shift_bounds(N, S, LB, UB), working_shift(S), X = { assigned(N, D, S) : date(D) }, X < LB.
:- hard_shift_lb(N, S, M),
    shift_bounds(N, S, LB, UB), working_shift(S), not LB - M { assigned(N, D, S) : date(D) }.

% 各看護師 N，各シフト S の担当回数の上限制約
penalty(shift_ub(N, S, UB, X), shift_ub_penalty * (X - UB) * (X - UB), shift_ub_priority) :-
    shift_bounds(N, S, LB, UB), working_shift(S), X = { assigned(N, D, S) : date(D) }, UB < X.
:- hard_shift_ub(N, S, M),
    shift_bounds(N, S, LB, UB), working_shift(S), not { assigned(N, D, S) : date(D) } UB + M.    

% 上限が 0 の場合はハード制約とする（割り当てることを想定していないため）
:- shift_bounds(N, S, 0, 0), assigned(N, D, S), not staff_request(N, D, S), date(D).

% 各看護師 N，シフト S1, S2 の担当回数の差分をハード制約化
:- shift_diff_bounds(N, S1, S2, LB, UB), 
   not LB #sum{  1, D : assigned(N, D, S1), date(D) ; 
                -1, D : assigned(N, D, S2), date(D) } UB.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 連続勤務回数に関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% フル勤務の期間
full_work_period(N, BD, ED) :-
    consecutive_work_ub(UB), base_date(BD), ED=BD+UB-1, base_date(ED),
    staff(N), assigned(N, D) : D = BD..ED.
% 連続勤務回数を超えてはならない
:- full_work_period(N, BD, ED), assigned(N, ED+1), date(ED+1).
% 月末のフル連続勤務で末尾に翌日勤務があるシフトをいれない
:- full_work_period(N, BD, ED), last_date(ED), assigned(N, ED, S), consecutive_working_shift(S).

% 基数制約によって表現した場合 
% full_work_period(N, BD, BD+UB-1) :-
%     consecutive_work_ub(UB), base_date(BD), % BD の上限を削減できる ( last_base_date(LD), BD <= LD - UB)
%     staff(N), UB { assigned(N, D) : D = BD..(BD+UB-1) }.  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 週末休暇に関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_weekend_offs(N, X) :-
    staff(N), X = { not assigned(N, D) : date(D, "日"), not assigned(N, D-1) }. % パターン末尾が今月に含まれること

penalty(weekend_off(N, X), weekend_off_penalty, weekend_off_priority) :-
    not ignore_weekend_offs,
    num_weekend_offs(N, X), X < 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 祝日に関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_national_holiday_offs(N, X) :-
    staff(N), X = { not assigned(N, D) : date(D), national_holiday(D), not staff_request(N, D) ;
                    not assigned(N, D) : date(D), national_holiday(D), staff_request(N, D, S), not working_shift(S) }.

penalty(diff_national_holiday_offs(X), national_holiday_off_penalty * X, national_holiday_off_priority) :-
    MIN = #min{ Y : num_national_holiday_offs(N, Y), staff(N) },
    MAX = #max{ Y : num_national_holiday_offs(N, Y), staff(N) },
    X = MAX - MIN,
    X > 0.    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 禁止シフトパターンに関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 当月で○ or ◎の日
regular_holiday(N, D) :- staff(N), date(D), not assigned(N, D), not staff_holiday_request(N, D).
% 翌月で○ or ◎の日
regular_holiday(N, D) :- staff(N), next_date(D), staff_request(N, D, S), regular_holiday_shift(S).

pattern_occured(PID, N, D, D+LEN-1) :-
    pattern(PID, LEN), staff(N), base_date(D),
    assigned(N, D + IDX, S)  : pattern(PID, IDX, S), working_shift(S);                  % S が勤務シフトなら勤務あり
    regular_holiday(N, D + IDX) : pattern(PID, IDX, S), not working_shift(S).           % S が非勤務シフトなら勤務なし

:- forbidden_pattern(PID), pattern_occured(PID, N, BD, ED), date(BD).
:- forbidden_pattern(PID), pattern_occured(PID, N, BD, ED), date(ED).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 前日・翌日可能シフトに関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ある勤務シフトを希望し，それが割り当てられていれば充足
sat_staff_request(N, D) :- staff_request(N, D, S), base_date(D), working_shift(S), assigned(N, D, S).
% ある非勤務シフトを希望し，勤務シフトが割り当てられてなければ充足
sat_staff_request(N, D) :- staff_request(N, D, S), base_date(D), not working_shift(S), not assigned(N, D).
% 前月最終日はすべて充足と仮定
sat_staff_request(N, D) :- staff(N), first_date(D+1).
% ２日連続希望を充足しているかどうか
sat_staff_request(N, D, D+1) :- sat_staff_request(N, D), sat_staff_request(N, D+1).

% 前日に出現不可なシフト
pred_base_shift(S) :- pred_shift(_, S).
penalty(pred_shift(N, D, S), valid_pattern_penalty, valid_pattern_priority) :- 
    pred_base_shift(S), assigned(N, D, S), date(D), 
    not sat_staff_request(N, D-1, D), 
    not 1 { assigned(N, D-1, PS) : pred_shift(PS, S), working_shift(PS) ;
            not assigned(N, D-1) : pred_shift(PS, S), weekly_holiday_shift(PS) } 1.
:- hard_pred_shift(S), 
    pred_base_shift(S), assigned(N, D, S), date(D), 
    not sat_staff_request(N, D-1, D), 
    not 1 { assigned(N, D-1, PS) : pred_shift(PS, S), working_shift(PS) ;
            not assigned(N, D-1) : pred_shift(PS, S), weekly_holiday_shift(PS) } 1.    

% 翌日に出現不可なシフト
succ_base_shift(S) :- succ_shift(S, _).
penalty(succ_shift(N, D, S), valid_pattern_penalty, valid_pattern_priority) :- 
    succ_base_shift(S), assigned(N, D, S), date(D+1),
    not sat_staff_request(N, D, D+1), 
    not 1 { assigned(N, D+1, SS) : succ_shift(S, SS), working_shift(SS) ;
            not assigned(N, D+1) : succ_shift(S, SS), weekly_holiday_shift(SS) } 1.
:- hard_succ_shift(S),
    succ_base_shift(S), assigned(N, D, S), date(D+1),
    not sat_staff_request(N, D, D+1), 
    not 1 { assigned(N, D+1, SS) : succ_shift(S, SS), working_shift(SS) ;
            not assigned(N, D+1) : succ_shift(S, SS), weekly_holiday_shift(SS) } 1.
% 最終日の翌日に希望勤務がある場合
penalty(succ_shift(N, D, S), valid_pattern_penalty, valid_pattern_priority) :- 
    succ_base_shift(S), assigned(N, D, S), last_date(D),
    not sat_staff_request(N, D, D+1), 
    staff_request(N, D+1, REQ),
    not succ_shift(S, REQ).
:- hard_succ_shift(S),
    succ_base_shift(S), assigned(N, D, S), last_date(D),
    not sat_staff_request(N, D, D+1), 
    staff_request(N, D+1, REQ),
    not succ_shift(S, REQ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% パターン割当数の最小・最大値		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

penalty(pattern_lb(N, PID, LB, X), pattern_lb_penalty * (LB - X), pattern_lb_priority) :- 
    staff(N), pattern_lb(PID, LB),
    X = { pattern_occured(PID, N, BD, ED) : date(ED) }, X < LB.  % 今月に終わるパターンの頻度を数える
:- hard_pattern_lb(PID),
    staff(N), pattern_lb(PID, LB),
    not LB { pattern_occured(PID, N, BD, ED) : date(ED) }.  % 今月に終わるパターンの頻度を数える

penalty(pattern_ub(N, PID, UB, X), pattern_ub_penalty * (X - UB) * (X - UB), pattern_ub_priority) :-
    staff(N), pattern_ub(PID, UB),
    X = { pattern_occured(PID, N, BD, ED) : date(ED) }, UB < X.  % 今月に終わるパターンの頻度を数える
:- hard_pattern_ub(PID),
    staff(N), pattern_ub(PID, UB),
    not { pattern_occured(PID, N, BD, ED) : date(ED) } UB.  % 今月に終わるパターンの頻度を数える

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 推奨パターンに関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% JSJS のあとに OO を希望
penalty(jsjsoo(N, ED+1), jsjsoo_penalty, jsjsoo_priority) :- 
    not ignore_jsjsoo,
    pattern_occured("JSJS", N, BD, ED),
    assigned(N, ED+2).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ソフト休暇に関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ソフト休暇の出現期間
soft_holidays_period(N, BD, ED) :-
    staff(N), date(BD), date(ED+1), BD <= ED,
    not staff_request(N, BD-1),
    not staff_request(N, ED+1),
    soft_holiday_date(N, D) : D = BD..ED.  % 前処理（探索なし）なので基礎化しても大きく爆発しない

% ソフト休暇の前後のいずれかには週休を入れる
penalty(additional_holiday(N, BD, ED), additional_holiday_penalty, additional_holiday_priority) :-
    soft_holidays_period(N, BD, ED),
    assigned(N, BD-1), assigned(N, ED+1).
:- hard_additional_holiday(N),
    soft_holidays_period(N, BD, ED),
    assigned(N, BD-1), assigned(N, ED+1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 推奨ペアに関する制約（ペアには同じ夜勤シフトを割り当てる）
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% penalty(night_pair(N1, N2, D), night_pair_penalty, night_pair_priority) :-    
%     recommended_night_pair(N1, N2), night_working_shift(S), 
%     workable_date(N1, D), workable_date(N2, D), 
%     assigned(N2, D, S), not assigned(N1, D, S).

penalty(night_pair(N1, N2, X), night_pair_penalty * (LB - X), night_pair_priority) :-
    recommended_night_pair(N1, N2),
    recommended_night_pair_lb(LB), 
    X = { assigned(N1, D, S) : night_working_shift(S), workable_date(N1, D), workable_date(N2, D), assigned(N2, D, S) },
    X < LB.

% 不一致のシフト日の表示用
unmatch_night_pair(N1, N2, D) :-
    recommended_night_pair(N1, N2), night_working_shift(S), 
    workable_date(N1, D), workable_date(N2, D), 
    assigned(N2, D, S), not assigned(N1, D, S).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 夜勤禁止ペアに関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- forbidden_night_pair(N1, N2), night_working_shift(S), 
    workable_date(N1, D, _), workable_date(N2, D, _),
    assigned(N1, D, S), assigned(N2, D, S).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 希望シフトに関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ある勤務シフトを希望しているのに，別の勤務シフトが割り当てられているとペナルティ
penalty(staff_request(N, D, REQ, RES), staff_request_penalty, staff_request_priority) :- 
    staff_request(N, D, REQ), date(D), working_shift(REQ), assigned(N, D, RES), REQ != RES.
:- hard_staff_work_request(REQ), hard_staff_request(N),
    staff_request(N, D, REQ), date(D), working_shift(REQ), assigned(N, D, RES), REQ != RES.

% ある勤務シフトを希望しているのに，休みが割り当てられているとペナルティ
penalty(staff_request(N, D, REQ, "--"), staff_request_penalty, staff_request_priority) :- 
    staff_request(N, D, REQ), date(D), working_shift(REQ), not assigned(N, D).
:- hard_staff_work_request(REQ), hard_staff_request(N),
    staff_request(N, D, REQ), date(D), working_shift(REQ), not assigned(N, D).

% ある非勤務シフトを希望しているのに，勤務シフトが割り当てられているとペナルティ
penalty(staff_request(N, D, REQ, RES), staff_request_penalty, staff_request_priority) :- 
    staff_request(N, D, REQ), date(D), not working_shift(REQ), assigned(N, D, RES).
:- hard_staff_holiday_request(REQ), hard_staff_request(N),
    staff_request(N, D, REQ), date(D), not working_shift(REQ), assigned(N, D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 看護師ごとのデフォルト割当可能シフト・割当不可シフトに関する制約
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos_def_request(N, D) :- pos_def_request(N, D, S).
:- pos_def_request(N, D), not staff_request(N, D), 
    not 1 { assigned(N, D, S) : pos_def_request(N, D, S), working_shift(S) ;
            not assigned(N, D) : pos_def_request(N, D, S), not working_shift(S) } 1.

:- neg_def_request(N, D, S), not staff_request(N, D), working_shift(S), assigned(N, D, S).
:- neg_def_request(N, D, S), not staff_request(N, D), not working_shift(S), assigned(N, D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 出力用シフト表
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out_assigned(N, D, S) :- assigned(N, D, S).
out_assigned(N, D, S) :- not assigned(N, D), staff_request(N ,D, S), not working_shift(S).
out_assigned(N, D, "○") :- not assigned(N, D), staff_request(N ,D, S), working_shift(S), not national_holiday(D).
out_assigned(N, D, "◎") :- not assigned(N, D), staff_request(N ,D, S), working_shift(S), national_holiday(D).
out_assigned(N, D, "○") :- not assigned(N, D), not staff_request(N ,D), staff(N), date(D), not national_holiday(D).
out_assigned(N, D, "◎") :- not assigned(N, D), not staff_request(N ,D), staff(N), date(D), national_holiday(D).
