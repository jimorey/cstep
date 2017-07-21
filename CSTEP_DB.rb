require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'simple_xlsx_reader'
require File.expand_path(File.dirname(__FILE__) + '/cstep.conf.rb')

###PART 1 - MODEL DECLARATIONS
#nb: DM tables have model name, lowercase, with 's' added

# This the data model called "User" that represents all employees ie. teachers, managers and accounts staff
class User
   include DataMapper::Resource
   property :id,           Serial  # An auto-increment integer key
   property :username,     Text
   property :displayname,  Text
   property :email,        Text
end

#database model to hold activity for time entry dropdown, and associated contract (CAS) type.
class CASLIST
   include DataMapper::Resource
   property :id,           Serial  # An auto-increment integer key
   property :activity,     Text
   property :castype,      Text
   property :misc,         Text
end

#database model to hold list of groups and shortnames.
class ADGROUPLIST
   include DataMapper::Resource
   property :id,               Serial  # An auto-increment integer key
   property :shortname,        Text
   property :description,      Text
end

#database model to hold C managers or coordinators who can approve.
class APPROVERS
   include DataMapper::Resource
   property :id,             Serial  # An auto-increment integer key
   property :shortname,      Text
   property :firstname,      Text
   property :lastname,       Text
   property :title,				   Text
   property :email,          Text
   property :role,           Text
   property :phone,          Text
  end

#database model to hold C courses for managers and time entry.
class COURSES
   include DataMapper::Resource
   property :id,               Serial  # An auto-increment integer key
   property :shortname,        Text
   property :description,      Text
   property :misc,             Text
end

#database model to hold C projects for managers and time entry, and shortname.
class PROJECTS
   include DataMapper::Resource
   property :id,               Serial  # An auto-increment integer key
   property :shortname,        Text
   property :description,      Text
   property :course,           Text
end

# This is the data model called "Item" that represents time entries
class Item
  include DataMapper::Resource
  property :id,       Serial
  property :created,  DateTime, :required => true
  property :user,     Text,     :required => true  # An auto-increment integer key
  property :firstname,Text,     :required => true
  property :lastname, Text,     :required => true
  property :date,     Date,     :required => true
  property :activity, Text,     :required => true  #was content
  property :hours,    Float,    :required => true
  property :start,    Text,     :required => true
  property :end,      Text,     :required => true
  property :Cgroup,Text,     :required => true  # was course
  property :subgroup, Text,     :required => true  # was group
  property :notes,    Text,     :required => false
  property :man_note, Text,     :required => false
  property :deleted,Boolean,  :required => true, :default => false
  property :delete_time, DateTime, :required => false
  property :submitted,Boolean,  :required => true, :default => false
  property :submit_time, DateTime, :required => false
  property :approvecount, Integer, :required => false, :default => 0
  property :approved, Boolean,  :required => true, :default => false
  property :approver1, Text, :required => false
  property :approv1_time, DateTime, :required => false
  property :approver2, Text, :required => false
  property :approv2_time, DateTime, :required => false
  property :entered,  Boolean,  :required => true, :default => false
  property :HR_time, DateTime, :required => false
  property :payroll_ID,    Text,     :required => false
end

# This is the data model called "Payperiod" for pay period entries
class Payperiod
   include DataMapper::Resource
   property :id,             Serial
   property :date_from,      Date
   property :date_to,        Date
   property :date_pay,       Date
   property :date_teach_sub, Date
   property :date_coor_sub,  Date
end

#####################
#The following functions and initialisation code must appear below the Classes (model declarations)
#####################

# PART 2 - MODEL FINALIZATION
def db_init(dbname, debug)

        if(debug)
                DataMapper::Logger.new($stdout, :debug)
                DataMapper::Model.raise_on_save_failure = true
        end

        #setup for sqlite3 database
        #DataMapper.setup(:default, "sqlite://#{dbname}")

        #setup for postgresql database
        #'postgres://user:password@hostname/database'
        #local
        DataMapper.setup(:default, 'postgres://jimorey:sk8er9@localhost/development')
        #heroku
        #DataMapper.setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

        DataMapper.finalize
end

# PART 3 - CREATE TABLES (Clean) and then access the Model (Item.all)
def db_setup
      if (DB_CLEAN==true) then
        DataMapper.auto_migrate!
        testitem=Item.all() #use it once to undo lazy loading
      end
      if (DB_UPDATE==true) then
        DataMapper.auto_upgrade!
        testitem=Item.all() #use it once to undo lazy loading
      end
      if (DB_CLEAN!=true) then
        testitem=Item.all()  # can we use auto_upgrade! safely here now?
      end
end

def caslist_fill
  cas_teaching  = CASLIST.new
  cas_teaching.activity = "Teaching"
  cas_teaching.castype = "CAS1"
  cas_teaching.save

  cas_marking   = CASLIST.new
  cas_marking.activity = "Marking"
  cas_marking.castype = "CAS2"
  cas_marking.save

  cas_planning  = CASLIST.new
  cas_planning.activity = "Planning"
  cas_planning.castype = "CAS2"
  cas_planning.save

  cas_meeting   = CASLIST.new
  cas_meeting.activity = "Meeting"
  cas_meeting.castype = "CAS2"
  cas_meeting.save

  cas_excursion = CASLIST.new
  cas_excursion.activity = "Excursion"
  cas_excursion.castype = "CAS3"
  cas_excursion.save
end

def adgrouplist_fill
  group_ST = ADGROUPLIST.new
  group_ST.shortname = "adST"
  group_ST.description = "C-Casual_Timesheet-Approver_StudyTours"
  group_ST.save

  group_BC = ADGROUPLIST.new
  group_BC.shortname = "adBC"
  group_BC.description = "C-Casual_Timesheet-Approver_BC"
  group_BC.save

  group_EL = ADGROUPLIST.new
  group_EL.shortname = "adEL"
  group_EL.description = "C-Casual_Timesheet-Approver_ELICOS"
  group_EL.save

  group_AC = ADGROUPLIST.new
  group_AC.shortname = "adAC"
  group_AC.description = "C-Casual_Timesheet-Accounts"
  group_AC.save
end

def approvers_fill
  app_mik = APPROVERS.new
  app_mik.shortname = "Mike"
  app_mik.firstname = "Michael"
  app_mik.lastname = "Jones"
  app_mik.title = "Mr"
  app_mik.role = "Manager (Study Tours)"
  app_mik.phone = "60008000"
  app_mik.email = "michael.jones@email.com"
  app_mik.save

  app_mon = APPROVERS.new
  app_mon.shortname = "Mon"
  app_mon.firstname = "Monica"
  app_mon.lastname = "Rose"
  app_mon.title = "Ms"
  app_mon.role = "Study Tours Coordinator"
  app_mon.phone = "60009000"
  app_mon.email = "monica.rose@email.com"
  app_mon.save

  app_dan = APPROVERS.new
  app_dan.shortname = "Dan"
  app_dan.firstname = "Daniel"
  app_dan.lastname = "Radcliffe"
  app_dan.title = "Mr"
  app_dan.role = "Mainstream Course Coordinator"
  app_dan.phone = "60007000"
  app_dan.email = "daniel.radcliffe@email.com"
  app_dan.save

  app_cat = APPROVERS.new
  app_cat.shortname = "Cat"
  app_cat.firstname = "Catherine"
  app_cat.lastname = "Williams"
  app_cat.title = "Mrs"
  app_cat.role = "Manager (Study Tours)"
  app_cat.phone = "60006000"
  app_cat.email = "catherine.williams@email.com"
  app_cat.save

  app_jak = APPROVERS.new
  app_jak.shortname = "Jak"
  app_jak.firstname = "Jake"
  app_jak.lastname = "Howes"
  app_jak.title = "Mr"
  app_jak.role = "Bridging Course Coordinator"
  app_jak.phone = "60003000"
  app_jak.email = "jake.howes@email.com"
  app_jak.save

  app_jil = APPROVERS.new
  app_jil.shortname = "Jil"
  app_jil.firstname = "Jill"
  app_jil.lastname = "Jameson"
  app_jil.title = "Ms"
  app_jil.role = "Mainstream Course Coordinator"
  app_jil.phone = "60002000"
  app_jil.email = "jill.jameson@email.com"
  app_jil.save
end

def courses_fill
  course_BC = COURSES.new
  course_BC.shortname = "BC"
  course_BC.description = "Bridging Course"
  course_BC.save

  course_EL = COURSES.new
  course_EL.shortname = "EL"
  course_EL.description = "ELICOS"
  course_EL.save

  course_ST = COURSES.new
  course_ST.shortname = "ST"
  course_ST.description = "Study Tours"
  course_ST.save
end

def projects_fill
  project_Bei = PROJECTS.new
  project_Bei.shortname = "Beijing"
  project_Bei.description = "Beijing School"
  project_Bei.course = "ST"
  project_Bei.save

  project_Kor = PROJECTS.new
  project_Kor.shortname = "Korea"
  project_Kor.description = "Korea Manufacturing"
  project_Kor.course = "ST"
  project_Kor.save

  project_IAL = PROJECTS.new
  project_IAL.shortname = "IAL"
  project_IAL.description = "IAL project"
  project_IAL.course = "ST"
  project_IAL.save
end

#fPART 4: fill the payroll table with the entries from the Excel spreadsheet
#TO DO: empty table of all entries before refilling - we can set up a specific 'migration' to do this
def payroll_fill
    doc = SimpleXlsxReader.open(Dir.pwd + "/C_payroll.xlsx") #open xlxs document
    rows = doc.sheets.first.rows #read rows from document

    rows.delete_at(0) #delete the first row as it contains headers
    rows.delete_at(0) #delete the second row as it contains sub headers

    rows.each do |r|
      ppay = Payperiod.new
      ppay.date_from = r[0]
      ppay.date_to = r[1]
      ppay.date_pay = r[2]
      ppay.date_teach_sub = r[3]
      ppay.date_coor_sub = r[4]
      ppay.save
    end
end


#Database initialisation.
configure do
        puts "Loading Database Model..."
        puts DB_NAME
        db_init(DB_NAME, true)
        #setup and payroll added 12.10.16
        db_setup()
        if (LD_PAYROLL==true) then
          payroll_fill()
          caslist_fill()
          adgrouplist_fill()
          approvers_fill()
          courses_fill()
          projects_fill()
        end
end
