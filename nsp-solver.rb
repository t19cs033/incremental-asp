#!/usr/bin/env ruby
require 'optparse'
require "open3"
require 'rainbow/refinement'
using Rainbow

require 'holiday_japan'
require 'rubyXL'
require 'rubyXL/convenience_methods'

opt = OptionParser.new
$output = nil
$print_assignment = false
$print_assignment_freq = false
$init_penalty = nil
$threads = 1
$time_limit = 0
$verb = :verb

opt.banner += ' FILES [-- clingo options]'
opt.on('-o FILE.xlsx',     "output shift table") { |v| $output = v }
opt.on('-a',               "print assignment")  { |v| $print_assignment = true }
opt.on('-A',               "print assignment frequency distribution") { |v| $print_assignment_freq = true }
opt.on('-p NUM',           "initial penalty")   { |v| $init_penalty = v.to_i }
opt.on('-t NUM',           "num of threads")    { |v| $threads = v.to_i }
opt.on('--time-limit NUM', "set time limit to NUM seconds") { |v| $time_limit = v.to_i }
opt.on('-v',               "verbose mode")      { |v| $verb = :verb }
opt.on('-V',               "very verbose mode") { |v| $verb = :very_verb }

# clingo options 
# --opt-mode=ignore  目的関数を無視（＝最初の解で停止）
# --config=trendy --dom-mod=neg,opt --heu=domain  decision 変数に偽を割り当て
# --stats  統計量を表示

opt.parse!(ARGV)
if ARGV.empty?
    puts opt.help
    exit
end

$workbook = nil
$workbook = RubyXL::Workbook.new unless $output.nil?

$warning_fg = 'ffffff'
$warning_bg = 'e27073'

$last_sol = nil

# ネストしたハッシュを生成可能にする (https://stackoverflow.com/questions/3338979/one-liner-nested-hash-creation-in-ruby-i-come-from-perl)
class Hash
    def self.recursive
      new { |hash, key| hash[key] = recursive }
    end
end
  
# 数値の配列を範囲の配列に変換する（https://stackoverflow.com/questions/20847212/how-to-convert-an-array-of-number-into-ranges）
class Array
    def to_rs
      res = [ Range.new(first,first) ]
      self[1..-1].sort.each{|item|
        if res.last.max == (item -1)
          res << Range.new(res.pop.min, item)
        else
          res << Range.new(item, item)
        end
      }
      res
    end
end
  
class String
    # 全角を2,半角を1とした、文字列の長さを導出
    def width
      self.each_char.map{|c| c.bytesize == 1 ? 1 : 2}.reduce(0, &:+)
    end
end

def add_weekend_color(str, day)
    return str unless STDOUT.isatty
    case day
    when "土" then str.blue 
    when "日" then str.red  
    else str
    end
end

def print_table(total_penalty, assignment, head = "")    
    table           = assignment[:table]    
    base_dates      = assignment[:base_dates]
    dweeks          = assignment[:dweeks]
    prev_dates      = assignment[:prev_dates]
    dates           = assignment[:dates]
    next_dates      = assignment[:next_dates]
    penalties       = assignment[:penalties]
    violations      = assignment[:violations]

    staffs = table.keys.sort { |a,b| [a.size, a] <=> [b.size, b] }
    if $print_assignment
        puts "#{head} ==============================================================================================="
        assignment[:facts].each { |fact| puts "#{head} #{fact}" }
    end
    if $print_assignment_freq
        freq = assignment[:facts].map { |fact| fact.slice(/\w+/) }.group_by(&:itself).map{|k, v| [k, v.size]}.sort_by{|k, v| -v}.to_h
        freq.each { |k,v| puts "#{head} #{v}: #{k}" } 
    end
    
    # debug
    #puts "violations = #{violations}"

    puts "#{head} -----" + "----" * prev_dates.size + "+" + "----" * dates.size + "+" + "----" * next_dates.size
    dates_header  = base_dates.map { |d| add_weekend_color(sprintf("%-3d ", d), dweeks[d]) }
    days_header   = base_dates.map { |d| add_weekend_color(sprintf("%3d ", (Date.new(2021, 12, 31)+d).day), dweeks[d]) }
    dweeks_header = base_dates.map { |d| add_weekend_color(" #{dweeks[d]} ", dweeks[d]) }    
    puts "#{head}      " +
        dates_header[0...prev_dates.size].join + "|" +
        dates_header[prev_dates.size...(prev_dates.size+dates.size)].join + "|" +
        dates_header[(prev_dates.size+dates.size)..-1].join 
    puts "#{head}      " +
        days_header[0...prev_dates.size].join + "|" +
        days_header[prev_dates.size...(prev_dates.size+dates.size)].join + "|" +
        days_header[(prev_dates.size+dates.size)..-1].join 
    puts "#{head}      " +
        dweeks_header[0...prev_dates.size].join + "|" +
        dweeks_header[prev_dates.size...(prev_dates.size+dates.size)].join + "|" +
        dweeks_header[(prev_dates.size+dates.size)..-1].join 
    staffs.each { |staff|
        shifts = base_dates.map { |day| 
            s = table[staff][day]
            s = "--" if s == {}
            s = s.tr('a-zA-Z/', 'ａ-ｚＡ-Ｚ／') # すべて全角に統一                
            s = " #{s} "
            if STDOUT.isatty
                case s
                when /日/ then s = s.black.background(:yellow)
                when /Ｐ/ then s = s.black.background(:khaki)
                when /Ｎ/ then s = s.black.background(:darkorange)
                when /Ｊ/ then s = s.black.background(:aquamarine)
                when /Ｓ/ then s = s.black.background(:darkcyan)                
                when /★/ then s = s.black.background(:cornflower)
                when /☆/ then s = s.black.background(:mediumslateblue)
                when /[○,◎]/ then s = s.white.bright
                when /[研,年,健,特]/ then s = s.red
                end
                if violations[staff][day].size > 0
                    s = s.white.bright.background(:red)
                end
            end              
            s 
        }        
        printf("#{head} %4s %s\n", staff, 
            shifts[0...prev_dates.size].join + "|" + 
            shifts[prev_dates.size...(prev_dates.size+dates.size)].join + "|" +
            shifts[(prev_dates.size+dates.size)..-1].join
        )
    }
    puts "#{head} Penalty: #{total_penalty}"
    penalties = penalties.sort { |a,  b| [-a[:priority], -a[:cost], a[:cause]] <=> [-b[:priority], -b[:cost], b[:cause]] }
    penalties.each { |p| 
        puts "#{head}  #{p[:cost]} #{p[:priority]} #{p[:cause]}"
    }
    puts "#{head} Penalty: #{total_penalty}"

    STDOUT.flush
end

def cell_color(shift)
    fg = '000000'
    bg = 'ffffff'
    case shift
    when /日/ then bg = 'ffcc66'
    when /Ｐ/ then bg = 'ffffaf'
    when /Ｎ/ then bg = 'ffaf00'
    when /Ｊ/ then bg = '87ffd7'
    when /Ｓ/ then bg = '00afaf'
    when /★/ then bg = '87afff'
    when /☆/ then bg = '8787ff'
    when /[○,◎]/ then 
    when /[研,年,健,特]/ then fg = 'e27073'
    end
    return fg, bg
end    

def set_border(cell, weight='thin')
    cell.change_border(:top,    weight)
    cell.change_border(:bottom, weight)
    cell.change_border(:left,   weight)
    cell.change_border(:right,  weight)
end

def set_area_border(sheet, sx, sy, w, h, weight='medium')
    (sx...(sx+w)).each { |x| 
        sheet.sheet_data[sy][x].change_border(:top, weight) 
        sheet.sheet_data[sy+h-1][x].change_border(:bottom, weight) 
    }
    (sy...(sy+h)).each { |y| 
        sheet.sheet_data[y][sx].change_border(:left, weight) 
        sheet.sheet_data[y][sx+w-1].change_border(:right, weight) 
    }
end

def members_to_range(members)
    prev = members[0]
    members.slice_before { |e|
      prev, prev2 = e, prev
      prev2 + 1 != e
    }.map{|b,*,c| c ? (b..c) : (b..b) }    
end

def write_table(total_penalty, assignment, elapsed_time)

    # 新しいシートの追加
    new_sheet_name = "Penalty #{total_penalty}"
    # もし同名のシートがあれば別名化
    no = 0
    loop do
        break if $workbook[new_sheet_name].nil?
        no += 1
        new_sheet_name = "Penalty #{total_penalty} (#{no})"        
    end
    # 新しいシートの追加
    sheet = $workbook.add_worksheet(new_sheet_name)

    table            = assignment[:table]  
    staffs           = assignment[:staffs]  
    base_dates       = assignment[:base_dates]
    dweeks           = assignment[:dweeks]
    prev_dates       = assignment[:prev_dates]
    dates            = assignment[:dates]
    next_dates       = assignment[:next_dates]
    num_weekend_offs = assignment[:num_weekend_offs]
    shifts           = assignment[:shifts]
    groups           = assignment[:groups]
    penalties        = assignment[:penalties]
    violations       = assignment[:violations]

    # シフトの基本的並び順
    base_shift_order = shifts.dup

    # グループメンバーを範囲に変換
    groups.each_key { |gname|
        members = groups[gname][:members]
        groups[gname][:members] = members_to_range(members)
    }

    # 看護師エリア
    staff_area = { 
        sx: 0,
        sy: 1,
        w:  5,
        h:  staffs.size + 1  # with header
    }
    # 勤務表
    shift_table_area = {
        sx: staff_area[:sx] + staff_area[:w],
        sy: 0,
        w:  base_dates.size,
        h:  staffs.size + 2  # with header
    }
    # 看護師ごとの担当シフト数
    staff_shifts_area = {
        sx: shift_table_area[:sx] + shift_table_area[:w],
        sy: 1,
        w:  shifts.size, 
        h:  staffs.size + 1  # with header
    }
    # 看護師ごとの週末休暇数
    weekend_off_area = {
        sx: staff_shifts_area[:sx] + staff_shifts_area[:w],
        sy: 1,
        w:  1, 
        h:  staffs.size + 1  # with header
    }

    # 日毎のシフト数
    day_shifts_area = {
        sx: shift_table_area[:sx] - 1,
        sy: shift_table_area[:sy] + shift_table_area[:h],
        w:  dates.size + 8,  # with header
        h:  groups.keys.reduce(0) { |res, g| 
            res += groups[g][:shifts].map { |k,v| v.size }.sum
        }
    }
    # 出力エリア（ペナルティ含まず）の高さと幅
    area_width  = staff_area[:w] + shift_table_area[:w] + staff_shifts_area[:w] + weekend_off_area[:w]
    area_height = shift_table_area[:h] + day_shifts_area[:h]
    # 出力エリアにセルを追加
    (0...area_width).each { |c|
        (0...area_height).each { |r|
            sheet.add_cell(r, c, "")
        }
    }

    # 看護師の出力 (ID, 氏名, 職名, 利用者CD, 点数)
    staff_header = [[:id, "ID", 3.25], [:name, "氏名", 12], [:job, "職名", 7], [:cd, "利用者CD", 9], [:point, "点数", 3.25]]
    staff_header.each_with_index { |header, x|
        col = x + staff_area[:sx]
        cell = sheet.sheet_data[staff_area[:sy]][col]
        cell.change_contents(header[1])
        set_border(cell)
        sheet.change_column_width(col, header[2])                   # 列幅
        sheet.change_column_font_name(col, 'メイリオ')              # フォント
        sheet.change_column_font_size(col, 10)                      # フォントサイズ
    }
    staffs.keys.sort.each_with_index { |id, y|
        staff = staffs[id]
        staff_header.each_with_index { |header, x|
            cell = sheet.sheet_data[y + staff_area[:sy] + 1][x + staff_area[:sx]]
            cell.change_contents(staff[header[0]])
            set_border(cell)
        }
    }

    # 日付の出力
    base_dates.each_with_index { |d, idx| 
        date = Date.new(2021, 12, 31) + d
        col = idx + shift_table_area[:sx]
        cell = sheet.sheet_data[0][col]
        cell.change_contents(date)
        cell.set_number_format('m/d')        
        cell.change_text_rotation(90)        
        sheet.change_column_width(col, 3.25)                        # 列幅
        sheet.change_column_font_name(col, 'メイリオ')              # フォント
        sheet.change_column_font_size(col, 10)                      # フォントサイズ
        sheet.change_column_horizontal_alignment(col, 'center')     # センタリング
        set_border(cell)                                            # 罫線
    }
    sheet.change_row_height(0, 30 / 0.8)                            # 日付行の高さ
    sheet.change_row_vertical_alignment(0, 'center')                # 日付行をセンタリング

    # 曜日の出力
    base_dates.each_with_index { |d, idx|         
        date = Date.new(2021, 12, 31) + d
        col = idx + shift_table_area[:sx]
        cell = sheet.sheet_data[1][col]
        cell.change_contents(dweeks[d])
        if dweeks[d] == '日' or HolidayJapan.check(date)
            cell.change_font_color('e97376')
        elsif dweeks[d] == '土'
            cell.change_font_color('6699cc')
        end
        set_border(cell)
    }

    # シフト表の出力
    staffs.keys.sort.each_with_index { |id, y|
        staff = staffs[id]
        base_dates.each_with_index { |date, x| 
            shift = table[staff[:id]][date]
            shift = "/" if shift.empty?
            shift = shift.tr('a-zA-Z/', 'ａ-ｚＡ-Ｚ／') # すべて全角に統一                
            cell = sheet.sheet_data[shift_table_area[:sy] + 2 + y][shift_table_area[:sx] + x] 
            cell.change_contents(shift)

            fg, bg = cell_color(shift)
            if violations[staff[:id]][date].size > 0
                fg = $warning_fg
                bg = $warning_bg
            end
            cell.change_font_color(fg)
            cell.change_fill(bg)
            set_border(cell)
        }        
    }

    # 看護師ごとのシフト数の集計のためのシフトの出力
    shifts.each_with_index { |shift, x|
        shift = shift.tr('a-zA-Z/', 'ａ-ｚＡ-Ｚ／')
        col = staff_shifts_area[:sx] + x
        cell = sheet.sheet_data[staff_shifts_area[:sy]][col]
        cell.change_contents(shift)
        fg, bg = cell_color(shift)
        cell.change_font_color(fg)
        cell.change_fill(bg)
        sheet.change_column_width(col, 3.25)                        # 列幅
        sheet.change_column_font_name(col, 'メイリオ')              # フォント
        sheet.change_column_horizontal_alignment(col, 'center')     # センタリング
        set_border(cell)
    }
    # 看護師ごとのシフト数の集計    
    staffs.keys.sort.each_with_index { |id, y|
        staff = staffs[id]
        shifts.each_with_index { |shift, x|
            row = staff_shifts_area[:sy] + y + 1
            col = staff_shifts_area[:sx] + x
            area = RubyXL::Reference.ind2ref(row, shift_table_area[:sx] + prev_dates.size) + ":" + RubyXL::Reference.ind2ref(row, shift_table_area[:sx] + prev_dates.size + dates.size - 1)
            target = RubyXL::Reference.ind2ref(staff_area[:sy], col)
            formula = "=countif(#{area}, #{target})"
            cell = sheet.sheet_data[row][col]
            cell.change_contents(formula)
            cell = sheet.add_cell(row, col, '', formula)
            if violations[staff[:id]][shift].size > 0
                cell.change_font_color($warning_fg)
                cell.change_fill($warning_bg)
            end
            set_border(cell)
        }
    }

    # 週末休日数の出力
    unless num_weekend_offs.nil?
        col = weekend_off_area[:sx]
        row = weekend_off_area[:sy]
        cell = sheet.sheet_data[row][col]
        cell.change_contents("週末休暇")
        sheet.change_column_horizontal_alignment(col, 'center')     # センタリング
        set_border(cell)
        staffs.keys.sort.each_with_index { |id, y|
            staff = staffs[id]
            cell  = sheet.sheet_data[row + y + 1][col]
            cell.change_contents(num_weekend_offs[id])
            if violations[staff].key?(:weekend_off)
                cell.change_font_color($warning_fg)
                cell.change_fill($warning_bg)        
            end
            set_border(cell)
        }
    end

    # 日・グループごとのシフト数の集計のためのシフトの出力
    col = day_shifts_area[:sx]
    row = day_shifts_area[:sy]
    groups.keys.each { |gname|
        group = groups[gname]
        shifts = group[:shifts].keys
        # シフト名をソート
        shifts = shifts.sort_by { |s|
            idx = base_shift_order.index(s)
            idx = base_shift_order.size if idx.nil?
            [idx, s]
        }        
        # 高さ
        h =  group[:shifts].map { |k,v| v.size }.sum
        # グループ名は４列をマージしていれる
        sx = col 
        ex = sx + 3        
        sheet.merge_cells(row, sx, row + h - 1, ex)
        cell = sheet.sheet_data[row][col]
        cell.change_contents(gname)
        cell.change_vertical_alignment('center')
        set_area_border(sheet, sx, row, 4, shifts.size, 'thin')
        shifts.each { |shift|
            group[:shifts][shift].each { |type|
                shift = shift.tr('a-zA-Z/', 'ａ-ｚＡ-Ｚ／')
                # シフト名は３列をマージしていれる
                sx = col + prev_dates.size - 3
                ex = sx + 2
                sheet.merge_cells(row, sx, row, ex)
                cell = sheet.sheet_data[row][sx]
                cell.change_contents(shift)
                set_area_border(sheet, sx, row, 3, 1, 'thin')
                # タイプ名
                case type
                when :staffs then type = "人数"
                when :points then type = "点数"
                end
                sx = sx + 3
                cell = sheet.sheet_data[row][sx]
                cell.change_contents(type)
                set_area_border(sheet, sx, row, 1, 1, 'thin')
                row += 1
            }
        }
    }
    # 日・グループごとのシフト数の集計
    dates.each_with_index { |date, x|
        col = day_shifts_area[:sx] + 8 + x
        row = day_shifts_area[:sy]
        groups.keys.each { |gname|
            group   = groups[gname]
            shifts  = group[:shifts].keys
            # シフト名をソート
            shifts = shifts.sort_by { |s|
                idx = base_shift_order.index(s)
                idx = base_shift_order.size if idx.nil?
                [idx, s]
            }        
            members = group[:members]
            area = members.map { |r|
                from = RubyXL::Reference.ind2ref(shift_table_area[:sy] + r.first + 1, col)
                to   = RubyXL::Reference.ind2ref(shift_table_area[:sy] + r.last  + 1, col)
                from + ":" + to
            }
            parea = members.map { |r|
                from = RubyXL::Reference.ind2ref(shift_table_area[:sy] + r.first + 1, staff_area[:sx] + staff_area[:w] - 1)
                to   = RubyXL::Reference.ind2ref(shift_table_area[:sy] + r.last  + 1, staff_area[:sx] + staff_area[:w] - 1)
                from + ":" + to
            }   
            shifts.each { |shift|
                group[:shifts][shift].each { |type|
                    sft = shift.tr('ａ-ｚＡ-Ｚ／＋', 'a-zA-Z/+')
                    formula = nil
                    case type
                    when :staffs
                        formula = area.map { |area| 
                            sft.split("+").map { |s| 
                                s = s.tr('a-zA-Z/', 'ａ-ｚＡ-Ｚ／')                        
                                "countif(#{area}, \"#{s}\")" }
                        }.flatten.join("+")    

                    when :points
                        formula = []
                        (0...area.size).each { |i|
                            sft.split("+").map { |s| 
                                s = s.tr('a-zA-Z/', 'ａ-ｚＡ-Ｚ／')                        
                                formula.push("sumproduct((#{area[i]}=\"#{s}\")*(#{parea[i]}))")
                            }
                        }
                        formula = formula.flatten.join("+")                        
                    end                        
                    cell = sheet.sheet_data[row][col]
                    cell.change_contents('', formula)
                    set_border(cell)

                    unless violations[gname][shift][date][:staff_lb].empty? && violations[gname][shift][date][:staff_ub].empty?
                        cell.change_font_color($warning_fg)
                        cell.change_fill($warning_bg)            
                    end
                    row += 1
                }            
            }
        }        
    }

    # 罫線
    # Possible weights: hairline, thin, medium, thick
    # Possible "directions": top, bottom, left, right, diagonal
    # worksheet.sheet_data[0][0].change_border(:top, 'thin')        

    # 看護師
    set_area_border(sheet, staff_area[:sx], staff_area[:sy], staff_area[:w], 1, 'medium')
    set_area_border(sheet, staff_area[:sx], staff_area[:sy], 1, staff_area[:h], 'medium')
    set_area_border(sheet, staff_area[:sx], staff_area[:sy], staff_area[:w], staff_area[:h], 'medium')

    # 日付＋曜日
    set_area_border(sheet, shift_table_area[:sx], shift_table_area[:sy], shift_table_area[:w], 2, 'medium')
    set_area_border(sheet, shift_table_area[:sx], shift_table_area[:sy], shift_table_area[:w], shift_table_area[:h], 'medium')
    set_area_border(sheet, shift_table_area[:sx], shift_table_area[:sy], prev_dates.size, shift_table_area[:h], 'medium')
    set_area_border(sheet, shift_table_area[:sx] + prev_dates.size + dates.size, shift_table_area[:sy], next_dates.size, shift_table_area[:h], 'medium')

    # 看護師ごとのシフト数
    set_area_border(sheet, staff_shifts_area[:sx], staff_shifts_area[:sy], staff_shifts_area[:w], 1, 'medium')
    set_area_border(sheet, staff_shifts_area[:sx], staff_shifts_area[:sy], staff_shifts_area[:w], staff_shifts_area[:h], 'medium')

    # 週末休暇数
    set_area_border(sheet, weekend_off_area[:sx], weekend_off_area[:sy], weekend_off_area[:w], 1, 'medium')
    set_area_border(sheet, weekend_off_area[:sx], weekend_off_area[:sy], weekend_off_area[:w], weekend_off_area[:h], 'medium')

    # 日毎の看護師数
    set_area_border(sheet, day_shifts_area[:sx], day_shifts_area[:sy], day_shifts_area[:w], day_shifts_area[:h], 'medium')
    set_area_border(sheet, day_shifts_area[:sx], day_shifts_area[:sy], 4, day_shifts_area[:h], 'medium')
    set_area_border(sheet, day_shifts_area[:sx] + 4, day_shifts_area[:sy], 3, day_shifts_area[:h], 'medium')
    set_area_border(sheet, day_shifts_area[:sx] + 7, day_shifts_area[:sy], 1, day_shifts_area[:h], 'medium')
    row = day_shifts_area[:sy]
    groups.each_key { |gname|
        h = groups[gname][:shifts].map { |k,v| v.size }.sum
        set_area_border(sheet, day_shifts_area[:sx], row, day_shifts_area[:w], h, 'medium')
        row += h
    }

    # 経過時間の出力
    row = 2 + shift_table_area[:h] + day_shifts_area[:h]
    cell = sheet.add_cell(row, 0, "Elapsed time")
    cell.change_horizontal_alignment('left')
    cell.change_font_bold(true)
    cell = sheet.add_cell(row+1, 0, elapsed_time)

    # Penalty の出力
    row += 2
    cell = sheet.add_cell(row, 0, "Penalties")
    cell.change_horizontal_alignment('left')
    cell.change_font_bold(true)
    row += 1    
    penalties = penalties.sort { |a,  b| [-a[:priority], -a[:cost], a[:cause]] <=> [-b[:priority], -b[:cost], b[:cause]] }
    penalties.each_with_index { |p, i| 
        cell = sheet.add_cell(row+i, 0, "#{p[:cost]} #{p[:priority]} #{p[:cause]}")
        cell.change_horizontal_alignment('left')
    }    
    
    # もし Sheet1 というデフォルトシートがあれば削除
    sheet = $workbook['Sheet1']    
    $workbook.worksheets.delete(sheet) unless sheet.nil?

    # シートの整列（最後に追加したシートを先頭にする）
    $workbook.worksheets = [$workbook.worksheets.last] + $workbook.worksheets[0..-2]

    # ブックの保存
    $workbook.write($output)
    return
end

def parse_assignment(line)    
    table = Hash.recursive
    staffs           = {}
    base_dates       = []
    dweeks           = {}
    prev_dates       = []
    dates            = []    
    next_dates       = []
    num_weekend_offs = {}
    
    violations = Hash.recursive
    penalties        = []
    shifts           = []
    groups           = {}
    assignments  = line.split(' ')
    assignments.each { |fact|
        case fact
        when /^out_assigned\((\d+),(-?\d+),\"(.+)\"\)/
            staff = $1.to_i
            date  = $2.to_i
            shift = $3
            #next if day < 0
            table[staff][date] = shift            
        when /^penalty\((.+),(\d+),(\d+)\)/
            penalties.push({ cause: $1, cost: $2.to_i, priority: $3.to_i })

            case $1
            when /^national_holiday\((\d+),(\d+),"(.+)"\)/
                staff = $1.to_i
                date  = $2.to_i
                shift = $3
                violations[staff][date][:national_holiday] = true
            when /^soft_holiday\((\d+),(\d+),"(.+)"\)/
                staff = $1.to_i
                date  = $2.to_i
                shift = $3
                violations[staff][date][:soft_holiday] = true
            when /^staff_lb\((\d+),"(.+)","(.+)",(\d+),(\d+)\)/
                date  = $1.to_i
                shift = $2
                group = $3
                lb    = $4.to_i
                val   = $5.to_i
                violations[group][shift][date][:staff_lb] = { lb: lb, val: val }
            when /^staff_ub\((\d+),"(.+)","(.+)",(\d+),(\d+)\)/
                date  = $1.to_i
                shift = $2
                group = $3
                ub    = $4.to_i
                val   = $5.to_i
                violations[group][shift][date][:staff_ub] = { ub: ub, val: val }
            when /^staff_sg_lb\((\d+),"(.+)","(.+)",(\d+),(\d+)\)/
                date  = $1.to_i
                shift = $2
                group = $3
                lb    = $4.to_i
                val   = $5.to_i
                violations[group][shift][date][:staff_lb] = { lb: lb, val: val }
            when /^staff_sg_ub\((\d+),"(.+)","(.+)",(\d+),(\d+)\)/
                date  = $1.to_i
                shift = $2
                group = $3
                ub    = $4.to_i
                val   = $5.to_i
                violations[group][shift][date][:staff_ub] = { ub: ub, val: val }
            when /^shift_lb\((\d+),"(.+)",(\d+),(\d+)\)/
                staff = $1.to_i
                shift = $2
                lb    = $4.to_i
                val   = $5.to_i
                violations[staff][shift][:shift_lb] = { lb: lb, val: val }
            when /^shift_ub\((\d+),"(.+)",(\d+),(\d+)\)/
                staff = $1.to_i
                shift = $2
                ub    = $4.to_i
                val   = $5.to_i
                violations[staff][shift][:shift_ub] = { ub: ub, val: val }                
            when /^weekend_off\((\d+)\),\d+\)/
                staff = $1.to_i
                violations[staff][:weekend_off] = true
            when /^pred_shift\((\d+),(\d+),"(.+)"\)/
                staff = $1.to_i
                date  = $2.to_i
                shift = $3
                violations[staff][date][:pred_shift] = { shift: shift }
            when /^succ_shift\((\d+),(\d+),"(.+)"\)/
                staff = $1.to_i
                date  = $2.to_i
                shift = $3
                violations[staff][date][:succ_shift] = { shift: shift }
            when /^pattern_lb\((\d+),"(.+)",(\d+),(\d+)\)/
                staff   = $1.to_i
                pattern = $2
                lb      = $4.to_i
                val     = $5.to_i
                violations[staff][:pattern_lb] = { pattern: pattern, lb: lb, val: val }
            when /^pattern_ub\((\d+),"(.+)",(\d+),(\d+)\)/
                staff   = $1.to_i
                pattern = $2
                ub      = $4.to_i
                val     = $5.to_i
                violations[staff][:pattern_ub] = { pattern: pattern, ub: ub, val: val }
            when /jsjsoo\((\d+),(\d+)\)/
                staff = $1.to_i
                date  = $2.to_i
                violations[staff][date+0][:jsjsoo] = true
                violations[staff][date+1][:jsjsoo] = true
            when /additional_holiday\((\d+),(\d+),(\d+)\)/
                staff = $1.to_i
                date1 = $2.to_i
                date2 = $3.to_i
                violations[staff][date1][:additional_holiday] = true
                violations[staff][date2][:additional_holiday] = true
            when /^staff_request\((\d+),(\d+),"(.+)","(.+)"\)/
                staff = $1.to_i
                date  = $2.to_i
                req   = $3
                res   = $4
                violations[staff][date][:staff_request] = { req: req, res: res }                
            end

        when /^base_date\((\d+),"(.+)"\)/
            base_dates.push($1.to_i)
            dweeks[$1.to_i] = $2
        when /^date\((\d+),"(.+)"\)/
            dates.push($1.to_i)
        when /^prev_date\((\d+),"(.+)"\)/
            prev_dates.push($1.to_i)
        when /^next_date\((\d+),"(.+)"\)/
            next_dates.push($1.to_i)
        when /^num_weekend_offs\((\d+),(\d+)\)/
            num_weekend_offs[$1.to_i] = $2.to_i            
        when /^staff\((\d+),"(.+)","(.+)","(.+)",(\d+)\)/ # staff(ID, 氏名, 職名, 利用者CD, 点数)
            staffs[$1.to_i] = {
                id:    $1.to_i,
                name:  $2,
                job:   $3,
                cd:    $4,
                point: $5.to_i
            }
        when /^shift\("(.+)"\)/
            shifts.push($1)
        when /^group\("(.+)",(\d+)\)/  # 
            groups[$1] = {} unless groups.key?($1)
            groups[$1][:members] = [] unless groups[$1].key?(:members)
            groups[$1][:members].push($2.to_i)
        when /^staff_bounds\("(.+)","(.+)",\d+,\d+,\d+\)/   # staff_bounds(G, S, D, LB, UB)
            groups[$1] = {} unless groups.key?($1)
            groups[$1][:shifts] = {} unless groups[$1].key?(:shifts)
            groups[$1][:shifts][$2] = [] unless groups[$1][:shifts].key?($2)
            groups[$1][:shifts][$2].push(:staffs) unless groups[$1][:shifts][$2].include?(:staffs)
        when /^staff_sg_bounds\("(.+)","(.+)",\d+,\d+,\d+\)/   # staff_sg_bounds(G, SG, D, LB, UB) 
            groups[$1] = {} unless groups.key?($1)
            groups[$1][:shifts] = {} unless groups[$1].key?(:shifts)
            groups[$1][:shifts][$2] = [] unless groups[$1][:shifts].key?($2)
            groups[$1][:shifts][$2].push(:staffs) unless groups[$1][:shifts][$2].include?(:staffs)
        when /^point_bounds\("(.+)","(.+)",\d+,\d+,\d+\)/   # point_bounds(G, S, D, LB, UB)
            groups[$1] = {} unless groups.key?($1)
            groups[$1][:shifts] = {} unless groups[$1].key?(:shifts)
            groups[$1][:shifts][$2] = [] unless groups[$1][:shifts].key?($2)
            groups[$1][:shifts][$2].push(:points) unless groups[$1][:shifts][$2].include?(:points)
        when /^point_sg_bounds\("(.+)","(.+)",\d+,\d+,\d+\)/   # point_sg_bounds(G, SG, D, LB, UB) 
            groups[$1] = {} unless groups.key?($1)
            groups[$1][:shifts] = {} unless groups[$1].key?(:shifts)
            groups[$1][:shifts][$2] = [] unless groups[$1][:shifts].key?($2)
            groups[$1][:shifts][$2].push(:points) unless groups[$1][:shifts][$2].include?(:points)
        when /^unmatch_night_pair\((\d+),(\d+),(\d+)\)/
            staff1 = $1.to_i
            staff2 = $2.to_i
            date   = $3.to_i
            violations[staff1][date][:night_pair] = { staff: staff2 }
            violations[staff2][date][:night_pair] = { staff: staff1 }
        end
    }

    # 日付のソート
    base_dates.sort!
    prev_dates.sort!
    dates.sort! 
    next_dates.sort!

    # 未割り当ての日を埋める
    table.each_key { |staff|
        dates.each { |date|
            unless table[staff].has_key?(date)
                table[staff][date] = "　"
            end
        }
        next_dates.each { |date|
            unless table[staff].has_key?(date)
                table[staff][date] = "　"
            end
        }
    }

    return { 
        table: table, 
        staffs: staffs,
        base_dates: base_dates, 
        dweeks: dweeks,
        prev_dates: prev_dates,
        dates: dates,
        next_dates: next_dates,
        penalties: penalties, 
        violations: violations,
        shifts: shifts,
        groups: groups,
        num_weekend_offs: num_weekend_offs,
        facts: assignments
    }
end

def solve(argv)
    clingo_opt_idx = argv.index { |e| e =~ /^-.*/ }
    unless clingo_opt_idx.nil?
        files = argv[0...clingo_opt_idx]
        clingo_opts = argv[clingo_opt_idx..-1]
    else
        files = argv
        clingo_opts = []
    end

    cmd = "clingo #{files.join(' ')}"
    cmd += " --opt-mode opt,#{$init_penalty}" unless $init_penalty.nil?
    cmd += " -t #{$threads}" if $threads > 1
    cmd += " --time-limit=#{$time_limit}"
    cmd += " #{clingo_opts.join(' ')}"
    puts "c command: #{cmd}"
    start = Time.now
    Open3.popen2e(cmd) do |stdin, stdout, wait_thr|
        stdin.close
        next_is_assignment = false
        assignment = {}
        total_penalty = 0
        error = false
        stdout.each { |line|
            error = true if line =~ /error/
            elapsed = (Time.now - start).to_i
            head = sprintf("c %-3d", elapsed)
            if $verb == :very_verb or ($verb == :verb and not next_is_assignment) or error
                puts "#{head} #{line}" 
            end
            if line =~ /^Answer/ 
                next_is_assignment = true
            elsif next_is_assignment
                assignment = parse_assignment(line)
                next_is_assignment = false
            elsif line =~ /^Optimization: (.+)$/                
                total_penalty = $1.split(' ').join(',')
                print_table(total_penalty, assignment, head)
                $last_sol = { total_penalty: total_penalty, assignment: assignment, elapsed_time: elapsed }                
            elsif line =~ /^SATISFIABLE/            
                print_table(total_penalty, assignment, head)
                $last_sol = { total_penalty: total_penalty, assignment: assignment, elapsed_time: elapsed }                
            elsif line =~ /^UNSATISFIABLE/
                puts "#{head} #{line}" unless $verb
            elsif line =~ /^OPTIMUM FOUND/
                puts "#{head} #{line}" unless $verb
            end
        }
    end  
end

begin
    solve(ARGV)
rescue Interrupt 
    puts "Interrupted"
ensure    
    unless $output.nil? || $last_sol.nil?
        puts "Writing excel file..."
        write_table($last_sol[:total_penalty], $last_sol[:assignment], $last_sol[:elapsed_time]) 
    end
end
      