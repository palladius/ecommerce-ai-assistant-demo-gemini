




def db_dump(db: nil)
  db ||= Sequel.sqlite(ENV["DATABASE_NAME"])

  puts("== DB DUMP ==")
  puts "1. Products:"
  puts(db[:products].all)
  %w{ orders order_items products customers}.each do |table_name|
    table_sym = table_name.to_sym
    puts "X. #{table_sym}:"
    puts(db[table_sym].all)
  end

end
