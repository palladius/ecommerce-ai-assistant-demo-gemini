




def db_dump(db: nil)
  db ||= Sequel.sqlite(ENV["DATABASE_NAME"])

  puts("== DB DUMP ==")
  #puts "1. Products:"
  #puts(db[:products].all)
  %w{ orders order_items products customers}.sort.each_with_index do |table_name, ix|
    table_sym = table_name.to_sym
    puts "#{ix+1}. $DB[:#{table_sym}].all "
    puts(db[table_sym].all)
  end

end
