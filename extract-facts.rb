#!/usr/bin/ruby
# coding: utf-8
require 'optparse'
require 'roo'
require 'holiday_japan'

opts = OptionParser.new
$verb = false
$disable_request = false
opts.banner = "Usage: #{File.basename(__FILE__)} [options] input.xlsx"
opts.on('-v',           "verbose mode") {|v| $verb = true }
opts.on('--no-request', "does not generate staff's request") {|v| $disable_request = true }

opts.parse!(ARGV)
if ARGV.empty?
    puts opts.help
    exit
end

class String
    # 全角を2,半角を1とした、文字列の長さを導出
    def width
      self.each_char.map{|c| c.bytesize == 1 ? 1 : 2}.reduce(0, &:+)
    end
end
    
WIDTH = 79
def puts_facts(facts)
    s = ""
    facts.each { |fact|
        if (s + fact).width + 1 > WIDTH and fact.to_s.width < WIDTH
            puts s
            s = fact
        elsif fact.to_s.width > WIDTH
            puts s
            puts fact
            s = ""
        elsif s == ""
            s += fact
        else
            s += " " + fact
        end
    }
    puts s
end

def puts_fact(fact, comments = nil)
    fact += "\t% #{comments}" unless comments.nil?
    puts fact
end

def puts_section(section)
    puts
    puts "% #{section} #{'-' * (WIDTH - section.size - 3)}"
end

def dayid(date)
    # 日付を 2022/1/1 からの日数とする（整数として表現したい）
    (date - Date.new(2022, 1, 1) + 1).to_i
end

def weekday(date)
    ["日","月","火","水","木","金","土"][date.wday]
end

# 日付の解析
def parse_dates(book)
    idx = book.sheets.find_index { |name| name =~ /.*希望勤務.*/ }
    raise "not found '希望勤務' sheet " if idx.nil?
    sheet = book.sheet(idx)
    
    # 勤務表の開始日
    $start_date = sheet.cell('B',1)
    raise "開始日 '#{$start_date}' is not Date" unless $start_date.is_a?(Date)
    # 勤務表の終了日
    $end_date = sheet.cell('D',1)
    raise "終了日 '#{$end_date}' is not Date" unless $end_date.is_a?(Date)

    # 日付・曜日の抽出
    start_column = 5
    end_column = sheet.last_column
    dates = []
    (start_column..end_column).each { |c|
        date = sheet.cell(1,c)
        if !date.is_a?(Date)                
            break
        elsif dates.empty?
            dates.push(date)
        elsif dates.last < date
            dates.push(date)
        else
            break
        end
    }

    puts_section("Dates")
    dates.each { |d| 
        puts_fact("base_date(#{dayid(d)},\"#{weekday(d)}\").", d.to_s )
    }
    puts "% 前月のシフト表の対象日"
    puts_facts dates.select { |d| d < $start_date }.map { |d| "prev_date(#{dayid(d)},\"#{weekday(d)}\")." }
    puts "% シフト表の作成対象日"
    puts_facts dates.select { |d| $start_date <= d && d <= $end_date }.map { |d| "date(#{dayid(d)},\"#{weekday(d)}\")." }
    puts "% 翌月のシフト表の対象日"
    puts_facts dates.select { |d| $end_date < d }.map { |d| "next_date(#{dayid(d)},\"#{weekday(d)}\")." }

    # 祝日の出力
    puts "% 祝日"
    puts_facts dates.select { |d| HolidayJapan.check(d) }.map { |d| "national_holiday(#{dayid(d)},\"#{weekday(d)}\")." }
end

# スタッフの解析
def parse_staffs(book)
    idx = book.sheets.find_index { |name| name =~ /.*看護師別シフト数.*/ }
    raise "not found '看護師別シフト数' sheet " if idx.nil?
    sheet = book.sheet(idx)

    second_row = sheet.row(2)
    # 番号の列
    id_col = second_row.index("番号") + 1
    # 氏名の列
    name_col = second_row.index("氏名") + 1
    # 職名の列
    job_col = second_row.index("職名") + 1
    # 利用者CDの列
    cd_col = second_row.index("利用者CD") + 1
    # 点数の列
    point_col = second_row.index("点数") + 1

    # スタッフ情報の抽出
    row = 3   # スタッフ定義の開始行番号
    facts = []
    $staffs = {}
    while (id = sheet.cell(row, id_col)).to_s =~ /\d+/
        name  = sheet.cell(row, name_col).tr(' ','　')
        break if name == ""
        job   = sheet.cell(row, job_col)
        cd    = sheet.cell(row, cd_col)
        point = sheet.cell(row, point_col)
        point = 0 if point.nil?
        facts.push("staff(#{id},\"#{name}\",\"#{job}\",\"#{cd}\",#{point}).")
        $staffs[id] = { id: id, name: name, job: job, cd: cd, point: point }
        row += 1
    end

    puts_section("Staffs")
    puts_facts(facts)
end

# シフト記号の統一化処理
def validate_shift_sign(shift)
    # 全角英字は半角に
    shift = shift.tr('ａ-ｚＡ-Ｚ／〇◯', 'a-zA-Z/○○') 
end

# シフト記号
def parse_shift_sign(sheet)
    puts_section("Shifts")
    shifts    = sheet.column(1)[1..-1]
    meanings  = sheet.column(2)[1..-1]
    comments1 = sheet.column(3)[1..-1]
    comments2 = sheet.column(4)[1..-1]
    shifts.each_with_index { |shift, i|
        shift = validate_shift_sign(shift)
        comment  = meanings[i]
        comment += ", " + comments1[i] unless comments1[i].nil?
        comment += ", " + comments2[i] unless comments2[i].nil?
        puts_fact("shift(\"#{shift}\").", comment)
    }
end

# シフトの制約
def parse_shift_constraints(sheet)
    puts_section("Shift constraints")
    rows = sheet.row(1)[0..-1]
    processed = []
    rows.each_with_index { |type,idx|
        next if processed.include?(type)  # 出力済みならスキップ（結合セルはすべて同じ値を持つため）
        idx += 1  # Excel の列番号に変換
        puts "% #{type}"
        case type
        when '連続勤務可能日数'
            days = sheet.cell(3,idx).to_i
            puts_fact("consecutive_work_ub(#{days}).")
        when '必須パターン'
            patterns = sheet.column(idx)[2..-1]
            patterns.delete(nil)
            patterns.map! { |e| e.strip }
            patterns.map! { |e| validate_shift_sign(e) }
            patterns.each { |pattern|
                len    = pattern.size
                shifts = pattern.chars.map { |e| "\"#{e}\""}.join(',')
                puts_fact("mandatory_pattern_#{len}(#{shifts}).")
            }
        when '禁止パターン'
            patterns = sheet.column(idx)[2..-1]
            patterns.delete(nil)
            patterns.map! { |e| e.strip }
            patterns.map! { |e| validate_shift_sign(e) }
            patterns.each { |pattern|
                len    = pattern.size
                shifts = pattern.chars.map { |e| "\"#{e}\""}.join(',')                
                puts_fact("forbidden_pattern(#{shifts}).")
            }
            patterns.each { |pattern|
                len    = pattern.size
                shifts = pattern.chars.map.with_index { |e,i| "#{i},\"#{e}\""}
                puts_fact("pattern(\"#{pattern}\",#{len}).")
                shifts.each { |s|
                    puts_fact("pattern(\"#{pattern}\",#{s}).")
                }
                puts_fact("forbidden_pattern(\"#{pattern}\").")
            }
        when '推奨パターン'
            patterns = sheet.column(idx+0)[2..-1]
            comments = sheet.column(idx+1)[2..-1]
            patterns.delete(nil)
            patterns.map! { |e| e.strip }
            patterns.map! { |e| validate_shift_sign(e) }
            patterns.each_with_index { |pattern,i|
                len     = pattern.size
                shifts  = pattern.chars.map { |e| "\"#{e}\""}.join(',')
                comment = comments[i]
                puts_fact("recommended_pattern_#{len}(#{shifts}).", comment)
            }
        when '前日・翌日可能シフト'
            pred_shifts = sheet.column(idx+0)[2..-1]
            base_shifts = sheet.column(idx+1)[2..-1]
            succ_shifts = sheet.column(idx+2)[2..-1]
            base_shifts.delete(nil)
            base_shifts.map! { |e| e.strip }
            base_shifts.map! { |e| validate_shift_sign(e) }
            base_shifts.each_with_index { |base,i|
                preds = pred_shifts[i]
                unless preds.nil?
                    preds = preds.strip.split(',')
                    preds = preds.map { |e| validate_shift_sign(e) }
                    preds.each { |pred|
                        puts_fact("pred_shift(\"#{pred}\",\"#{base}\").")
                    }
                end
                succs = succ_shifts[i]
                unless succs.nil?
                    succs = succs.strip.split(',')
                    succs = succs.map { |e| validate_shift_sign(e) }
                    succs.each { |succ|
                        puts_fact("succ_shift(\"#{base}\",\"#{succ}\").")
                    }
                end
            }
        when 'パターン割当数の最小・最大値'
            patterns = sheet.column(idx+0)[2..-1]
            mins     = sheet.column(idx+1)[2..-1]
            maxs     = sheet.column(idx+2)[2..-1]
            patterns.delete(nil)
            patterns.map! { |e| e.strip }
            patterns.map! { |e| validate_shift_sign(e) }
            patterns.each_with_index { |pattern,i|
                pattern = pattern.chars.map { |e| "\"#{e}\"" }
                len     = pattern.size
                lb      = mins[i]
                ub      = maxs[i]
                puts_fact("num_patterns_#{len}(#{pattern.join(',')}).")
                unless lb.nil?
                    puts_fact("num_patterns_#{len}_lb(#{pattern.join(',')}, #{lb}).")
                end
                unless ub.nil?
                    puts_fact("num_patterns_#{len}_ub(#{pattern.join(',')}, #{ub}).")
                end
            }
            patterns.each { |pattern|
                len    = pattern.size
                shifts = pattern.chars.map.with_index { |e,i| "#{i},\"#{e}\""}
                puts_fact("pattern(\"#{pattern}\",#{len}).")
                shifts.each { |s|
                    puts_fact("pattern(\"#{pattern}\",#{s}).")
                }             
            }
            patterns.each_with_index { |pattern,i|
                lb = mins[i]
                ub = maxs[i]
                puts_fact("pattern_lb(\"#{pattern}\", #{lb}).") unless lb.nil?
                puts_fact("pattern_ub(\"#{pattern}\", #{ub}).") unless ub.nil?
            }

        else
            raise  "unexpected shift constraint: #{type}"
        end
        processed.push(type)
    }
end

# メンバー定義の解析
def parse_members(s)
    org_s = s
    members = []
    s = s.split(',')
    while s.size > 0
        t = s.shift
        if t =~ /\d+/
            members.push(t.to_i)
        elsif t == "…"            
            from = members.last
            to   = s.shift.to_i
            raise "unknown member definition: #{members}" if from.nil? or to.nil?
            ((from+1)..to).each { |m| members.push(m) }
        end
    end
    members
end

def get_shift_members(shift)
    shift = shift.gsub("＋", "+").gsub("－", "-")
    shift.split(/\+|-/)
end

def is_shift_formula(shift)
    get_shift_members(shift).size > 1
end

def parse_shift_formula(s)
    s = s.gsub("＋", "+").gsub("－", "-")
    # 現状では，加算式 or 減算式のいずれか
    if s.include?("+") && !s.include?("-")
        s = s.split("+").map { |e| "\"#{e}\"" }
        "add(#{s.join(',')})"
    elsif !s.include?("+") && s.include?("-")
        s = s.split("-").map { |e| "\"#{e}\"" }
        "sub(#{s.join(',')})"
    elsif !s.include?("+") && !s.include?("-")
        "\"#{s}\""
    else
        raise "unexpected shift formula: #{s}"
    end
end

def parse_num_staffs(sheet)

    # グループ名の抽出
    raw_group_names = sheet.row(1)[1..-1].map { |e| e.strip.gsub(/\s+|　/,'') }
    group_names   = raw_group_names.uniq   # 結合セルを1つに
    group_columns = group_names.map { |e| raw_group_names.count(e) }  # グループ定義の列数
    # グループが定義されている列番号の範囲を算出
    group_ranges  = group_columns.reduce([]) { |res,v| 
        from = res.last ? res.last.end : 2  # シート上で2列目から定義が始まる
        to   = from + v
        res.push(from...to)
        res 
    }
    puts_section("Groups")
    puts_facts group_names.map { |name| "group(\"#{name}\")." }

    # グループ定義の抽出
    group_members = []
    group_names.each_with_index { |group_name, i|
        members = sheet.cell(2, group_ranges[i].first)
        members = parse_members(members)
        group_members.push(members)
    }
    group_names.each_with_index { |name, idx|
        members = group_members[idx]
        puts_facts members.map { |s| "group(\"#{name}\",#{s})." }
    }

    # 各グループ・各シフト・各曜日ごとのスタッフ数の下限・上限
    puts_section("Num of staffs")
    group_names.each_with_index { |group, idx|        
        group_ranges[idx].each { |col|
            next if col % 2 == 1  # シフトごとの下限・上限は偶数列・奇数列に書いてある
            shift = sheet.cell(3, col)
            type  = sheet.cell(4, col)
            case type
            when "人数" then type = "staff" 
            when "点数" then type = "point"
            else raise "unknown type: #{type}"
            end
            puts "% #{group}, #{shift}"
            comment = sheet.cell(14, col)
            puts "% #{comment.gsub("\n","\n% ")}" unless comment.nil?
            if is_shift_formula(shift)
                # シフトの所属関係の定義
                shifts = get_shift_members(shift)
                shifts.each { |s|
                    puts_fact("shift_group(\"#{shift}\", \"#{s}\").")
                }
            end
            # 各曜日（日～土，祝日の８つ）
            facts = []
            (6..13).each { |row|
                dweek = sheet.cell(row, 1).strip
                lb    = sheet.cell(row, col+0)
                ub    = sheet.cell(row, col+1)
                lb    = 0 if lb.nil?
                if ub.nil?
                    if type == "staff"
                        ub = group_members[idx].size 
                    else
                        ub = group_members[idx].map { |id| $staffs[id][:point] }.sum
                    end
                end
                unless is_shift_formula(shift)
                    facts.push("#{type}_dweek_bounds(\"#{group}\",\"#{shift}\",\"#{dweek}\",#{lb},#{ub}).")                     
                else
                    facts.push("#{type}_sg_dweek_bounds(\"#{group}\",\"#{shift}\",\"#{dweek}\",#{lb},#{ub}).") 
                end
            }
            puts_facts facts
        }
    }    
end

def parse_num_shift(sheet)
    first_row = sheet.row(1)
    second_row = sheet.row(2)

    # 推奨ペアの列
    recommended_pair_col = first_row.index("推奨ペア") + 1
    # 夜勤禁止ペアの列
    forbidden_night_pair_col = first_row.index("夜勤禁止ペア") + 1
    # 看護師のシフト担当数に関するコメント列
    comment_col = first_row.index("説明") + 1
    # 希望シフトの開始列と終了列
    pos_shift_begin = first_row.index("割当可能なシフト（③希望勤務が優先）") + 1
    pos_shift_end = pos_shift_begin + 7
    # 希望しないシフトの開始列と終了列
    neg_shift_begin = first_row.index("割当不可なシフト（③希望勤務が優先）") + 1
    neg_shift_end = neg_shift_begin + 7
    # シフトの開始列と終了列
    shift_begin = second_row.index("最小") + 1
    shift_end = recommended_pair_col - 1

    puts_section("Num of shifts")
    (3..sheet.last_row).each { |r|
        facts   = []
        staff   = sheet.cell(r, 1)
        next unless staff.to_s =~ /\d+/
        name    = sheet.cell(r, 2)
        next if name == ""
        comment = sheet.cell(r, comment_col)

        puts "% Staff #{staff}: #{comment}"
        (shift_begin..shift_end).each { |c|
            next if sheet.cell(2, c) == "最大"
            shift = sheet.cell(1, c)  
            lb    = sheet.cell(r, c+0)
            ub    = sheet.cell(r, c+1)
            lb    = 0  if lb.nil?
            ub    = 28 if ub.nil?
            unless is_shift_formula(shift)
                facts.push("shift_bounds(#{staff},\"#{shift}\",#{lb},#{ub}).")
            else
                shifts = get_shift_members(shift).map { |e| "\"#{e}\"" }
                facts.push("shift_diff_bounds(#{staff},#{shifts.join(',')},#{lb},#{ub}).")
            end
        }
        puts_facts facts
    }

    unless recommended_pair_col.nil?
        puts_section("Recommended pairs")
        pairs = []
        (3..sheet.last_row).each { |r|
            staff = sheet.cell(r, 1)
            next unless staff.to_s =~ /\d+/
            pair = sheet.cell(r, recommended_pair_col)
            next if pair.nil?
            pairs.push([staff,pair])
        }   
        pairs  = pairs.map { |s, t| [s, t].sort }.uniq
        puts_facts pairs.map { |s, t|
            "recommended_night_pair(#{s}, #{t})."
        }
    end

    unless forbidden_night_pair_col.nil?
        puts_section("Forbidden night pairs")
        pairs = []
        (3..sheet.last_row).each { |r|
            staff = sheet.cell(r, 1)
            next unless staff.to_s =~ /\d+/
            pair = sheet.cell(r, forbidden_night_pair_col)
            next if pair.nil?
            pairs.push([staff,pair])
        }   
        pairs  = pairs.map { |s, t| [s, t].sort }.uniq
        puts_facts pairs.map { |s, t|
            "forbidden_night_pair(#{s}, #{t})."
        }
    end
    
    unless pos_shift_begin.nil?
        puts_section("Positive shifts")
        (3..sheet.last_row).each { |r|
            staff = sheet.cell(r, 1)
            next unless staff.to_s =~ /\d+/
            facts = []
            (pos_shift_begin..pos_shift_end).each { |c|
                dweek = sheet.cell(2, c)
                shifts = sheet.cell(r, c)
                next if shifts.nil?
                shifts = shifts.split(',').map { |e| e.strip }
                shifts.each { |shift|
                    facts.push("pos_shift(#{staff},\"#{dweek}\", \"#{shift}\").")
                }
            }
            next if facts.empty?
            puts "% Staff #{staff}"
            puts_facts facts
        }
    end

    unless neg_shift_begin.nil?
        puts_section("Negative shifts")
        (3..sheet.last_row).each { |r|
            staff = sheet.cell(r, 1)
            next unless staff.to_s =~ /\d+/
            facts = []
            (neg_shift_begin..neg_shift_end).each { |c|
                dweek = sheet.cell(2, c)
                shifts = sheet.cell(r, c)
                next if shifts.nil?
                shifts = shifts.split(',').map { |e| e.strip }
                shifts.each { |shift|
                    facts.push("neg_shift(#{staff},\"#{dweek}\", \"#{shift}\").")
                }
            }
            next if facts.empty?
            puts "% Staff #{staff}"
            puts_facts facts
        }
    end
end

def parse_request(sheet)
    puts_section("Staff's requests")
    (3..sheet.last_row).each { |r|
        staff = sheet.cell(r, 1)
        next unless staff.to_s =~ /\d+/
        puts "% Staff #{staff}"
        facts = []
        dates = []  # 終了判定用
        start_column = 5
        end_column = sheet.last_column
        (start_column...end_column).each { |c|
            date = sheet.cell(1, c)
            if !date.is_a?(Date)                
                break
            elsif dates.empty?
                dates.push(date)
            elsif dates.last < date
                dates.push(date)
            else
                break
            end

            # 日付を 2021/1/1 からの日数に変換
            days  = dayid(date)
            shift = sheet.cell(r, c)    
            next if shift.nil? || shift.size == 0
            shift = validate_shift_sign(shift)
            # もし祝日で○なら◎に変換
            shift = "◎" if shift == "○" && HolidayJapan.check(date)
            # もし非祝日で◎なら○に変換
            shift = "○" if shift == "◎" && !HolidayJapan.check(date)
            if date < $start_date
                facts.push("assigned(#{staff}, #{days}, \"#{shift}\").")
            elsif !$disable_request
                facts.push("staff_request(#{staff}, #{days}, \"#{shift}\").")
            end
        }
        puts_facts facts
    }
end

def parse_prev_shift_table(sheet)
    first_row = sheet.row(1)
    begin_col = first_row.index { |e| !e.nil? } 
    end_col   = first_row.rindex { |e| !e.nil? } 
    
    dates  = sheet.row(1)[begin_col..end_col]    
    dweeks = dates.map { |e| ["日","月","火","水","木","金","土"][e.wday] }

    # 日付を 2022/1/1 からの日数とする（整数として表現したい）
    dates = dates.map { |d| (d - Date.new(2022, 1, 1) + 1).to_i }
    
    puts_section("Dates in previous shift table")
    puts_facts dates.zip(dweeks).map { |date,day| "base_date(#{date},\"#{day}\")." }
    puts_facts dates.zip(dweeks).map { |date,day| "prev_date(#{date},\"#{day}\")." }

    puts_section("Previous shift table")
    (3..sheet.last_row).each { |r|
        staff   = sheet.cell(r, 1)
        next unless staff.to_s =~ /\d+/
        puts "% Staff #{staff}"
        facts = []
        ((begin_col+1)..(end_col+1)).each { |c|
            date  = sheet.cell(1, c)
            next if date.nil?
            # 日付を 2021/1/1 からの日数に変換
            date  = (date - Date.new(2022, 1, 1) + 1).to_i
            shift = sheet.cell(r, c)            
            next if shift.nil?
            shift = validate_shift_sign(shift)
            facts.push("assigned(#{staff}, #{date}, \"#{shift}\").")
        }
        puts_facts facts
    }
end

def parse_notes(sheet)
    puts_section("Notes")
    sheet.column(1).each { |comment|
        puts "% #{comment}"
    }
end

def parse_nsp(input)
    book = Roo::Excelx.new(input, {:expand_merged_ranges => true})  # 結合セルには同じ値を持たせる
    parse_dates(book)
    parse_staffs(book)
    book.each_with_pagename { |name, sheet|
        case name
        when /.*シフト記号.*/             then parse_shift_sign(sheet)
        when /.*シフトの制約.*/           then parse_shift_constraints(sheet)
        when /.*曜日グループ別シフト数.*/ then parse_num_staffs(sheet)
        when /.*看護師別シフト数.*/       then parse_num_shift(sheet)
        when /.*希望勤務.*/               then parse_request(sheet)
        when /.*前月勤務表.*/             then #parse_prev_shift_table(sheet)
        when /.*補足事項.*/               then parse_notes(sheet)        
        #else raise "unknown sheet: #{name}"
        end        
    }
end

input = ARGV.shift
nsp = parse_nsp(input)




