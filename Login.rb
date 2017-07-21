# Cut-down login file for offline emulation of active_directory_user.rb
# By Craig Duncan 17-18 September 2016, 28-6 October 2016


require_relative "active_directory_dummy.rb"
# on C dev server use this: require_relative "active_directory_user.rb"

module Sinatra
  module ADAuth
    class CLogin
      attr_accessor :username, :authenticated, :fullname, :access, :firstname, :lastname, :group, :groupArray
		  puts "------------------------------"
		  entry="userID"
      #comment out next line when running on C dev server
      ActiveDirectoryUser=ADUser.new(entry)

        def groupArray
          return @groupArray
        end

        def initialize(username, password)
            begin
				          puts "Initialize called from within Login object"
				          puts "username #{username}"
				          auth = ActiveDirectoryUser.authenticate(username, password)
                  if !(auth) then puts "login issues" end
                  if auth
                       @groupArray= Array.new
                       @firstname = auth.first_name
                       @lastname=auth.last_name
                       @fullname=auth.fullname
                       @username = username
                       @authenticated = true
                       @access= :teacher
                       if auth.groups.include? "C-Casual_Timesheet-Approver_StudyTours" then
                              puts "ST group in array"
                              @access = :admin
                              @groupArray.push("Study Tours")
                              @group= "Study Tours"
                              #@groupArray.push("ST")
                       end
                       if auth.groups.include? "C-Casual_Timesheet-Approver_BC" then
                              puts "BC group in array"
                               @access = :admin
                               @group= "Bridging Course"
                               #@groupArray.push("BC")
                               @groupArray.push("Bridging Course")
                       end
                       if auth.groups.include? "C-Casual_Timesheet-Approver_ELICOS" then
                              puts "EL group in array"
                               @access = :admin
                               @group= "ELICOS"
                               #@groupArray.push("EL")
                               groupArray.push("ELICOS")
                       end
                       if auth.groups.include? "C-Casual_Timesheet-Accounts" then
                              puts "AC group in array"
                               @access = :accounts
                               #@group = :Accounts_Staff
                               @groupArray.push("Accounts_Staff")
                       end
                     else
                     @authenticated = false
                     puts "authentication failed inside Login"
   			            end

                     #put this last: rescue any interpreter or runtime errors etc
                     rescue
                       @authenticated = false
                       puts "authentication: #{@authenticated}"

            end
   	     end
		  end
	end
end
