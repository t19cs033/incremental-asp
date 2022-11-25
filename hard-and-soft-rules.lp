%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4N 独自の設定
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2022-09-18 のシフト表作成
% (1) シフト希望なし，縦方向制約・横方向制約をソフト化することで充足できることを確認
% (2) シフト希望あり，縦方向制約・横方向制約をソフト化だと充足不能
% (3) 充足不能なシフト希望は以下の２つ：
%     - staff_request(14,280,"日","J")
%       - 原因不明．看護師14の希望勤務は３回のみ．縦横ソフトなので割り当てられて良いはず
%       - staff_lb_priority のほうが高いことが原因．シフト希望の priority を 6 に設定
%     - staff_request(2,271,"日","--")
%       - 週休８日だが，看護師２はデフォルトで平日が"日"である．
%         しかし土曜日に夜勤を１回希望しているため，７回しか休日がなく，そのせいでシフト希望日に○が入っている
%       - 看護師２の平日シフトを "日,○" に変更
% (4) 縦方向制約・横方向制約をソフトにしたたま最適解の求解成功（30秒程度）
%     - まだ点数制約を加えていない
% (5) 点数制約を符号化しても最適解が求解可能（130秒程度）
% (6) 祝日の休暇数にばらつき（３回の看護師と０回の看護師）があったため，祝日休暇数の差を減らすソフト制約を追加
% (7) 生成した勤務表 (v1) に対するコメントを受けて，以下を修正
%     - 新人グループ２の夜勤上限を２名から１名に変更
%     - 夜勤グループの上限を５名から４名に変更
%     - 4n-rules にて，新人グループ２が JSJS を割り当てないようにハード制約を追加
%     - 夜勤グループの上限違反を抑えるため，priority を 2 から 5 に変更（それでも違反は解消せず）

% 2022-10-16 のシフト表作成
% (1) 先月の設定では UNSAT
% (2) 縦方向制約の下限をソフト化（すべてソフト）にして 64 threads で最適値の求解に成功
% (3) 師長のコメントを受けて看護師７の NJS の上限２をハード制約化

% 2022-11-13
%*
    (1) 先月の設定で解の導出可能
    (2) 16番は必ず2,4,5,6,7番のうち1人と一緒にするとのことで制約を追加
    (3) 推奨ペアが月2回との記述があったので4→2に変更
*%
%---------------------------------------------------------------------
% 各日 D，各シフト S，各グループ G に属する看護師数の制約
%---------------------------------------------------------------------

% 下限
%hard_staff_lb(G, S, 0) :- group(G), G != "中堅グループ", working_shift(S).
%hard_staff_sg_lb(G, SG, 0) :- staff_sg_bounds(G, SG, _, _, _).

% 全員と夜勤の下限は死守
hard_staff_lb("全員", S, 0) :- working_shift(S).
hard_staff_lb("全員", S, 0) :- night_working_shift(S).
hard_shift_lb(2, ("★";"☆"), 0).
%hard_staff_sg_lb("夜勤グループ", SG, 0) :- staff_sg_bounds("夜勤グループ", SG, _,  _, _).

% その他は -2 まで認める
%hard_staff_lb(G, S, 2) :- group(G), working_shift(S).
%hard_staff_sg_lb(G, SG, 2) :- staff_sg_bounds(G, SG, _, _, _).
%hard_staff_lb(G, "P", 0) :- group(G). 
% 上限
hard_staff_ub(G, S, 0) :- group(G), working_shift(S).
hard_staff_sg_ub(G, SG, 0) :- staff_sg_bounds(G, SG, _, _).
%hard_staff_ub("師長・副師長グループ", S, 0) :- working_shift(S).
%hard_staff_ub("熟練Aグループ", "日", 1).
% hard_staff_ub(G, "P", 0) :- group(G).
% %hard_staff_sg_ub("夜勤グループ", SG, 0) :- staff_sg_bounds("夜勤グループ", SG, _,  _, _).
% hard_staff_ub("新人グループ", "J", 0).
% hard_staff_ub("新人グループ", "S", 0).

%hard_staff_lb("師長・副師長グループ","日",0).

%*
insufficient_exports_date(D) :-
    date(D), 
    X = { assigned(N1, D, "J") : group("新人グループ", N1) },
    Y = { assigned(N2, D, "J") : group("夜勤グループ", N2) ;
          assigned(N3, D, "★") : group("夜勤グループ", N3) },
    2 * X >= Y.
penalty(insufficient_exports_dates(X), X, 4) :-
    X = { insufficient_exports_date(D) : date(D) }.
*%
%---------------------------------------------------------------------
% 各看護師 N，各シフト S の担当回数の制約
%---------------------------------------------------------------------

% 下限
%hard_shift_lb(N, "日", 0) :- staff(N).
% 上限
hard_shift_ub(N, ("N";"J";"S"), 0) :- staff(N).

% 師長から看護師７の NJS は希望勤務のみとの指摘を受けて，上限２をハード制約化（希望勤務が２回）
%hard_shift_ub(7, ("N";"J";"S"), 0).
% 師長から看護師５も NJS をハードにしたいという要求あり
%hard_shift_ub(5, ("N";"J";"S"), 0).

%---------------------------------------------------------------------
% 前日・翌日可能シフトに関する制約
%---------------------------------------------------------------------

% 前日に出現不可なシフトはハード制約にする
hard_pred_shift("S";"☆").
% 翌日に出現不可なシフトはハード制約にする
hard_succ_shift("S";"J";"★";"☆").

%---------------------------------------------------------------------
% 希望シフトに関する制約
%---------------------------------------------------------------------

hard_staff_work_request(S) :- working_shift(S).
hard_staff_holiday_request("健";"年";"○";"◎").
hard_staff_request(N) :- staff(N).

%---------------------------------------------------------------------
% パターン割当数の最小・最大値		
%---------------------------------------------------------------------

hard_pattern_ub("JSJS").
hard_pattern_ub("N日").
hard_pattern_ub("P日").
hard_pattern_ub("PN").
hard_pattern_ub("PP").
%*
% 2022-09-03 新人グループ２（１年生）の連続夜勤（JSJS）は避ける
:- staff(N), group("新人グループ２", N), 
    1 { pattern_occured("JSJS", N, BD, ED) : date(ED) }.  % 今月に終わるパターンの頻度を数える
*%
%hard_pattern_lb("○○").
%---------------------------------------------------------------------
% 夜勤推奨ペア
%---------------------------------------------------------------------
recommended_night_pair_lb(2).  % 月に2回程度

%---------------------------------------------------------------------
% 夜勤必須ペア
%---------------------------------------------------------------------

:-  required_night_pair(N1, N2, D) , night_working_shift(S), 
    workable_date(N1, D, _), workable_date(N2, D, _),
    assigned(N1, D, S), not assigned(N2, D, S).

need_staffs(2).
need_staffs(4).
need_staffs(5).
need_staffs(6).
need_staffs(7).

%スタッフ16はneed_staffsのうち1人必ず夜勤が一緒になる
{required_night_pair(16, N2 ,D) : need_staffs(N2)}  >= 1 
:- workable_date(16, D ,_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ソフト制約の優先度と重み
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 各看護師の祝日シフト違反
#const national_holiday_penalty = 1.
#const national_holiday_priority = 4.

% 各看護師のソフト休暇シフト違反
#const soft_holiday_penalty = 1.
#const soft_holiday_priority = 4.

% 各日 D，各シフト S，各グループ G ごとの人数制約違反
#const staff_lb_penalty = 1.
#const staff_ub_penalty = 1.
#const staff_lb_priority = 5.
#const staff_ub_priority = 5.

% 各日 D，各シフト S，各グループ G ごとの点数制約違反
#const point_lb_penalty = 1.
#const point_ub_penalty = 1.
#const point_lb_priority = 5.
#const point_ub_priority = 2.

% 各看護師の担当するシフト数に関する制約違反
#const shift_lb_penalty = 1.
#const shift_ub_penalty = 1.
#const shift_lb_priority = 1.
#const shift_ub_priority = 2.

% 推奨パターン違反
#const valid_pattern_penalty = 2.
#const valid_pattern_priority = 2.

% JSJSOO パターン違反
#const jsjsoo_penalty = 1.
#const jsjsoo_priority = 3.

% パターンの出現回数制約違反
#const pattern_lb_penalty = 1.
#const pattern_ub_penalty = 1.
#const pattern_lb_priority = 1.
#const pattern_ub_priority = 3.

% 夜勤推奨ペアの違反
#const night_pair_penalty = 1.
#const night_pair_priority = 0.

% 看護師の希望シフト違反
#const staff_request_penalty = 1.
#const staff_request_priority = 6.

% 各看護師の週末休日数に関する制約違反
#const weekend_off_penalty = 1.
#const weekend_off_priority = 3.

% 各看護師の祝日休暇数に関する制約違反
#const national_holiday_off_penalty = 1.
#const national_holiday_off_priority = 5.

% 各看護師のソフト休暇前後の週休制約違反
#const additional_holiday_penalty = 1.
#const additional_holiday_priority = 4.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 目的関数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ペナルティの総和を最小化
#minimize { P@PRIORITY,CAUSE : penalty(CAUSE, P, PRIORITY) }.