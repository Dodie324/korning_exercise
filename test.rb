# Use this file to import the sales information into the
# the database.

require "pg"
require "csv"
require "pry"

####################
## HELPER METHODS ##
####################

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

def read_file(filename)
  data_array = []

  CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
    data_array << row.to_hash
  end

  data_array
end

####################
## FIND  CRITERIA ##
####################

def find_employee_by(email)
  sql = "SELECT email FROM employees WHERE email = '#{email}'"
  # return that employee in hash format
  employee_email = db_connection do |conn|
    conn.exec(sql)
  end

  employee_email.to_a
end

def find_customer_by(account)
  sql = "SELECT account_num FROM customers WHERE account_num = '#{account}'"

  acct_no = db_connection do |conn|
    conn.exec(sql)
  end

  acct_no.to_a
end

def find_product_by(product)
  sql = "SELECT name FROM products WHERE name = '#{product}'"

  prdct_name = db_connection do |conn|
    conn.exec(sql)
  end

  prdct_name.to_a
end

def find_invoice_by(invoice)
  sql = "SELECT invoice_number FROM invoices 
         WHERE invoice_number = '#{invoice}'"

  invoice_no = db_connection do |conn|
    conn.exec(sql)
  end

  invoice_no.to_a
end

######################
## PARSE EACH TABLE ##
######################

def parse_employee(row)
  employee = row[:employee]
  split = employee.split(' ')
  name = split[0] + ' ' + split[1]
  email = split[2].gsub(/[(|)]/, '')

  { name: name, email: email } # just going to return employee hash which we pass into insert
end

def parse_customer(row)
  customer = row[:customer_and_account_no]
  split = customer.split(' ')
  name = split[0]
  account = split[1].gsub(/[(|)]/, '')

  { name: name, account: account } # just going to return employee hash which we pass into insert
end

def parse_product(row)
  product = row[:product_name]

  { product: product }
end

# def parse_invoice(row)
#   employee = row[:employee]
#   customer = row[:customer_and_account_no]
#   product = row[:product_name]
#   date = row[:sale_date]
#   amount = row[:sale_amount]
#   qty = row[:units_sold]
#   invoice_num = row[:invoice_no]
#   freq = row[:invoice_frequency]

#   { date: date, amount: amount, qty: qty, invoice_num: invoice_num, freq: freq }
# end

####################
##  INSERT TO DB  ##
####################

def insert_employee(employee_hash)
  # if employee is already in db then return out of method
  #  some select statement to check if employee exists
  name = employee_hash[:name]
  email = employee_hash[:email]
  
  db_connection do |conn|
    if find_employee_by(email).empty?
      sql = "INSERT INTO employees (name, email) VALUES  ($1, $2)"
    
      conn.exec_params(sql, [name, email])
    else
      next
    end   
  end

end  

def insert_customer(employee_hash)
  name = employee_hash[:name]
  account = employee_hash[:account]

  db_connection do |conn|
    if find_customer_by(account).empty?
      sql = "INSERT INTO customers (name, account_num) VALUES ($1, $2)"
    
      conn.exec_params(sql, [name, account])
    else
      next
    end   
  end

end 

def insert_product(employee_hash)
  product = employee_hash[:product]

  db_connection do |conn|
    if find_product_by(product).empty?
      sql = "INSERT INTO products (name) VALUES ($1)"
    
      conn.exec_params(sql, [product])
    else
      next
    end   
  end

end



####################
## RUN THIS BEAST ##
####################

data = read_file('sales.csv') # an array of hashes, each hash is a line in the csv

data.each do |row|
  # each row is a line in the csv
  employee = parse_employee(row)# passing that row into #parse_employee and it returns a organized hash of name and email
  customer = parse_customer(row)
  product = parse_product(row)
  # invoice = parse_invoice(row)
  insert_employee(employee)   # insert the actual employee into the database
  insert_customer(customer)
  insert_product(product)
  # insert_invoice(invoice)

end

##################
## FOREIGN KEYS ##
##################

def read_invoice(filename)
  invoice_data = []

  CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
    invoice_data << row.to_hash
  end

  invoice_data
end

def foreign_key(table)
  sql = ( "SELECT id FROM #{table} WHERE name = '' ")
  result = db_connection do |conn|
    conn.exec(sql)
  end

  result
end

employee_map = Hash.new

foreign_key('employees').each do |employee|
  employee_map[employee['name']] = employee['id']
end

customer_map = Hash.new

foreign_key('customers').each do |customer|
  customer_map[customer['name']] = customer['id']
end

product_map = Hash.new

foreign_key('products').each do |product|
  product_map[product['name']] = product['id']
end


i_data = read_invoice('sales.csv')

i_data.each do |row|
  email = row[:employee].gsub(/[(|)]/, '').split[2]
  account_num = row[:customer_and_account_no].gsub(/[(|)]/, '').split[1]
  product = row[:product_name]
  date = row[:sale_date]
  amount = row[:sale_amount]
  qty = row[:units_sold]
  invoice_num = row[:invoice_no]
  freq = row[:invoice_frequency]
  # employee_id = employee_map[row[:employee]]
  # customer_id = customer_map[row[:customer_and_account_no]]
  # product_id = product_map[row[:product_name]]

  db_connection do |conn|
    if find_invoice_by(invoice_num).empty?
      sql = "INSERT INTO invoices 
             (sale_date, sale_amount, units, invoice_number, frequency, 
              customer_id, employee_id, product_id) VALUES ($1, $2, $3, $4, $5, 
              (SELECT id FROM customers WHERE account_num = '#{account_num}'),
              (SELECT id FROM employees WHERE email = '#{email}'),
              (SELECT id FROM products WHERE name = '#{product}'))"
    
      conn.exec_params(sql, [date, amount, qty, invoice_num, freq])
    else
      next
    end   
  end

end  







