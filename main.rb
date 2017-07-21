require 'bundler/setup'
require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'prawn'
require 'prawn/table'
require 'json'
require 'date'
require 'sinatra/flash' # this is for flash messages including the login_page.erb by Jim (23 Sep 2016)
require_relative 'CSTEP_DB'
require File.expand_path(File.dirname(__FILE__) + '/cstep.conf.rb')
require_relative "#{LOGINFILE}"

#sessions are cookies
enable :sessions
set :session_secret, 'development secret'

#############################################################
#User logged in checks
def require_logged_in
   redirect '/' unless is_authenticated?
end

def is_authenticated?
   #!! forces boolean return, and then negates for correct return
   return !!session[:username]
end
#############################################################
#User access level checks : default redirection if access is false
def redirect_access
   if session[:access] == "admin"
      redirect'/approval_page'
   elsif session[:access] == "teacher"
      redirect'/hours_entry_page'
   elsif session[:access] == "accounts"
      redirect'/accounts_page'
   else
      #this case is logically impossible, but bugs defy logic
      puts "Somehow you logged in, but you are not a member of a group. Well done."
      puts "Logging you out."
      session.clear
      redirect '/'
   end
end

def require_access (access)
   redirect_access unless has_access? access
end

def has_access? (access)
   if (access=="teacher") && (session[:access]=="teacher" || session[:access]=="admin")
     return true
   elsif (access=="admin") && (session[:access]=="admin")
     return true
   elsif (access=="accounts") && (session[:access]=="accounts" || session[:access]=="admin")
     return true
   else return false
   end
   #return session[:access] == access
end

#############################################################
#Other Functions

def setViewdata

  @devmsg=""
  if (DEV==true)
    @devmsg="C-STEP is currently in DEVELOPMENT"
  end
end

##################
# PDF TIMESHEET GENERATION FUNCTION

def hoursTable(timearray,lastname,firstname,user,date)

content_type 'application/pdf'
#helper array
days =["Mon","Tue", "Wed", "Thu","Fri","Sat","Sun","Mon","Tue", "Wed", "Thu","Fri","Sat","Sun"] #array of days, starts at [0]

#### HEADER ######

filename = "#{IMGDIR}/UWAlogo.png"
pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
pdf.image filename, :width => 107, :height => 35, :at => [000,525] #UWAlogo - nb Y value <550  for landscape
pdf.draw_text "FORTNIGHTLY TIMESHEET - CASUAL TEACHERS", :size =>12,:at => [250,500], :style=>:bold #X,Y from bottom left
pdf.move_down 40 # without this, it will draw in same place

### TABLE  - Build row by row
#
data = [[],[]]  #2D array required, of cells [ [], [] ]
data.push([{:content=>"Employee ID: #{user}",:font_style=>:bold},
  {:content=>"SURNAME, firstname:\n#{lastname},#{firstname}\n",:font_style=>:bold},
  {:content=>"School/Admin Dept: C\n\n",:font_style=>:bold},
  " "])

data.push([{:content=>"Fortnight Dates",:font_style=>:bold},
  {:content=>"Hrs Worked CAS1",:font_style=>:bold},
  {:content=>"Hrs Worked CAS2",:font_style=>:bold},
  {:content=>"Hrs Worked CAS3",:font_style=>:bold}
  ])

#array for adding up row totals
totalhrs=[]
tal=timearray.length()-1
for i in 0..tal do
  data.push([
    #{:content=>"#{days[i]} #{timearray[i][0]}"},   <--- if we can track days, use this
    {:content=>"#{timearray[i][0]}"},
    {:content=>"#{timearray[i][1]}"},
    {:content=>"#{timearray[i][2]}"},
    {:content=>"#{timearray[i][3]}"}
  ])

end

#take column totals
totalhrs[1]=timearray.map{|e| e[1]}.reduce(:+)
totalhrs[2]=timearray.map{|e| e[2]}.reduce(:+)
totalhrs[3]=timearray.map{|e| e[3]}.reduce(:+)

#add last row with total hours calculations
data.push([
  {:content=>"Total fortnighly hours worked",:font_style=>:bold},
  {:content=>"#{totalhrs[1]}",:font_style=>:bold},
  {:content=>"#{totalhrs[2]}",:font_style=>:bold},
  {:content=>"#{totalhrs[3]}",:font_style=>:bold}])

#add table in memory
pdf.table data, :cell_style => {:size=>9}, :column_widths=>{0=>150,1=>200,2=>200,3=>200}, :row_colors=>["F0F0F0","FFFFCC"]
pdf.move_down 10

#Footer
footer="OVERTIME AUTHORISATION."
footerdata="  Where hours worked are in excess of 7.5 hours per day overtime rates will apply if more than 75 hrs in fortnight (the 23% casual loading will not apply). Penalty rates will NOT apply if the hours worked have been at the convenience of the employee and not specifically required by the supervisor. A lunch break of at least 30 mins must be included."
pdf.text footer, :size =>9, :style=>:bold
pdf.text footerdata, :size =>9
#
#Certification section
pdf.move_down 10
dotline="..................................................."
dotlinespc="...................................................         "
staffcertify="I certify that the hours claimed above are correct and meet the requirements of the minimum hours of engagement and payment is approved. In approving this payment, I confirm that I am an Approved Delegate and funds are available."
certdata=([ ["I certify that the above hours are correct\n\n\n#{dotline}\nSignature of Employee","#{staffcertify}\n\n\n#{dotlinespc}#{dotlinespc}#{dotlinespc}#{dotline}\nSignature of Mainstream Officer          Signature of BC Officer                      Signature of Study Tours Officer           Signature of Accounts officer"]
 ])
pdf.table certdata, :cell_style => {:size=>9}, :column_widths=>{0=>160,1=>600}

save=true
if (save==true) then
  pdf.render_file "#{PDFDIR}/#{lastname}#{firstname}#{user}#{date}.pdf"
end
#this will, finally, render in browser window but it will be too quick to see if there is a redirect
pdf.render

end

##########
# Function to collate CAS1 entries for populating PDF timesheet
def populateCAS(uid)

  userlist={}
  timelist=[]
  cashrs=[]
  data=[]
  #Obtain a list of approved entries
  @userSet=Item.all(:fields => [:user]) && Item.all(:approved=>true,:order => [:date.asc])
  if (uid) then  #if user passed to function limit entries to that user
    @userSetA=Item.all(:user=>uid,:order => [:date.asc])
    @userSet=@userSetA.all(:approved=>true)
  end
  # 3 types of CAS contracts fixed on PDF form at present
  #
  @userSet.each do |focus|
      CASLIST.all().each do |i|
        cashrs[0]=0
        cashrs[1]=0
        cashrs[2]=0
        if (focus.hours) && (focus.hours>0) && (focus.activity==i.activity)  then
              if (i.castype=="CAS1") then cashrs[0]=focus.hours end
              if (i.castype=="CAS2") then cashrs[1]=focus.hours end
              if (i.castype=="CAS3") then cashrs[2]=focus.hours end
        puts "#{focus.user} Date #{focus.date} #{i.activity} #{i.castype} hours: #{focus.hours}"
        puts "#{focus.date} #{cashrs[0]} #{cashrs[1]} #{cashrs[2]}"
        data=[focus.date,cashrs[0],cashrs[1],cashrs[2]]
        timelist.push(data)
        @ln=focus.lastname
        @fn=focus.firstname
        @uid=focus.user
        #@dte="2016-10-16"
        @dte=Time.now
        end
      end
    end
    #Make a PDF for each user and save
    hoursTable(timelist,@ln,@fn,@uid,@dte)
  end

#############################################################
#Sinatra GET and POST for Views
############################################################

#login get
get '/' do
   setViewdata()
   erb :login_page
end

#buttons at top
get '/logout' do
   session.clear
   flash[:error] = "You have successfully logged out."
   redirect '/'
end

#login post
post '/' do
   login=::Sinatra::ADAuth::CLogin.new(params[:loginusername], params[:loginpassword])

   if login.authenticated
      user = User.new
      user.username    = params[:loginusername]
      user.displayname = login.fullname.to_s
      user.save if User.count(:username=>user.username) == 0
      puts "DISPLAY NAME: " + user.displayname

		#give session essential details
		session[:username]    = params[:loginusername]
    session[:firstname]   = login.firstname.to_s
    session[:lastname]    = login.lastname.to_s
		session[:fullname]    = login.fullname.to_s
    session[:access]      = login.access.to_s
		session[:man_group]   = login.group.to_s
		session[:displayname] = login.fullname.to_s
    session[:usergroups]  = login.groupArray

    #multiple groups access for some managers/admin
		###
		@user=session[:username]
		puts "Summary output:"
    puts "first name: #{login.firstname}"
    puts "last name: #{login.lastname}"
		puts "fullname: #{login.fullname}"
		puts "username: #{@user}"
		puts "authentication: #{login.authenticated}"   #uses attribute accessor methods
		puts "Access: #{login.access}"
		puts "------------------------------"
		puts "Finished Login instance"
		puts "------------------------------"
		puts session[:man_group]
		####
		redirect_access #let's make this default to teacher.  Users with higher access can see the options at top of screen.

   else
      puts "Incorrect username or password"
      flash[:error] = "Incorrect username or password."
      redirect'/'  #activates flash error when re-rendering html
   end
end

#############################################################
### SUB PAGE REDIRECTIONS ###################################

#manager approvals page
before '/approval_page' do
   require_logged_in
   require_access "admin"
end

get '/approval_page' do
   session[:currentpage] = request.fullpath
   # A note on datamapper here: If you give datamapper an array
   # it will add a IN-clause for each member of the array.
   # ie. users = User.all(:id => [1,2,3])
   #load page with approvers selected pay period
   if params[:payperiod] != nil && params[:employee] == "" then
      date_from_s = Date.strptime(params[:payperiod], '%d/%m/%Y').to_s
      @pp_start_s = date_from_s
      payperiod = Payperiod.first(:date_from => date_from_s)
      @items = Item.all(:submitted => true, :Cgroup => session[:usergroups], :user.not => session[:username], :date.gte => payperiod[:date_from], :date.lte => payperiod[:date_to], :order => [:lastname.asc])
   #load page with approvers selected pay period and specific employee
   elsif params[:payperiod] != nil && params[:employee] != ""
      date_from_s = Date.strptime(params[:payperiod], '%d/%m/%Y').to_s
      @pp_start_s = date_from_s
      payperiod = Payperiod.first(:date_from => date_from_s)
      firstname, lastname = params[:employee].split(' ')
      @items = Item.all(:firstname => firstname, :lastname => lastname, :order => [:lastname.asc]) & Item.all(:submitted => true, :Cgroup => session[:usergroups], :user.not => session[:username], :date.gte => payperiod[:date_from], :date.lte => payperiod[:date_to])
   #load page with current pay period if none selected by user ie. on first page load
   else
      today = Date.today()
      dates_from_lte = Payperiod.all(:date_from.lte => today).map(&:date_from)
      pp_start = dates_from_lte.max
      pp_end = Payperiod.first(:fields => [:date_to], :date_from => pp_start)
      @pp_start_s =  pp_start.to_s
      @items = Item.all(:submitted => true, :Cgroup => session[:usergroups], :user.not => session[:username], :date.gte => pp_start, :date.lte => pp_end.date_to, :order => [:lastname.asc])
   end
  @dates_from = Payperiod.all(:fields => [:date_from])
  @dates_to = Payperiod.all(:fields => [:date_to])
  @users = User.all()
  @userDisplay = params[:employee]
  setViewdata()
  erb :approver
end

#accounts staff page
before '/accounts_page' do
   require_logged_in
   require_access "accounts"
end

get '/accounts_page' do
   #load page with accounts selected pay period
   if params[:payperiod] != nil && params[:employee] == ""
      date_from_s = Date.strptime(params[:payperiod], '%d/%m/%Y').to_s
      @pp_start_s = date_from_s
      payperiod = Payperiod.first(:date_from => date_from_s)
      #@items = Item.all()
      @items = Item.all(:approved => true, :user.not => session[:username], :date.gte => payperiod[:date_from], :date.lte => payperiod[:date_to], :order => [:lastname.asc])
   #load page with accounts selected pay period and specific employee
   elsif params[:payperiod] != nil && params[:employee] != ""
      date_from_s = Date.strptime(params[:payperiod], '%d/%m/%Y').to_s
      @pp_start_s = date_from_s
      payperiod = Payperiod.first(:date_from => date_from_s)
      firstname, lastname = params[:employee].split(' ')
      #allow managers to see all groups they belong to
      @i=0
      session[:usergroups].each do |i|
        @a=Item.all(:Cgroup=>i)
        if (@i>0)
          @k=@k | @a
        elsif @k=@a
        @i=1
        end
      end
      @items = @k & Item.all(:firstname => firstname, :lastname => lastname, :order => [:lastname.asc]) & Item.all(:submitted => true, :Cgroup => session[:man_group], :user.not => session[:username], :date.gte => payperiod[:date_from], :date.lte => payperiod[:date_to])
   #load page with current pay period if none selected by user ie. on first page load
   else
      today = Date.today()
      dates_from_lte = Payperiod.all(:date_from.lte => today).map(&:date_from)
      pp_start = dates_from_lte.max
      pp_end = Payperiod.first(:fields => [:date_to], :date_from => pp_start)
      @pp_start_s =  pp_start.to_s
      #allow managers to see all groups they belong to
      @i=0
      session[:usergroups].each do |i|
        @a=Item.all(:Cgroup=>i)
        if (@i>0)
          @k=@k | @a
        elsif @k=@a
        @i=1
        end
      end
      @items = @k & Item.all(:approved => true, :user.not => session[:username], :date.gte => pp_start, :date.lte => pp_end.date_to, :order => [:lastname.asc])
   end
  @dates_from = Payperiod.all(:fields => [:date_from])
  @dates_to = Payperiod.all(:fields => [:date_to])
  @users = User.all()
  @userDisplay = params[:employee]
  @castypes=CASLIST.all()
  setViewdata()
  erb :accounts
end

#teaching staff time entry page
before '/hours_entry_page' do
   require_logged_in
   #managers can view this as well?
   require_access "teacher"
end

get '/hours_entry_page?' do
   setViewdata()
   #allows page to be refreshed using the exact url
   session[:currentpage] = request.fullpath
   #Retrieve all the items for the current user excluding deleted entries
   @items = Item.all(:order => :created.desc, :deleted => false, :user => session[:username])
   # retrieve current course details from courses and projects tables
   @courses=COURSES.all()
   @projects=PROJECTS.all()
   @actionlist=CASLIST.all()
   @display = "view_submitted"
   erb :hours_entry_page
end

#############################################################
post '/new' do
  @user=session[:username]
  @fname=session[:firstname]
  @lname=session[:lastname]
  @hours=params[:hours]
  puts "updating the entry for this user: #{@user}"
  Item.create(:activity => params[:activity],
              :user => @user.to_s,
              :firstname => @fname.to_s,
              :lastname => @lname.to_s,
              :date => Date.strptime(params[:date], '%d/%m/%Y'),
              :hours => @hours.to_f,  #integer
              :start => params[:startTime],
              :end => params[:endTime],
              :Cgroup => params[:Cgroup],
              :subgroup  => params[:subgroup],
              :notes => params[:notes],
              :submitted => false,
              :deleted => false,
              :approved => false,
              :entered => false,
              :created => Time.now)
  #needed for drop downs.
  @courses=COURSES.all()
  @projects=PROJECTS.all()
  @actionlist=CASLIST.all()
  #
  redirect '/hours_entry_page'
end

# Time Entry Submission Backend
post '/submit/?' do
	if params[:checkbox] != nil
		obs = params[:checkbox]
		obs.each { |it|
			item = Item.first(:id => it)
			item.update(:submitted => true)
      item.update(:submit_time=>Time.now)
		}
		redirect "/hours_entry_page"
	else
		redirect "/hours_entry_page"
	end
end

post '/delete/?' do
  if params[:checkbox] != nil
    obs = params[:checkbox]
    obs.each { |it|
      item = Item.first(:id => it)
      item.destroy
    }
    redirect "/hours_entry_page"
  elsif params[:id] != nil
     puts "deleting single entry " + params[:id]
     item = Item.first(:id => params[:id])
     item.destroy
     redirect "/hours_entry_page"
  else
    redirect "/hours_entry_page"
  end
end

post '/submitapprovals' do
   if params[:checkbox] != nil
      approved = params[:checkbox]
      approved.each { |app|
      item = Item.first(:id => app)
         #modify so 2 different approvers are needed before it can go to accounts
         #current approver is user logged into session
         if (item.approvecount==1 && item.approver1!=session[:username]) then
           item.update(:approver2 => session[:username])
           item.update(:approv2_time=>Time.now)
           item.update(:approvecount=>2)
           item.update(:approved=>true)
         elsif (item.approvecount==0)
           item.update(:approver1 => session[:username]) #flags time entry ready for accounts
           item.update(:approv1_time=>Time.now)
           item.update(:approvecount=>1)
           item.update(:approved=>false)
         end
      }
   end
   redirect session[:currentpage]
end

get '/submit/:id/?' do
  @item = Item.first(:id => params[:id])
  erb :submit
end

post '/submit/:id/?' do
   if params.has_key?("ok")
      #retreive entry from database
      item = Item.first(:id => params[:id])
      #submit selected entry
      puts "submitting entry for user: #{@user}"
      item.update(:submitted => true)
      item.update(:submit_time=>Time.now)
   end
   redirect "/hours_entry_page"
end

#the submit all and reset functions are form based (not javascript) and return here
post "/submit" do
	return true;
end


get '/disapprove/:id/?' do
	@item = Item.first(:id => params[:id])
	erb :disapprove, :layout => false
end

post '/disapprove/:id/?' do
   if params.has_key?("ok")
      #retreive entry from database
      item = Item.first(:id => params[:id])
      #new entry to is set to entered/unsubmitted state by default
      puts "creating new entry for disapproved user: #{@user}"
      Item.create(:activity => item[:activity],
                  :created => item[:created],
                  :user => item[:user],
                  :firstname => item[:firstname],
                  :lastname => item[:lastname],
                  :date => item[:date],
                  :hours => item[:hours],
                  :start => item[:start],
                  :end => item[:end],
                  :Cgroup => item[:Cgroup],
                  :subgroup  => item[:subgroup],
                  :notes => item[:notes],
                  :man_note =>params[:MGMTnotes])
      #set disapproved entry to deleted state
      puts "deleting old entry for disapproved user: #{@user}"
      item.update(:man_note => params[:MGMTnotes])
      item.update(:submitted => false)
      item.update(:deleted => true)
      item.update(:delete_time => Time.now)
		item.update(:entered => false)
		item.update(:approved => false)
   end
	   redirect session[:currentpage]
end


# Edit Entries
get '/edit/:id/?' do
  @item = Item.first(:id => params[:id])
  @courses=COURSES.all()
  @projects=PROJECTS.all()
  @actionlist=CASLIST.all()
  erb :edit, :layout => false
end

post '/edit/:id/?' do
	if params.has_key?("ok")
      #retreive entry from database
		item = Item.first(:id => params[:id])
      #set entry fields again
      puts "editing entry for user: #{@user}"
		item.update(:activity => params[:activity])
		item.update(:date => Date.strptime(params[:date], '%d/%m/%Y'))
		item.update(:hours => params[:hours])
		item.update(:start => params[:startTime])
		item.update(:end => params[:endTime])
		item.update(:Cgroup => params[:Cgroup])
      if params[:subgroup] != nil
         item.update(:subgroup  => params[:subgroup])
      end
		item.update(:notes => params[:notes])
      item.update(:man_note => params[:MGMTnotes])
	end
   redirect session[:currentpage]
end

# Display Backend
get "/reload" do
	@items = Item.all(:order => :created.desc)
	@display = params[:LoadedValues]
  setViewdata()
  #needed for drop downs.
  @courses=COURSES.all()
  @projects=PROJECTS.all()
  @actionlist=CASLIST.all()
  #
	erb :hours_entry_page
end

# Delete Entry
get '/delete/:id/?' do
   @item = Item.first(:id => params[:id])
   erb :delete
end

post '/delete/:id/?' do
   if params.has_key?("ok")
      #retreive entry from database
      item = Item.first(:id => params[:id])
      #set entry to deleted state
      puts "deleting entry for user: #{@user}"
      item.update(:submitted => false)
      item.update(:deleted => true)
      item.update(:delete_time => Time.now)
      item.update(:entered => false)
      item.update(:approved => false)
   end
   redirect "/hours_entry_page"
end

get '/pdfSaveAccounts/' do
  userid = params[:id]
  item = Item.first(:id => userid)
  @testme=item.user
  populateCAS(@testme)
end

post '/enterapprovals' do
    #manager logged in to approve

   if params[:checkbox] != nil && params[:cbdisapprove] == nil
      entered = params[:checkbox]
      entered.each { |app|
         item = Item.first(:id => app)
         item.update(:entered => true) #time entry entered
         item.update(:HR_time=>Time.now)
      }
   end
   redirect "/accounts_page"
end
