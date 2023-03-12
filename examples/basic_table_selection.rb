require 'glimmer-dsl-libui'

class BasicTableSelection
  include Glimmer::LibUI::Application
  
  before_body do
    @one_data = [
      %w[cat meow],
      %w[dog woof],
      %w[chicken cock-a-doodle-doo],
      %w[horse neigh],
      %w[cow moo]
    ]
    @zero_or_one_data = @one_data.dup
    @zero_or_many_data = @one_data.dup
    @none_data = @one_data.dup
  end
  
  body {
    window('Basic Table Selection', 400, 300) {
      tab {
        tab_item('One') {
          vertical_box {
            vertical_box {
              stretchy false
              
              @one_radio_buttons = radio_buttons {
                items @one_data.size.times.map { |row| "Row #{row} Selection" }
                
                on_selected do |rb|
                  @one_table.selection = [rb.selected]
                end
              }
            }
            
            @one_table = table {
              text_column('Animal') {
                on_clicked do |tc, column|
                  puts "Clicked column #{column}: #{tc.name}"
                  tc.toggle_sort_indicator
                  @one_data.sort_by! { |row_data| row_data[column] }
                  @one_data.reverse! if tc.sort_indicator == :descending
                end
              }
              text_column('Description') {
                on_clicked do |tc, column|
                  puts "Clicked column #{column}: #{tc.name}"
                  tc.toggle_sort_indicator
                  @one_data.sort_by! { |row_data| row_data[column] }
                  @one_data.reverse! if tc.sort_indicator == :descending
                end
              }
        
              cell_rows @one_data
              selection_mode :one # other values are :zero_or_many , :zero_or_one, :none (default is :zero_or_one if not specified)
              selection 2 # initial selection row index (could be nil too or just left off, defaulting to 0)
        
              on_row_clicked do |t, row|
                puts "Row Clicked: #{row}"
              end
        
              on_row_double_clicked do |t, row|
                puts "Row Double Clicked: #{row}"
              end
        
              on_selection_changed do |t|
                # selection is an array or nil if selection mode is zero_or_many
                # otherwise, selection is a single index integer or nil when not selected
                puts "Selection Changed: #{t.selection.inspect}"
                @one_radio_buttons.selected = t.selection
              end
            }
          }
        }
              
        tab_item('Zero-Or-One') {
          vertical_box {
            vertical_box {
              stretchy false
              
              @zero_or_one_radio_buttons = radio_buttons {
                items @zero_or_one_data.size.times.map { |row| "Row #{row} Selection" }
                
                on_selected do |rb|
                  @zero_or_one_table.selection = [rb.selected]
                end
              }
            }
            
            @zero_or_one_table = table {
              text_column('Animal') {
                on_clicked do |tc, column|
                  puts "Clicked column #{column}: #{tc.name}"
                  tc.toggle_sort_indicator
                  @zero_or_one_data.sort_by! { |row_data| row_data[column] }
                  @zero_or_one_data.reverse! if tc.sort_indicator == :descending
                end
              }
              text_column('Description') {
                on_clicked do |tc, column|
                  puts "Clicked column #{column}: #{tc.name}"
                  tc.toggle_sort_indicator
                  @zero_or_one_data.sort_by! { |row_data| row_data[column] }
                  @zero_or_one_data.reverse! if tc.sort_indicator == :descending
                end
              }
        
              cell_rows @zero_or_one_data
              selection_mode :zero_or_one # other values are :zero_or_many , :one, :none (default is :zero_or_one if not specified)
              # selection 0 # initial selection row index (could be nil too or just left off)
        
              on_row_clicked do |t, row|
                puts "Row Clicked: #{row}"
              end
        
              on_row_double_clicked do |t, row|
                puts "Row Double Clicked: #{row}"
              end
        
              on_selection_changed do |t|
                # selection is an array or nil if selection mode is zero_or_many
                # otherwise, selection is a single index integer or nil when not selected
                puts "Selection Changed: #{t.selection.inspect}"
                @zero_or_one_radio_buttons.selected = t.selection
              end
            }
          }
        }
        
        tab_item('Zero-Or-Many') {
          vertical_box {
            vertical_box {
              stretchy false
              
              @zero_or_many_checkboxes = @zero_or_many_data.size.times.map do |row|
                checkbox("Row #{row} Selection") {
                  on_toggled do |c|
                    table_selection = @zero_or_many_table.selection.to_a
                    if c.checked?
                      table_selection << row unless table_selection.include?(row)
                    else
                      table_selection.delete(row) if table_selection.include?(row)
                    end
                    @zero_or_many_table.selection = table_selection
                  end
                }
              end
            }
            
            @zero_or_many_table = table {
              text_column('Animal') {
                on_clicked do |tc, column|
                  puts "Clicked column #{column}: #{tc.name}"
                  tc.toggle_sort_indicator
                  @zero_or_many_data.sort_by! { |row_data| row_data[column] }
                  @zero_or_many_data.reverse! if tc.sort_indicator == :descending
                end
              }
              text_column('Description') {
                on_clicked do |tc, column|
                  puts "Clicked column #{column}: #{tc.name}"
                  tc.toggle_sort_indicator
                  @zero_or_many_data.sort_by! { |row_data| row_data[column] }
                  @zero_or_many_data.reverse! if tc.sort_indicator == :descending
                end
              }
        
              cell_rows @zero_or_many_data
              selection_mode :zero_or_many # other values are :none , :zero_or_one , and :one (default is :zero_or_one if not specified)
              selection 0, 2, 4 # initial selection row indexes (could be empty array too or just left off)
        
              on_row_clicked do |t, row|
                puts "Row Clicked: #{row}"
              end
        
              on_row_double_clicked do |t, row|
                puts "Row Double Clicked: #{row}"
              end
        
              on_selection_changed do |t|
                # selection is an array or nil if selection mode is zero_or_many
                # otherwise, selection is a single index integer or nil when not selected
                puts "Selection Changed: #{t.selection.inspect}"
                @zero_or_many_checkboxes.each { |cb| cb.checked = false }
                t.selection&.each do |selected_row|
                  @zero_or_many_checkboxes[selected_row].checked = true
                end
              end
            }
          }
        }
                
        tab_item('None') {
          vertical_box {
            @none_table = table {
              text_column('Animal') {
                on_clicked do |tc, column|
                  puts "Clicked column #{column}: #{tc.name}"
                  tc.toggle_sort_indicator
                  @none_data.sort_by! { |row_data| row_data[column] }
                  @none_data.reverse! if tc.sort_indicator == :descending
                end
              }
              text_column('Description') {
                on_clicked do |tc, column|
                  puts "Clicked column #{column}: #{tc.name}"
                  tc.toggle_sort_indicator
                  @none_data.sort_by! { |row_data| row_data[column] }
                  @none_data.reverse! if tc.sort_indicator == :descending
                end
              }
        
              cell_rows @none_data
              selection_mode :none # other values are :zero_or_many , :zero_or_one, :one (default is :zero_or_one if not specified)
        
              on_row_clicked do |t, row|
                puts "Row Clicked: #{row}"
              end
        
              on_row_double_clicked do |t, row|
                puts "Row Double Clicked: #{row}"
              end
        
              on_selection_changed do |t|
                # selection is an array or nil if selection mode is zero_or_many
                # otherwise, selection is a single index integer or nil when not selected
                puts "Selection Changed: #{t.selection.inspect}"
              end
            }
          }
        }
        
      }
    }
  }
end

BasicTableSelection.launch
