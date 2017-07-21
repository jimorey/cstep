# C Options
=begin
DB_NAME = "/var/www/c-step-dev/CSTEP_DB.db"
LOGINFILE="CLogin.rb"
=end

# Offline options : comment these out if using C options
DB_NAME = "#{Dir.pwd}/CSTEP_DB.db"
LOGINFILE="Login.rb"

#Database model : set to true to reapply database model and start with empty items and payroll tables; false to keep existing data
DB_CLEAN=true
#to refresh the tables underlying the model, non-destructively
DB_UPDATE=true

#Payperiods import from xlsx: set to true to import the data from the xlsx after all DB tables are cleaned,
# or payroll period table is cleaned, then reset to false next time
LD_PAYROLL=true

#development version message
DEV=true

#Folders used by prawn gem for image source and when saving PDFs
PDFDIR="pdfSaved"
IMGDIR="public/img/"
