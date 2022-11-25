
% Dates -----------------------------------------------------------------------
base_date(254,"日").	% 2022-09-11
base_date(255,"月").	% 2022-09-12
base_date(256,"火").	% 2022-09-13
base_date(257,"水").	% 2022-09-14
base_date(258,"木").	% 2022-09-15
base_date(259,"金").	% 2022-09-16
base_date(260,"土").	% 2022-09-17
base_date(261,"日").	% 2022-09-18
base_date(262,"月").	% 2022-09-19
base_date(263,"火").	% 2022-09-20
base_date(264,"水").	% 2022-09-21
base_date(265,"木").	% 2022-09-22
base_date(266,"金").	% 2022-09-23
base_date(267,"土").	% 2022-09-24
base_date(268,"日").	% 2022-09-25
base_date(269,"月").	% 2022-09-26
base_date(270,"火").	% 2022-09-27
base_date(271,"水").	% 2022-09-28
base_date(272,"木").	% 2022-09-29
base_date(273,"金").	% 2022-09-30
base_date(274,"土").	% 2022-10-01
base_date(275,"日").	% 2022-10-02
base_date(276,"月").	% 2022-10-03
base_date(277,"火").	% 2022-10-04
base_date(278,"水").	% 2022-10-05
base_date(279,"木").	% 2022-10-06
base_date(280,"金").	% 2022-10-07
base_date(281,"土").	% 2022-10-08
base_date(282,"日").	% 2022-10-09
base_date(283,"月").	% 2022-10-10
base_date(284,"火").	% 2022-10-11
base_date(285,"水").	% 2022-10-12
base_date(286,"木").	% 2022-10-13
base_date(287,"金").	% 2022-10-14
base_date(288,"土").	% 2022-10-15
base_date(289,"日").	% 2022-10-16
base_date(290,"月").	% 2022-10-17
base_date(291,"火").	% 2022-10-18
base_date(292,"水").	% 2022-10-19
base_date(293,"木").	% 2022-10-20
base_date(294,"金").	% 2022-10-21
base_date(295,"土").	% 2022-10-22
% 前月のシフト表の対象日
prev_date(254,"日"). prev_date(255,"月"). prev_date(256,"火").
prev_date(257,"水"). prev_date(258,"木"). prev_date(259,"金").
prev_date(260,"土").
% シフト表の作成対象日
date(261,"日"). date(262,"月"). date(263,"火"). date(264,"水"). date(265,"木").
date(266,"金"). date(267,"土"). date(268,"日"). date(269,"月"). date(270,"火").
date(271,"水"). date(272,"木"). date(273,"金"). date(274,"土"). date(275,"日").
date(276,"月"). date(277,"火"). date(278,"水"). date(279,"木"). date(280,"金").
date(281,"土"). date(282,"日"). date(283,"月"). date(284,"火"). date(285,"水").
date(286,"木"). date(287,"金"). date(288,"土").
% 翌月のシフト表の対象日
next_date(289,"日"). next_date(290,"月"). next_date(291,"火").
next_date(292,"水"). next_date(293,"木"). next_date(294,"金").
next_date(295,"土").
% 祝日
national_holiday(262,"月"). national_holiday(266,"金").
national_holiday(283,"月").

% Staffs ----------------------------------------------------------------------
staff(1,"竹田　礼子","師長","0033330",0).
staff(2,"望月　文香","副師長","0236665",5).
staff(3,"上原　良江","副師長","0021574",1).
staff(4,"手塚　浩美","副師長","0192093",5).
staff(5,"大木　麻衣","助産師","0236643",5).
staff(6,"鶴田　真希","助産師","0250845",5).
staff(7,"中山　小由美","助産師","0250754",5).
staff(8,"村松　千夏","助産師","0261564",0).
staff(9,"橋本　瑞季","助産師","0272853",5).
staff(10,"入倉　みな美","助産師","0272465",5).
staff(11,"笠井　知世","助産師","0212963",5).
staff(12,"山中　美和","助産師","0291140",5).
staff(13,"望月　舞","助産師","0341402",5).
staff(14,"大堀　夢乃","助産師","0272410",3).
staff(15,"伊藤　可奈実","看護師","0299731",2).
staff(16,"小坂　由佳莉","助産師","0301538",4).
staff(17,"堤　愛","助産師","0355693",4).
staff(18,"福田　真由","助産師","0368277",4).
staff(19,"清水　有紗","助産師","0370431",3).
staff(20,"伊藤　晴美","助産師","0315433",3).
staff(21,"遠藤　美香","助産師","0312554",2).
staff(22,"望月　紗帆","助産師","0355820",2).
staff(23,"八巻　陽香","助産師","0384698",2).
staff(24,"平田　彩奈","助産師","0384164",2).
staff(25,"小林　彩美","助産師","0329213",2).
staff(26,"武持　舞","助産師","0329348",2).
staff(27,"小野　聡美","助産師","0355512",1).
staff(28,"大村　向日葵","助産師","0400037",1).
staff(29,"小林　舞","助産師","0400015",1).
staff(30,"田中　里実","助産師","0347784",1).
staff(31,"原　奈々子","助産師","0347820",1).
staff(32,"渡辺　めい","助産師","0399732",1).

% Shifts ----------------------------------------------------------------------
shift("日").	% 日勤, 連続は５回まで
shift("N").	% 長日勤, 連続は２回まで, 「N1」と「N2」は「N」にまとめる。
shift("J").	% 短準夜, 後にSが来る。, 「J1」と「J2」は「J」にまとめる。
shift("S").	% 短深夜, Jの後
shift("★").	% 準夜, 後に☆が来る。
shift("☆").	% 深夜, ★の後
shift("P").	% 遅出, 連続なし, Nが不足する（５未満）の時にPで代替
shift("○").	% 週休, 28日の中に8日必要
shift("◎").	% 祝日, 祝日に労働がない時, 祝日に勤務がないと自動的に設定、なるべく年間で公平に
shift("研").	% 研修, 希望入力のみ, 出張等も「研」にまとめるか。
shift("年").	% 休暇, 希望入力のみ, 「ﾈ|」、「|ﾈ」等の半休もすべて含めるか。
shift("健").	% 健康増進休暇, 希望入力のみ, １～１２月で４日間、１日単位
shift("特").	% その他の特別休暇, 希望入力のみ
shift("/").	% シフト割振不可, 他部署への応援等

% Shift constraints -----------------------------------------------------------
% 連続勤務可能日数
consecutive_work_ub(5).
% 必須パターン
mandatory_pattern_3("★","☆","○").
mandatory_pattern_2("J","S").
% 禁止パターン
forbidden_pattern("N","N").
forbidden_pattern("N","日").
forbidden_pattern("P","日").
forbidden_pattern("P","N").
pattern("NN",2).
pattern("NN",0,"N").
pattern("NN",1,"N").
forbidden_pattern("NN").
pattern("N日",2).
pattern("N日",0,"N").
pattern("N日",1,"日").
forbidden_pattern("N日").
pattern("P日",2).
pattern("P日",0,"P").
pattern("P日",1,"日").
forbidden_pattern("P日").
pattern("PN",2).
pattern("PN",0,"P").
pattern("PN",1,"N").
forbidden_pattern("PN").
% 推奨パターン
recommended_pattern_4("N","J","S","○").
recommended_pattern_6("N","J","S","J","S","○").
recommended_pattern_2("○","○").	% ※できれば土日で
% 前日・翌日可能シフト
pred_shift("J","S").
succ_shift("S","J").
succ_shift("S","○").
pred_shift("N","J").
pred_shift("P","J").
pred_shift("S","J").
succ_shift("J","S").
succ_shift("★","☆").
pred_shift("★","☆").
succ_shift("☆","○").
% パターン割当数の最小・最大値
num_patterns_2("○","○").
num_patterns_2_lb("○","○", 2).
num_patterns_4("J","S","J","S").
num_patterns_4_ub("J","S","J","S", 1).
num_patterns_2("N","日").
num_patterns_2_ub("N","日", 1).
num_patterns_2("P","日").
num_patterns_2_ub("P","日", 1).
num_patterns_2("P","N").
num_patterns_2_ub("P","N", 1).
num_patterns_2("P","P").
num_patterns_2_ub("P","P", 1).
pattern("○○",2).
pattern("○○",0,"○").
pattern("○○",1,"○").
pattern("JSJS",4).
pattern("JSJS",0,"J").
pattern("JSJS",1,"S").
pattern("JSJS",2,"J").
pattern("JSJS",3,"S").
pattern("N日",2).
pattern("N日",0,"N").
pattern("N日",1,"日").
pattern("P日",2).
pattern("P日",0,"P").
pattern("P日",1,"日").
pattern("PN",2).
pattern("PN",0,"P").
pattern("PN",1,"N").
pattern("PP",2).
pattern("PP",0,"P").
pattern("PP",1,"P").
pattern_lb("○○", 2).
pattern_ub("JSJS", 1).
pattern_ub("N日", 1).
pattern_ub("P日", 1).
pattern_ub("PN", 1).
pattern_ub("PP", 1).

% Staff's requests ------------------------------------------------------------
% Staff 1
assigned(1, 254, "○"). assigned(1, 255, "日"). assigned(1, 256, "日").
assigned(1, 257, "日"). assigned(1, 258, "日"). assigned(1, 259, "日").
assigned(1, 260, "○").
% Staff 2
assigned(2, 254, "○"). assigned(2, 255, "日"). assigned(2, 256, "日").
assigned(2, 257, "日"). assigned(2, 258, "日"). assigned(2, 259, "日").
assigned(2, 260, "日"). staff_request(2, 261, "○").
staff_request(2, 263, "日"). staff_request(2, 264, "日").
staff_request(2, 268, "○"). staff_request(2, 271, "日").
staff_request(2, 273, "★"). staff_request(2, 274, "☆").
staff_request(2, 275, "○"). staff_request(2, 280, "日").
staff_request(2, 281, "○"). staff_request(2, 282, "○").
staff_request(2, 285, "日"). staff_request(2, 287, "日").
staff_request(2, 288, "○").
% Staff 3
assigned(3, 254, "○"). assigned(3, 255, "日"). assigned(3, 256, "日").
assigned(3, 257, "N"). assigned(3, 258, "J"). assigned(3, 259, "S").
assigned(3, 260, "○"). staff_request(3, 265, "日").
staff_request(3, 273, "日"). staff_request(3, 275, "○").
staff_request(3, 285, "日").
% Staff 4
assigned(4, 254, "○"). assigned(4, 255, "日"). assigned(4, 256, "○").
assigned(4, 257, "日"). assigned(4, 258, "日"). assigned(4, 259, "★").
assigned(4, 260, "☆"). staff_request(4, 261, "○").
staff_request(4, 269, "日"). staff_request(4, 272, "日").
staff_request(4, 277, "年"). staff_request(4, 282, "○").
staff_request(4, 286, "日"). staff_request(4, 289, "○").
% Staff 5
assigned(5, 254, "○"). assigned(5, 255, "○"). assigned(5, 256, "日").
assigned(5, 257, "日"). assigned(5, 258, "J"). assigned(5, 259, "S").
assigned(5, 260, "健"). staff_request(5, 261, "健").
staff_request(5, 262, "◎"). staff_request(5, 263, "○").
staff_request(5, 265, "日"). staff_request(5, 267, "○").
staff_request(5, 273, "○"). staff_request(5, 276, "○").
staff_request(5, 281, "○"). staff_request(5, 287, "○").
staff_request(5, 288, "○").
% Staff 6
assigned(6, 254, "N"). assigned(6, 255, "J"). assigned(6, 256, "S").
assigned(6, 257, "○"). assigned(6, 258, "日"). assigned(6, 259, "日").
assigned(6, 260, "日"). staff_request(6, 272, "年").
staff_request(6, 273, "年").
% Staff 7
assigned(7, 254, "J"). assigned(7, 255, "S"). assigned(7, 256, "○").
assigned(7, 257, "日"). assigned(7, 258, "日"). assigned(7, 259, "日").
assigned(7, 260, "○"). staff_request(7, 261, "○").
staff_request(7, 262, "J"). staff_request(7, 263, "S").
staff_request(7, 264, "○"). staff_request(7, 267, "健").
staff_request(7, 268, "健"). staff_request(7, 269, "健").
staff_request(7, 274, "N"). staff_request(7, 275, "J").
staff_request(7, 276, "S"). staff_request(7, 277, "○").
staff_request(7, 281, "N"). staff_request(7, 282, "○").
staff_request(7, 283, "◎"). staff_request(7, 287, "日").
staff_request(7, 289, "○").
% Staff 8
assigned(8, 254, "/"). assigned(8, 255, "/"). assigned(8, 256, "/").
assigned(8, 257, "/"). assigned(8, 258, "/"). assigned(8, 259, "/").
assigned(8, 260, "/"). staff_request(8, 261, "/"). staff_request(8, 262, "/").
staff_request(8, 263, "/"). staff_request(8, 264, "/").
staff_request(8, 265, "/"). staff_request(8, 266, "/").
staff_request(8, 267, "/"). staff_request(8, 268, "/").
staff_request(8, 269, "/"). staff_request(8, 270, "/").
staff_request(8, 271, "/"). staff_request(8, 272, "/").
staff_request(8, 273, "/"). staff_request(8, 274, "/").
staff_request(8, 275, "/"). staff_request(8, 276, "/").
staff_request(8, 277, "/"). staff_request(8, 278, "/").
staff_request(8, 279, "/"). staff_request(8, 280, "/").
staff_request(8, 281, "/"). staff_request(8, 282, "/").
staff_request(8, 283, "/"). staff_request(8, 284, "/").
staff_request(8, 285, "/"). staff_request(8, 286, "/").
staff_request(8, 287, "/"). staff_request(8, 288, "/").
staff_request(8, 289, "/"). staff_request(8, 290, "/").
staff_request(8, 291, "/"). staff_request(8, 292, "/").
staff_request(8, 293, "/"). staff_request(8, 294, "/").
staff_request(8, 295, "/").
% Staff 9
assigned(9, 254, "日"). assigned(9, 255, "日"). assigned(9, 256, "日").
assigned(9, 257, "日"). assigned(9, 258, "N"). assigned(9, 259, "○").
assigned(9, 260, "J"). staff_request(9, 261, "S"). staff_request(9, 265, "健").
staff_request(9, 284, "日"). staff_request(9, 289, "○").
staff_request(9, 290, "日"). staff_request(9, 291, "日").
staff_request(9, 292, "日").
% Staff 10
assigned(10, 254, "○"). assigned(10, 255, "N"). assigned(10, 256, "J").
assigned(10, 257, "S"). assigned(10, 258, "○"). assigned(10, 259, "N").
assigned(10, 260, "J"). staff_request(10, 261, "S").
staff_request(10, 268, "年"). staff_request(10, 273, "日").
staff_request(10, 275, "○"). staff_request(10, 276, "日").
staff_request(10, 277, "日"). staff_request(10, 278, "日").
staff_request(10, 279, "日"). staff_request(10, 285, "健").
staff_request(10, 286, "健"). staff_request(10, 287, "日").
% Staff 11
assigned(11, 254, "日"). assigned(11, 255, "日"). assigned(11, 256, "○").
assigned(11, 257, "J"). assigned(11, 258, "S"). assigned(11, 259, "J").
assigned(11, 260, "S"). staff_request(11, 263, "日").
staff_request(11, 264, "日"). staff_request(11, 265, "日").
staff_request(11, 284, "日"). staff_request(11, 285, "日").
staff_request(11, 286, "日"). staff_request(11, 287, "日").
% Staff 12
assigned(12, 254, "日"). assigned(12, 255, "日"). assigned(12, 256, "日").
assigned(12, 257, "日"). assigned(12, 258, "日"). assigned(12, 259, "○").
assigned(12, 260, "N"). staff_request(12, 267, "○").
staff_request(12, 268, "○"). staff_request(12, 283, "◎").
staff_request(12, 284, "年"). staff_request(12, 285, "年").
% Staff 13
assigned(13, 254, "S"). assigned(13, 255, "○"). assigned(13, 256, "N").
assigned(13, 257, "P"). assigned(13, 258, "J"). assigned(13, 259, "S").
assigned(13, 260, "○"). staff_request(13, 269, "日").
staff_request(13, 270, "日"). staff_request(13, 271, "日").
staff_request(13, 272, "日"). staff_request(13, 273, "健").
staff_request(13, 274, "健"). staff_request(13, 275, "健").
staff_request(13, 276, "健"). staff_request(13, 277, "○").
% Staff 14
assigned(14, 254, "J"). assigned(14, 255, "S"). assigned(14, 256, "○").
assigned(14, 257, "N"). assigned(14, 258, "○"). assigned(14, 259, "健").
assigned(14, 260, "健"). staff_request(14, 261, "健").
staff_request(14, 262, "◎").
% Staff 15
assigned(15, 254, "S"). assigned(15, 255, "○"). assigned(15, 256, "○").
assigned(15, 257, "○"). assigned(15, 258, "年"). assigned(15, 259, "N").
assigned(15, 260, "J"). staff_request(15, 261, "S").
staff_request(15, 265, "日"). staff_request(15, 270, "日").
% Staff 16
assigned(16, 254, "○"). assigned(16, 255, "N"). assigned(16, 256, "J").
assigned(16, 257, "S"). assigned(16, 258, "○"). assigned(16, 259, "日").
assigned(16, 260, "日"). staff_request(16, 269, "健").
% Staff 17
assigned(17, 254, "N"). assigned(17, 255, "J"). assigned(17, 256, "S").
assigned(17, 257, "○"). assigned(17, 258, "J"). assigned(17, 259, "S").
assigned(17, 260, "○").
% Staff 18
assigned(18, 254, "○"). assigned(18, 255, "日"). assigned(18, 256, "N").
assigned(18, 257, "J"). assigned(18, 258, "S"). assigned(18, 259, "○").
assigned(18, 260, "N"). staff_request(18, 281, "健").
staff_request(18, 282, "健"). staff_request(18, 283, "◎").
staff_request(18, 284, "○").
% Staff 19
assigned(19, 254, "N"). assigned(19, 255, "J"). assigned(19, 256, "S").
assigned(19, 257, "○"). assigned(19, 258, "N"). assigned(19, 259, "J").
assigned(19, 260, "S"). staff_request(19, 263, "○").
staff_request(19, 267, "年"). staff_request(19, 268, "年").
staff_request(19, 270, "○"). staff_request(19, 278, "○").
staff_request(19, 279, "○").
% Staff 20
assigned(20, 254, "/"). assigned(20, 255, "/"). assigned(20, 256, "/").
assigned(20, 257, "/"). assigned(20, 258, "/"). assigned(20, 259, "/").
assigned(20, 260, "/"). staff_request(20, 261, "/").
staff_request(20, 262, "/"). staff_request(20, 263, "/").
staff_request(20, 264, "/"). staff_request(20, 265, "/").
staff_request(20, 266, "/"). staff_request(20, 267, "/").
staff_request(20, 268, "健"). staff_request(20, 269, "○").
staff_request(20, 278, "○"). staff_request(20, 282, "○").
% Staff 21
assigned(21, 254, "J"). assigned(21, 255, "S"). assigned(21, 256, "○").
assigned(21, 257, "○"). assigned(21, 258, "N"). assigned(21, 259, "J").
assigned(21, 260, "S"). staff_request(21, 268, "/").
staff_request(21, 269, "/"). staff_request(21, 270, "/").
staff_request(21, 271, "/"). staff_request(21, 272, "/").
staff_request(21, 273, "/"). staff_request(21, 274, "/").
staff_request(21, 275, "/"). staff_request(21, 276, "/").
staff_request(21, 277, "/"). staff_request(21, 278, "/").
staff_request(21, 279, "/"). staff_request(21, 280, "/").
staff_request(21, 281, "/"). staff_request(21, 282, "/").
staff_request(21, 283, "/"). staff_request(21, 284, "/").
staff_request(21, 285, "/"). staff_request(21, 286, "/").
staff_request(21, 287, "/"). staff_request(21, 288, "/").
staff_request(21, 289, "○").
% Staff 22
assigned(22, 254, "S"). assigned(22, 255, "○"). assigned(22, 256, "N").
assigned(22, 257, "J"). assigned(22, 258, "S"). assigned(22, 259, "○").
assigned(22, 260, "年"). staff_request(22, 289, "○").
staff_request(22, 290, "日"). staff_request(22, 291, "日").
staff_request(22, 292, "日").
% Staff 23
assigned(23, 254, "N"). assigned(23, 255, "J"). assigned(23, 256, "S").
assigned(23, 257, "○"). assigned(23, 258, "日"). assigned(23, 259, "○").
assigned(23, 260, "N"). staff_request(23, 261, "年").
staff_request(23, 288, "年"). staff_request(23, 289, "年").
staff_request(23, 290, "年").
% Staff 24
assigned(24, 254, "○"). assigned(24, 255, "N"). assigned(24, 256, "J").
assigned(24, 257, "S"). assigned(24, 258, "○"). assigned(24, 259, "N").
assigned(24, 260, "J"). staff_request(24, 261, "S").
% Staff 25
assigned(25, 254, "S"). assigned(25, 255, "○"). assigned(25, 256, "○").
assigned(25, 257, "N"). assigned(25, 258, "J"). assigned(25, 259, "S").
assigned(25, 260, "○"). staff_request(25, 283, "◎").
staff_request(25, 284, "健").
% Staff 26
assigned(26, 254, "J"). assigned(26, 255, "S"). assigned(26, 256, "○").
assigned(26, 257, "○"). assigned(26, 258, "日"). assigned(26, 259, "日").
assigned(26, 260, "N").
% Staff 27
assigned(27, 254, "日"). assigned(27, 255, "○"). assigned(27, 256, "N").
assigned(27, 257, "J"). assigned(27, 258, "S"). assigned(27, 259, "○").
assigned(27, 260, "○"). staff_request(27, 276, "健").
staff_request(27, 277, "健"). staff_request(27, 278, "健").
staff_request(27, 279, "健"). staff_request(27, 280, "○").
staff_request(27, 281, "○").
% Staff 28
assigned(28, 254, "○"). assigned(28, 255, "○"). assigned(28, 256, "日").
assigned(28, 257, "N"). assigned(28, 258, "J"). assigned(28, 259, "S").
assigned(28, 260, "○"). staff_request(28, 269, "日").
staff_request(28, 273, "日"). staff_request(28, 276, "○").
staff_request(28, 284, "○").
% Staff 29
assigned(29, 254, "J"). assigned(29, 255, "S"). assigned(29, 256, "○").
assigned(29, 257, "○"). assigned(29, 258, "N"). assigned(29, 259, "○").
assigned(29, 260, "健"). staff_request(29, 261, "健").
staff_request(29, 262, "◎"). staff_request(29, 269, "日").
staff_request(29, 273, "日").
% Staff 30
assigned(30, 254, "N"). assigned(30, 255, "J"). assigned(30, 256, "S").
assigned(30, 257, "○"). assigned(30, 258, "○"). assigned(30, 259, "日").
assigned(30, 260, "日"). staff_request(30, 269, "日").
staff_request(30, 273, "日").
% Staff 31
assigned(31, 254, "○"). assigned(31, 255, "N"). assigned(31, 256, "J").
assigned(31, 257, "S"). assigned(31, 258, "○"). assigned(31, 259, "日").
assigned(31, 260, "日"). staff_request(31, 262, "◎").
staff_request(31, 263, "○"). staff_request(31, 269, "日").
staff_request(31, 273, "日").
% Staff 32
assigned(32, 254, "日"). assigned(32, 255, "N"). assigned(32, 256, "J").
assigned(32, 257, "S"). assigned(32, 258, "○"). assigned(32, 259, "日").
assigned(32, 260, "日"). staff_request(32, 269, "日").
staff_request(32, 273, "日"). staff_request(32, 281, "○").
staff_request(32, 282, "○").
% Staff 33

% Staff 34

% Staff 35

% Staff 36

% Staff 37

% Staff 38

% Staff 39

% Staff 40

% Staff 41

% Staff 42

% Staff 43


% Groups ----------------------------------------------------------------------
group("全員"). group("熟練グループ１"). group("熟練グループ２").
group("師長・副師長グループ"). group("中堅グループ"). group("新人グループ").
group("新人グループ１"). group("新人グループ２"). group("夜勤グループ").
group("全員",1). group("全員",2). group("全員",3). group("全員",4).
group("全員",5). group("全員",6). group("全員",7). group("全員",8).
group("全員",9). group("全員",10). group("全員",11). group("全員",12).
group("全員",13). group("全員",14). group("全員",15). group("全員",16).
group("全員",17). group("全員",18). group("全員",19). group("全員",20).
group("全員",21). group("全員",22). group("全員",23). group("全員",24).
group("全員",25). group("全員",26). group("全員",27). group("全員",28).
group("全員",29). group("全員",30). group("全員",31). group("全員",32).
group("熟練グループ１",1). group("熟練グループ１",2).
group("熟練グループ１",4). group("熟練グループ１",5).
group("熟練グループ１",6). group("熟練グループ１",7).
group("熟練グループ１",8). group("熟練グループ１",9).
group("熟練グループ１",10). group("熟練グループ１",11).
group("熟練グループ１",12). group("熟練グループ１",13).
group("熟練グループ２",2). group("熟練グループ２",5).
group("熟練グループ２",6). group("熟練グループ２",7).
group("熟練グループ２",8). group("熟練グループ２",9).
group("熟練グループ２",10). group("熟練グループ２",11).
group("熟練グループ２",12). group("熟練グループ２",13).
group("師長・副師長グループ",1). group("師長・副師長グループ",2).
group("師長・副師長グループ",4).
group("中堅グループ",14). group("中堅グループ",15). group("中堅グループ",16).
group("中堅グループ",17). group("中堅グループ",18).
group("新人グループ",3). group("新人グループ",19). group("新人グループ",20).
group("新人グループ",21). group("新人グループ",22). group("新人グループ",23).
group("新人グループ",24). group("新人グループ",25). group("新人グループ",26).
group("新人グループ",27). group("新人グループ",28). group("新人グループ",29).
group("新人グループ",30). group("新人グループ",31). group("新人グループ",32).
group("新人グループ１",3). group("新人グループ１",19).
group("新人グループ１",20). group("新人グループ１",21).
group("新人グループ１",22). group("新人グループ１",23).
group("新人グループ１",24). group("新人グループ１",25).
group("新人グループ１",26).
group("新人グループ２",27). group("新人グループ２",28).
group("新人グループ２",29). group("新人グループ２",30).
group("新人グループ２",31). group("新人グループ２",32).
group("夜勤グループ",2). group("夜勤グループ",4). group("夜勤グループ",5).
group("夜勤グループ",6). group("夜勤グループ",7). group("夜勤グループ",8).
group("夜勤グループ",9). group("夜勤グループ",10). group("夜勤グループ",11).
group("夜勤グループ",12). group("夜勤グループ",13). group("夜勤グループ",14).
group("夜勤グループ",15). group("夜勤グループ",16). group("夜勤グループ",17).
group("夜勤グループ",18). group("夜勤グループ",19). group("夜勤グループ",20).
group("夜勤グループ",21). group("夜勤グループ",22). group("夜勤グループ",23).
group("夜勤グループ",24). group("夜勤グループ",25). group("夜勤グループ",26).
group("夜勤グループ",27). group("夜勤グループ",28). group("夜勤グループ",29).
group("夜勤グループ",30). group("夜勤グループ",31). group("夜勤グループ",32).

% Num of staffs ---------------------------------------------------------------
% 全員, 日
staff_dweek_bounds("全員","日","日",4,6).
staff_dweek_bounds("全員","日","月",5,9).
staff_dweek_bounds("全員","日","火",5,9).
staff_dweek_bounds("全員","日","水",5,9).
staff_dweek_bounds("全員","日","木",5,9).
staff_dweek_bounds("全員","日","金",5,9).
staff_dweek_bounds("全員","日","土",4,6).
staff_dweek_bounds("全員","日","祝日",4,6).
% 全員, N
staff_dweek_bounds("全員","N","日",4,5).
staff_dweek_bounds("全員","N","月",4,5).
staff_dweek_bounds("全員","N","火",4,5).
staff_dweek_bounds("全員","N","水",4,5).
staff_dweek_bounds("全員","N","木",4,5).
staff_dweek_bounds("全員","N","金",4,5).
staff_dweek_bounds("全員","N","土",4,5).
staff_dweek_bounds("全員","N","祝日",4,5).
% 全員, J
staff_dweek_bounds("全員","J","日",4,5).
staff_dweek_bounds("全員","J","月",4,5).
staff_dweek_bounds("全員","J","火",4,5).
staff_dweek_bounds("全員","J","水",4,5).
staff_dweek_bounds("全員","J","木",4,5).
staff_dweek_bounds("全員","J","金",4,5).
staff_dweek_bounds("全員","J","土",4,5).
staff_dweek_bounds("全員","J","祝日",4,5).
% 全員, S
staff_dweek_bounds("全員","S","日",4,5).
staff_dweek_bounds("全員","S","月",4,5).
staff_dweek_bounds("全員","S","火",4,5).
staff_dweek_bounds("全員","S","水",4,5).
staff_dweek_bounds("全員","S","木",4,5).
staff_dweek_bounds("全員","S","金",4,5).
staff_dweek_bounds("全員","S","土",4,5).
staff_dweek_bounds("全員","S","祝日",4,5).
% 全員, ★
% 希望で★☆夜勤があれば可能
staff_dweek_bounds("全員","★","日",0,1).
staff_dweek_bounds("全員","★","月",0,1).
staff_dweek_bounds("全員","★","火",0,1).
staff_dweek_bounds("全員","★","水",0,1).
staff_dweek_bounds("全員","★","木",0,1).
staff_dweek_bounds("全員","★","金",0,1).
staff_dweek_bounds("全員","★","土",0,1).
staff_dweek_bounds("全員","★","祝日",0,1).
% 全員, ☆
staff_dweek_bounds("全員","☆","日",0,1).
staff_dweek_bounds("全員","☆","月",0,1).
staff_dweek_bounds("全員","☆","火",0,1).
staff_dweek_bounds("全員","☆","水",0,1).
staff_dweek_bounds("全員","☆","木",0,1).
staff_dweek_bounds("全員","☆","金",0,1).
staff_dweek_bounds("全員","☆","土",0,1).
staff_dweek_bounds("全員","☆","祝日",0,1).
% 全員, P
% P推奨は１人
staff_dweek_bounds("全員","P","日",0,2).
staff_dweek_bounds("全員","P","月",0,2).
staff_dweek_bounds("全員","P","火",0,2).
staff_dweek_bounds("全員","P","水",0,2).
staff_dweek_bounds("全員","P","木",0,2).
staff_dweek_bounds("全員","P","金",0,2).
staff_dweek_bounds("全員","P","土",0,2).
staff_dweek_bounds("全員","P","祝日",0,2).
% 全員, N+P
% Pを割り当てるのはNが４以下のときのみ（N=5ならP=0)
shift_group("N+P", "N").
shift_group("N+P", "P").
staff_sg_dweek_bounds("全員","N+P","日",4,5).
staff_sg_dweek_bounds("全員","N+P","月",4,5).
staff_sg_dweek_bounds("全員","N+P","火",4,5).
staff_sg_dweek_bounds("全員","N+P","水",4,5).
staff_sg_dweek_bounds("全員","N+P","木",4,5).
staff_sg_dweek_bounds("全員","N+P","金",4,5).
staff_sg_dweek_bounds("全員","N+P","土",4,5).
staff_sg_dweek_bounds("全員","N+P","祝日",4,5).
% 全員, N+P+★
% N,P,★は常に８名以上とする
shift_group("N+P+★", "N").
shift_group("N+P+★", "P").
shift_group("N+P+★", "★").
staff_sg_dweek_bounds("全員","N+P+★","日",4,6).
staff_sg_dweek_bounds("全員","N+P+★","月",4,6).
staff_sg_dweek_bounds("全員","N+P+★","火",4,6).
staff_sg_dweek_bounds("全員","N+P+★","水",4,6).
staff_sg_dweek_bounds("全員","N+P+★","木",4,6).
staff_sg_dweek_bounds("全員","N+P+★","金",4,6).
staff_sg_dweek_bounds("全員","N+P+★","土",4,6).
staff_sg_dweek_bounds("全員","N+P+★","祝日",4,6).
% 熟練グループ１, J
% 熟練グループから夜勤に1,2名を割り当てる
staff_dweek_bounds("熟練グループ１","J","日",1,2).
staff_dweek_bounds("熟練グループ１","J","月",1,2).
staff_dweek_bounds("熟練グループ１","J","火",1,2).
staff_dweek_bounds("熟練グループ１","J","水",1,2).
staff_dweek_bounds("熟練グループ１","J","木",1,2).
staff_dweek_bounds("熟練グループ１","J","金",1,2).
staff_dweek_bounds("熟練グループ１","J","土",1,2).
staff_dweek_bounds("熟練グループ１","J","祝日",1,2).
% 熟練グループ１, S
% 熟練グループから夜勤に1,2名を割り当てる
staff_dweek_bounds("熟練グループ１","S","日",1,2).
staff_dweek_bounds("熟練グループ１","S","月",1,2).
staff_dweek_bounds("熟練グループ１","S","火",1,2).
staff_dweek_bounds("熟練グループ１","S","水",1,2).
staff_dweek_bounds("熟練グループ１","S","木",1,2).
staff_dweek_bounds("熟練グループ１","S","金",1,2).
staff_dweek_bounds("熟練グループ１","S","土",1,2).
staff_dweek_bounds("熟練グループ１","S","祝日",1,2).
% 熟練グループ２, N
% 長日勤には熟練者を少なくとも１名割り当てる（師長，看護師除く）
staff_dweek_bounds("熟練グループ２","N","日",1,10).
staff_dweek_bounds("熟練グループ２","N","月",1,10).
staff_dweek_bounds("熟練グループ２","N","火",1,10).
staff_dweek_bounds("熟練グループ２","N","水",1,10).
staff_dweek_bounds("熟練グループ２","N","木",1,10).
staff_dweek_bounds("熟練グループ２","N","金",1,10).
staff_dweek_bounds("熟練グループ２","N","土",1,10).
staff_dweek_bounds("熟練グループ２","N","祝日",1,10).
% 師長・副師長グループ, 日
% 師長または副師長は，日勤に少なくとも１名割り当てる（平日のみ）
staff_dweek_bounds("師長・副師長グループ","日","日",1,3).
staff_dweek_bounds("師長・副師長グループ","日","月",1,3).
staff_dweek_bounds("師長・副師長グループ","日","火",1,3).
staff_dweek_bounds("師長・副師長グループ","日","水",1,3).
staff_dweek_bounds("師長・副師長グループ","日","木",1,3).
staff_dweek_bounds("師長・副師長グループ","日","金",1,3).
staff_dweek_bounds("師長・副師長グループ","日","土",1,3).
staff_dweek_bounds("師長・副師長グループ","日","祝日",1,3).
% 中堅グループ, J
% 中堅グループから夜勤に1,2名を割り当てる
staff_dweek_bounds("中堅グループ","J","日",1,2).
staff_dweek_bounds("中堅グループ","J","月",1,2).
staff_dweek_bounds("中堅グループ","J","火",1,2).
staff_dweek_bounds("中堅グループ","J","水",1,2).
staff_dweek_bounds("中堅グループ","J","木",1,2).
staff_dweek_bounds("中堅グループ","J","金",1,2).
staff_dweek_bounds("中堅グループ","J","土",1,2).
staff_dweek_bounds("中堅グループ","J","祝日",1,2).
% 中堅グループ, S
% 中堅グループから夜勤に1,2名を割り当てる
staff_dweek_bounds("中堅グループ","S","日",1,2).
staff_dweek_bounds("中堅グループ","S","月",1,2).
staff_dweek_bounds("中堅グループ","S","火",1,2).
staff_dweek_bounds("中堅グループ","S","水",1,2).
staff_dweek_bounds("中堅グループ","S","木",1,2).
staff_dweek_bounds("中堅グループ","S","金",1,2).
staff_dweek_bounds("中堅グループ","S","土",1,2).
staff_dweek_bounds("中堅グループ","S","祝日",1,2).
% 新人グループ, J
% 新人グループは夜勤１～３人
staff_dweek_bounds("新人グループ","J","日",1,3).
staff_dweek_bounds("新人グループ","J","月",1,3).
staff_dweek_bounds("新人グループ","J","火",1,3).
staff_dweek_bounds("新人グループ","J","水",1,3).
staff_dweek_bounds("新人グループ","J","木",1,3).
staff_dweek_bounds("新人グループ","J","金",1,3).
staff_dweek_bounds("新人グループ","J","土",1,3).
staff_dweek_bounds("新人グループ","J","祝日",1,3).
% 新人グループ, S
% 新人グループは夜勤１～３人
staff_dweek_bounds("新人グループ","S","日",1,3).
staff_dweek_bounds("新人グループ","S","月",1,3).
staff_dweek_bounds("新人グループ","S","火",1,3).
staff_dweek_bounds("新人グループ","S","水",1,3).
staff_dweek_bounds("新人グループ","S","木",1,3).
staff_dweek_bounds("新人グループ","S","金",1,3).
staff_dweek_bounds("新人グループ","S","土",1,3).
staff_dweek_bounds("新人グループ","S","祝日",1,3).
% 新人グループ１, J
% 新人グループ１は夜勤２名まで
staff_dweek_bounds("新人グループ１","J","日",0,2).
staff_dweek_bounds("新人グループ１","J","月",0,2).
staff_dweek_bounds("新人グループ１","J","火",0,2).
staff_dweek_bounds("新人グループ１","J","水",0,2).
staff_dweek_bounds("新人グループ１","J","木",0,2).
staff_dweek_bounds("新人グループ１","J","金",0,2).
staff_dweek_bounds("新人グループ１","J","土",0,2).
staff_dweek_bounds("新人グループ１","J","祝日",0,2).
% 新人グループ１, S
% 新人グループ１は夜勤２名まで
staff_dweek_bounds("新人グループ１","S","日",0,2).
staff_dweek_bounds("新人グループ１","S","月",0,2).
staff_dweek_bounds("新人グループ１","S","火",0,2).
staff_dweek_bounds("新人グループ１","S","水",0,2).
staff_dweek_bounds("新人グループ１","S","木",0,2).
staff_dweek_bounds("新人グループ１","S","金",0,2).
staff_dweek_bounds("新人グループ１","S","土",0,2).
staff_dweek_bounds("新人グループ１","S","祝日",0,2).
% 新人グループ２, N
% 新人グループ２は長日勤・夜勤１名まで
staff_dweek_bounds("新人グループ２","N","日",0,1).
staff_dweek_bounds("新人グループ２","N","月",0,1).
staff_dweek_bounds("新人グループ２","N","火",0,1).
staff_dweek_bounds("新人グループ２","N","水",0,1).
staff_dweek_bounds("新人グループ２","N","木",0,1).
staff_dweek_bounds("新人グループ２","N","金",0,1).
staff_dweek_bounds("新人グループ２","N","土",0,1).
staff_dweek_bounds("新人グループ２","N","祝日",0,1).
% 新人グループ２, J
% 新人グループ２は長日勤・夜勤１名まで
staff_dweek_bounds("新人グループ２","J","日",0,1).
staff_dweek_bounds("新人グループ２","J","月",0,1).
staff_dweek_bounds("新人グループ２","J","火",0,1).
staff_dweek_bounds("新人グループ２","J","水",0,1).
staff_dweek_bounds("新人グループ２","J","木",0,1).
staff_dweek_bounds("新人グループ２","J","金",0,1).
staff_dweek_bounds("新人グループ２","J","土",0,1).
staff_dweek_bounds("新人グループ２","J","祝日",0,1).
% 新人グループ２, S
% 新人グループ２は長日勤・夜勤１名まで
staff_dweek_bounds("新人グループ２","S","日",0,1).
staff_dweek_bounds("新人グループ２","S","月",0,1).
staff_dweek_bounds("新人グループ２","S","火",0,1).
staff_dweek_bounds("新人グループ２","S","水",0,1).
staff_dweek_bounds("新人グループ２","S","木",0,1).
staff_dweek_bounds("新人グループ２","S","金",0,1).
staff_dweek_bounds("新人グループ２","S","土",0,1).
staff_dweek_bounds("新人グループ２","S","祝日",0,1).
% 夜勤グループ, J＋★
% 夜勤には常に４名、計11点を確保
% ※以下が希望です
% ・新人１→中堅以上３
% ・新人２→中堅以上２
% ・新人３→中堅以上２
shift_group("J＋★", "J").
shift_group("J＋★", "★").
staff_sg_dweek_bounds("夜勤グループ","J＋★","日",4,4).
staff_sg_dweek_bounds("夜勤グループ","J＋★","月",4,4).
staff_sg_dweek_bounds("夜勤グループ","J＋★","火",4,4).
staff_sg_dweek_bounds("夜勤グループ","J＋★","水",4,4).
staff_sg_dweek_bounds("夜勤グループ","J＋★","木",4,4).
staff_sg_dweek_bounds("夜勤グループ","J＋★","金",4,4).
staff_sg_dweek_bounds("夜勤グループ","J＋★","土",4,4).
staff_sg_dweek_bounds("夜勤グループ","J＋★","祝日",4,4).
% 夜勤グループ, S＋☆
% 夜勤には常に４名、計11点を確保
% ※以下が希望です
% ・新人１→中堅以上３
% ・新人２→中堅以上２
% ・新人３→中堅以上２
shift_group("S＋☆", "S").
shift_group("S＋☆", "☆").
staff_sg_dweek_bounds("夜勤グループ","S＋☆","日",4,4).
staff_sg_dweek_bounds("夜勤グループ","S＋☆","月",4,4).
staff_sg_dweek_bounds("夜勤グループ","S＋☆","火",4,4).
staff_sg_dweek_bounds("夜勤グループ","S＋☆","水",4,4).
staff_sg_dweek_bounds("夜勤グループ","S＋☆","木",4,4).
staff_sg_dweek_bounds("夜勤グループ","S＋☆","金",4,4).
staff_sg_dweek_bounds("夜勤グループ","S＋☆","土",4,4).
staff_sg_dweek_bounds("夜勤グループ","S＋☆","祝日",4,4).
% 夜勤グループ, J＋★
% 夜勤には常に４名、計11点を確保
% ※以下が希望です
% ・新人１→中堅以上３
% ・新人２→中堅以上２
% ・新人３→中堅以上２
shift_group("J＋★", "J").
shift_group("J＋★", "★").
point_sg_dweek_bounds("夜勤グループ","J＋★","日",11,91).
point_sg_dweek_bounds("夜勤グループ","J＋★","月",11,91).
point_sg_dweek_bounds("夜勤グループ","J＋★","火",11,91).
point_sg_dweek_bounds("夜勤グループ","J＋★","水",11,91).
point_sg_dweek_bounds("夜勤グループ","J＋★","木",11,91).
point_sg_dweek_bounds("夜勤グループ","J＋★","金",11,91).
point_sg_dweek_bounds("夜勤グループ","J＋★","土",11,91).
point_sg_dweek_bounds("夜勤グループ","J＋★","祝日",11,91).
% 夜勤グループ, S＋☆
% 夜勤には常に４名、計11点を確保
% ※以下が希望です
% ・新人１→中堅以上３
% ・新人２→中堅以上２
% ・新人３→中堅以上２
shift_group("S＋☆", "S").
shift_group("S＋☆", "☆").
point_sg_dweek_bounds("夜勤グループ","S＋☆","日",11,91).
point_sg_dweek_bounds("夜勤グループ","S＋☆","月",11,91).
point_sg_dweek_bounds("夜勤グループ","S＋☆","火",11,91).
point_sg_dweek_bounds("夜勤グループ","S＋☆","水",11,91).
point_sg_dweek_bounds("夜勤グループ","S＋☆","木",11,91).
point_sg_dweek_bounds("夜勤グループ","S＋☆","金",11,91).
point_sg_dweek_bounds("夜勤グループ","S＋☆","土",11,91).
point_sg_dweek_bounds("夜勤グループ","S＋☆","祝日",11,91).

% Num of shifts ---------------------------------------------------------------
% Staff 1: 
shift_bounds(1,"日",1,20). shift_bounds(1,"N",0,2). shift_bounds(1,"J",0,2).
shift_bounds(1,"S",0,2). shift_bounds(1,"★",0,0). shift_bounds(1,"☆",0,0).
shift_bounds(1,"P",0,0). shift_bounds(1,"○",8,8).
shift_diff_bounds(1,"N","J",0,0).
% Staff 2: 平日日勤、土日祝日休み　夜勤１回金土のみ
shift_bounds(2,"日",1,20). shift_bounds(2,"N",0,0). shift_bounds(2,"J",0,0).
shift_bounds(2,"S",0,0). shift_bounds(2,"★",0,1). shift_bounds(2,"☆",0,1).
shift_bounds(2,"P",0,0). shift_bounds(2,"○",8,8).
shift_diff_bounds(2,"N","J",0,0).
% Staff 3: 看護師15番看護師との夜勤禁止
shift_bounds(3,"日",1,17). shift_bounds(3,"N",1,3). shift_bounds(3,"J",1,3).
shift_bounds(3,"S",1,3). shift_bounds(3,"★",0,0). shift_bounds(3,"☆",0,0).
shift_bounds(3,"P",0,1). shift_bounds(3,"○",8,8).
shift_diff_bounds(3,"N","J",0,0).
% Staff 4: 金・土の★☆夜勤月2-3回
shift_bounds(4,"日",1,18). shift_bounds(4,"N",0,0). shift_bounds(4,"J",0,0).
shift_bounds(4,"S",0,0). shift_bounds(4,"★",1,3). shift_bounds(4,"☆",1,3).
shift_bounds(4,"P",0,0). shift_bounds(4,"○",8,8).
shift_diff_bounds(4,"N","J",0,0).
% Staff 5: 月・木がＳ禁止　夜勤月2-3回
shift_bounds(5,"日",1,17). shift_bounds(5,"N",1,3). shift_bounds(5,"J",1,3).
shift_bounds(5,"S",1,3). shift_bounds(5,"★",0,0). shift_bounds(5,"☆",0,0).
shift_bounds(5,"P",0,1). shift_bounds(5,"○",8,8).
shift_diff_bounds(5,"N","J",0,0).
% Staff 6: 土日祝日のみN,P可、平日のみS可
shift_bounds(6,"日",1,17). shift_bounds(6,"N",1,4). shift_bounds(6,"J",1,4).
shift_bounds(6,"S",1,4). shift_bounds(6,"★",0,0). shift_bounds(6,"☆",0,0).
shift_bounds(6,"P",0,1). shift_bounds(6,"○",8,8).
shift_diff_bounds(6,"N","J",0,0).
% Staff 7: ＪＳは（希望優先）　夜勤月2-3回
shift_bounds(7,"日",1,17). shift_bounds(7,"N",1,3). shift_bounds(7,"J",1,3).
shift_bounds(7,"S",1,3). shift_bounds(7,"★",0,0). shift_bounds(7,"☆",0,0).
shift_bounds(7,"P",0,1). shift_bounds(7,"○",8,8).
shift_diff_bounds(7,"N","J",0,0).
% Staff 8: 8/7～産休
shift_bounds(8,"日",0,20). shift_bounds(8,"N",0,0). shift_bounds(8,"J",0,0).
shift_bounds(8,"S",0,0). shift_bounds(8,"★",0,0). shift_bounds(8,"☆",0,0).
shift_bounds(8,"P",0,0). shift_bounds(8,"○",8,8).
shift_diff_bounds(8,"N","J",0,0).
% Staff 9: 木曜日休み希望なくなりました
shift_bounds(9,"日",1,17). shift_bounds(9,"N",1,6). shift_bounds(9,"J",1,6).
shift_bounds(9,"S",1,6). shift_bounds(9,"★",0,0). shift_bounds(9,"☆",0,0).
shift_bounds(9,"P",0,2). shift_bounds(9,"○",8,8).
shift_diff_bounds(9,"N","J",0,0).
% Staff 10: 
shift_bounds(10,"日",1,17). shift_bounds(10,"N",1,6). shift_bounds(10,"J",1,6).
shift_bounds(10,"S",1,6). shift_bounds(10,"★",0,0). shift_bounds(10,"☆",0,0).
shift_bounds(10,"P",0,2). shift_bounds(10,"○",8,8).
shift_diff_bounds(10,"N","J",0,0).
% Staff 11: 
shift_bounds(11,"日",1,17). shift_bounds(11,"N",1,6). shift_bounds(11,"J",1,6).
shift_bounds(11,"S",1,6). shift_bounds(11,"★",0,0). shift_bounds(11,"☆",0,0).
shift_bounds(11,"P",0,2). shift_bounds(11,"○",8,8).
shift_diff_bounds(11,"N","J",0,0).
% Staff 12: 
shift_bounds(12,"日",1,17). shift_bounds(12,"N",1,6). shift_bounds(12,"J",1,6).
shift_bounds(12,"S",1,6). shift_bounds(12,"★",0,0). shift_bounds(12,"☆",0,0).
shift_bounds(12,"P",0,2). shift_bounds(12,"○",8,8).
shift_diff_bounds(12,"N","J",0,0).
% Staff 13: 夜勤は28番と一緒（月2回ほど）
shift_bounds(13,"日",1,17). shift_bounds(13,"N",1,6). shift_bounds(13,"J",1,6).
shift_bounds(13,"S",1,6). shift_bounds(13,"★",0,0). shift_bounds(13,"☆",0,0).
shift_bounds(13,"P",0,2). shift_bounds(13,"○",8,8).
shift_diff_bounds(13,"N","J",0,0).
% Staff 14: 夜勤は32番と一緒（月2回ほど）
shift_bounds(14,"日",1,17). shift_bounds(14,"N",1,6). shift_bounds(14,"J",1,6).
shift_bounds(14,"S",1,6). shift_bounds(14,"★",0,0). shift_bounds(14,"☆",0,0).
shift_bounds(14,"P",0,2). shift_bounds(14,"○",8,8).
shift_diff_bounds(14,"N","J",0,0).
% Staff 15: 
shift_bounds(15,"日",1,17). shift_bounds(15,"N",1,6). shift_bounds(15,"J",1,6).
shift_bounds(15,"S",1,6). shift_bounds(15,"★",0,0). shift_bounds(15,"☆",0,0).
shift_bounds(15,"P",0,2). shift_bounds(15,"○",8,8).
shift_diff_bounds(15,"N","J",0,0).
% Staff 16: 夜勤は31番と一緒（月2回ほど）
shift_bounds(16,"日",0,17). shift_bounds(16,"N",1,6). shift_bounds(16,"J",1,6).
shift_bounds(16,"S",1,6). shift_bounds(16,"★",0,0). shift_bounds(16,"☆",0,0).
shift_bounds(16,"P",0,2). shift_bounds(16,"○",8,8).
shift_diff_bounds(16,"N","J",0,0).
% Staff 17: 夜勤は30番と一緒（月2回ほど）
shift_bounds(17,"日",1,17). shift_bounds(17,"N",1,6). shift_bounds(17,"J",1,6).
shift_bounds(17,"S",1,6). shift_bounds(17,"★",0,0). shift_bounds(17,"☆",0,0).
shift_bounds(17,"P",0,2). shift_bounds(17,"○",8,8).
shift_diff_bounds(17,"N","J",0,0).
% Staff 18: 夜勤は29番と一緒（月2回ほど）
shift_bounds(18,"日",1,17). shift_bounds(18,"N",1,6). shift_bounds(18,"J",1,6).
shift_bounds(18,"S",1,6). shift_bounds(18,"★",0,0). shift_bounds(18,"☆",0,0).
shift_bounds(18,"P",0,2). shift_bounds(18,"○",8,8).
shift_diff_bounds(18,"N","J",0,0).
% Staff 19: 
shift_bounds(19,"日",1,17). shift_bounds(19,"N",1,6). shift_bounds(19,"J",1,6).
shift_bounds(19,"S",1,6). shift_bounds(19,"★",0,0). shift_bounds(19,"☆",0,0).
shift_bounds(19,"P",0,2). shift_bounds(19,"○",8,8).
shift_diff_bounds(19,"N","J",0,0).
% Staff 20: 9/24まで５西勤務
shift_bounds(20,"日",1,17). shift_bounds(20,"N",1,6). shift_bounds(20,"J",1,6).
shift_bounds(20,"S",1,6). shift_bounds(20,"★",0,0). shift_bounds(20,"☆",0,0).
shift_bounds(20,"P",0,2). shift_bounds(20,"○",8,8).
shift_diff_bounds(20,"N","J",0,0).
% Staff 21: 9/25から５西勤務
shift_bounds(21,"日",1,17). shift_bounds(21,"N",1,6). shift_bounds(21,"J",1,6).
shift_bounds(21,"S",1,6). shift_bounds(21,"★",0,0). shift_bounds(21,"☆",0,0).
shift_bounds(21,"P",0,2). shift_bounds(21,"○",8,8).
shift_diff_bounds(21,"N","J",0,0).
% Staff 22: 
shift_bounds(22,"日",1,17). shift_bounds(22,"N",1,6). shift_bounds(22,"J",1,6).
shift_bounds(22,"S",1,6). shift_bounds(22,"★",0,0). shift_bounds(22,"☆",0,0).
shift_bounds(22,"P",0,2). shift_bounds(22,"○",8,8).
shift_diff_bounds(22,"N","J",0,0).
% Staff 23: 
shift_bounds(23,"日",1,17). shift_bounds(23,"N",1,6). shift_bounds(23,"J",1,6).
shift_bounds(23,"S",1,6). shift_bounds(23,"★",0,0). shift_bounds(23,"☆",0,0).
shift_bounds(23,"P",0,2). shift_bounds(23,"○",8,8).
shift_diff_bounds(23,"N","J",0,0).
% Staff 24: 
shift_bounds(24,"日",1,17). shift_bounds(24,"N",1,6). shift_bounds(24,"J",1,6).
shift_bounds(24,"S",1,6). shift_bounds(24,"★",0,0). shift_bounds(24,"☆",0,0).
shift_bounds(24,"P",0,2). shift_bounds(24,"○",8,8).
shift_diff_bounds(24,"N","J",0,0).
% Staff 25: 
shift_bounds(25,"日",1,17). shift_bounds(25,"N",1,6). shift_bounds(25,"J",1,6).
shift_bounds(25,"S",1,6). shift_bounds(25,"★",0,0). shift_bounds(25,"☆",0,0).
shift_bounds(25,"P",0,2). shift_bounds(25,"○",8,8).
shift_diff_bounds(25,"N","J",0,0).
% Staff 26: 
shift_bounds(26,"日",1,17). shift_bounds(26,"N",1,6). shift_bounds(26,"J",1,6).
shift_bounds(26,"S",1,6). shift_bounds(26,"★",0,0). shift_bounds(26,"☆",0,0).
shift_bounds(26,"P",0,2). shift_bounds(26,"○",8,8).
shift_diff_bounds(26,"N","J",0,0).
% Staff 27: 8月中は夜勤５人（１年生２人は可）
shift_bounds(27,"日",1,17). shift_bounds(27,"N",1,4). shift_bounds(27,"J",1,4).
shift_bounds(27,"S",1,4). shift_bounds(27,"★",0,0). shift_bounds(27,"☆",0,0).
shift_bounds(27,"P",0,1). shift_bounds(27,"○",8,8).
shift_diff_bounds(27,"N","J",0,0).
% Staff 28: 8月中は夜勤５人（１年生２人は可）
shift_bounds(28,"日",1,17). shift_bounds(28,"N",1,4). shift_bounds(28,"J",1,4).
shift_bounds(28,"S",1,4). shift_bounds(28,"★",0,0). shift_bounds(28,"☆",0,0).
shift_bounds(28,"P",0,1). shift_bounds(28,"○",8,8).
shift_diff_bounds(28,"N","J",0,0).
% Staff 29: 8月中は夜勤５人（１年生２人は可）
shift_bounds(29,"日",1,17). shift_bounds(29,"N",1,4). shift_bounds(29,"J",1,4).
shift_bounds(29,"S",1,4). shift_bounds(29,"★",0,0). shift_bounds(29,"☆",0,0).
shift_bounds(29,"P",0,1). shift_bounds(29,"○",8,8).
shift_diff_bounds(29,"N","J",0,0).
% Staff 30: 8月中は夜勤５人（１年生２人は可）
shift_bounds(30,"日",1,17). shift_bounds(30,"N",1,4). shift_bounds(30,"J",1,4).
shift_bounds(30,"S",1,4). shift_bounds(30,"★",0,0). shift_bounds(30,"☆",0,0).
shift_bounds(30,"P",0,1). shift_bounds(30,"○",8,8).
shift_diff_bounds(30,"N","J",0,0).
% Staff 31: 8月中は夜勤５人（１年生２人は可）
shift_bounds(31,"日",1,17). shift_bounds(31,"N",1,4). shift_bounds(31,"J",1,4).
shift_bounds(31,"S",1,4). shift_bounds(31,"★",0,0). shift_bounds(31,"☆",0,0).
shift_bounds(31,"P",0,1). shift_bounds(31,"○",8,8).
shift_diff_bounds(31,"N","J",0,0).
% Staff 32: 8月中は夜勤５人（１年生２人は可）
shift_bounds(32,"日",1,17). shift_bounds(32,"N",1,4). shift_bounds(32,"J",1,4).
shift_bounds(32,"S",1,4). shift_bounds(32,"★",0,0). shift_bounds(32,"☆",0,0).
shift_bounds(32,"P",0,1). shift_bounds(32,"○",8,8).
shift_diff_bounds(32,"N","J",0,0).

% Recommended pairs -----------------------------------------------------------
recommended_night_pair(13, 28). recommended_night_pair(14, 32).
recommended_night_pair(16, 31). recommended_night_pair(17, 30).
recommended_night_pair(18, 29).

% Forbidden night pairs -------------------------------------------------------
forbidden_night_pair(3, 15).

% Positive shifts -------------------------------------------------------------
% Staff 2
pos_shift(2,"日", "○"). pos_shift(2,"月", "日"). pos_shift(2,"月", "○").
pos_shift(2,"火", "日"). pos_shift(2,"火", "○"). pos_shift(2,"水", "日").
pos_shift(2,"水", "○"). pos_shift(2,"木", "日"). pos_shift(2,"木", "○").
pos_shift(2,"金", "日"). pos_shift(2,"金", "○"). pos_shift(2,"土", "○").
pos_shift(2,"祝", "◎").

% Negative shifts -------------------------------------------------------------
% Staff 4
neg_shift(4,"日", "★"). neg_shift(4,"日", "☆"). neg_shift(4,"月", "★").
neg_shift(4,"月", "☆"). neg_shift(4,"火", "★"). neg_shift(4,"火", "☆").
neg_shift(4,"水", "★"). neg_shift(4,"水", "☆"). neg_shift(4,"木", "★").
neg_shift(4,"木", "☆"). neg_shift(4,"金", "☆"). neg_shift(4,"土", "★").
% Staff 5
neg_shift(5,"月", "S"). neg_shift(5,"木", "S").
% Staff 6
neg_shift(6,"日", "S"). neg_shift(6,"月", "N"). neg_shift(6,"月", "P").
neg_shift(6,"火", "N"). neg_shift(6,"火", "P"). neg_shift(6,"水", "N").
neg_shift(6,"水", "P"). neg_shift(6,"木", "N"). neg_shift(6,"木", "P").
neg_shift(6,"金", "N"). neg_shift(6,"金", "P"). neg_shift(6,"土", "S").
neg_shift(6,"祝", "S").
% Staff 7
neg_shift(7,"日", "☆"). neg_shift(7,"月", "★"). neg_shift(7,"火", "★").
neg_shift(7,"火", "☆"). neg_shift(7,"水", "★"). neg_shift(7,"水", "☆").
neg_shift(7,"木", "★"). neg_shift(7,"木", "☆"). neg_shift(7,"金", "★").
neg_shift(7,"金", "☆"). neg_shift(7,"土", "★"). neg_shift(7,"土", "☆").
