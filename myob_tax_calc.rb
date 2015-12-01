# MYOB Code Challenge
#
# Tax computation for the given input CSV
#
# Usage: 
# => ruby myob_tax_calc.rb myob_emp.csv myob_salary_slip.csv tax_slab.csv
#

require 'csv'

# Input CSV for tax computation
input_file=ARGV[0]          #first parameter input file - myob_emp.csv

#output CSV for payslips
output_file=ARGV[1]         # second parameter output file - myob_salary_slip.csv

# if the tax slab is changed, new csv file for 2016 will be provided as input
tax_slab_file=ARGV[2]       # third parameter tax slab file - tax_slab.csv

emp_data = CSV.read(input_file, { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

tax_data = CSV.read(tax_slab_file, { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})

hash_emp_data = emp_data.map { |e| e.to_hash }
#puts hashed_data.inspect
hash_tax_data = tax_data.map { |t| t.to_hash }

#open myob_salary_slip CSV file in WRITE mode.
myob_salary_slip=open(output_file,'w')

# Write CSV header in payslip CSV
myob_salary_slip.write("Emp_Name,Salary_Month,Gross_Income,Income_Tax,Net_income,Super_Amount")
# insert new line as the write function will not insert a new line in the file and we need one.
myob_salary_slip.write("\n")

# Loop through the input emp records for Tax Computation
hash_emp_data.each do|emp_rec|
  #puts rec.inspect

  # Calculate Gross income =annaual salary divided by 12 - round off
  gross_income=(emp_rec[:annual_salary]/12).round(0)
  
  # initialize tax to 0 before calculation
  tax=0

  hash_tax_data.each do|tax_slab|
    if emp_rec[:annual_salary] >= tax_slab[:start_range] and emp_rec[:annual_salary] <= tax_slab[:end_range]
      # if the salary is with in the tax slab, calculate based on the tax slab CSV file
      tax+=((tax_slab[:slab_tax]+(emp_rec[:annual_salary]-tax_slab[:start_range]-1)*tax_slab[:tax_on_income])/12).round(0)
    end
  end

  # Net income = gross salary minus tax 
  net_income=(emp_rec[:annual_salary]/12).round(0)-tax

  # Super amount = gross income * super rate%
  super_amount=((gross_income*emp_rec[:super_rate])/100).round(0)

  #write the salary slip record for the Empployee
  myob_salary_slip.write("#{emp_rec[:first_name]} #{emp_rec[:last_name]},#{emp_rec[:salary_month]},#{gross_income},#{tax},#{net_income},#{super_amount}")
  myob_salary_slip.write("\n")
end