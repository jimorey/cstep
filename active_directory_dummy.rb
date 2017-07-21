# Cut-down login file for active_directory
# By Craig Duncan 17-18 September 2016
# Replace with active_directory_user.rb for online access
#
# this will perform 'authentication' and read in server information from a YAML file, as the Perego file originally intended
#
# the active directory code that C uses from github (original author Ernie Miller, later changes by Paolo Perego) is written as a Sinatra extension
#
# Perego's code comes with a licence that allows modification but it must contain the copyright notice:
#  AS FOLLOWS: Copyright (c) 2012, Paolo Perego - <thesp0nge@gmail.com> All rights reserved.  (No reference to Miller's terms)
# Source:  https://github.com/thesp0nge/sinatra_ad_auth/blob/master/LICENSE
# i.e. 'Sinatra Active Directory auth is a simple sinatra extension to provide an authentication mechanism against an AD Server and some APIs you can use in your sinatra applications.'
# see this link for Perego's dependencies: https://github.com/thesp0nge/sinatra_ad_auth/blob/master/sinatra_ad_auth.gemspec
#

require 'net/ldap' # gem install net-ldap
require 'yaml'


module Sinatra
	module ADAuth
		class ADUser

			#setup
			@login
			@email
			@name
			@first_name
			@last_name
			# convert the value to a string before returning or calling your Proc.
		      	ATTR_SV = {
		        :login => :samaccountname,
		        :first_name => :givenname,
		        :last_name => :sn,
		        :email => :mail
		      }


		      # ATTR_MV is for multi-valued attributes. Generated readers will always
		      # return an array.
		      #
		      # 18/9/16 I am putting hard-coded values into this hash for now.  Craig.

               ATTR_MV = { :groups=>"C-Casual_Timesheet-Accounts", :displayname=>"Mr Dummy User"}

			#new method 21 September 2016 to update group data etc
			# this should be based on a simple loop that iterates through the YAML entries regardless of how many
			def read_AD(logstring)
				ufile="users.yaml"
				ud= YAML.load_file(ufile)
				puts "Reading user info as if it was AD data."
				ud.each do |key|
					key.each do |useritem|
						lgt=useritem["sAMAccountName"]
						if lgt.to_s==logstring.to_s
							@login=useritem["sAMAccountName"]
							puts "matched #{@login}"
							@first_name=useritem["givenname"]
							@last_name=useritem["sn"]
							@email=useritem["email"]
							@grouptest=useritem["group"]
							@groups=[" "]
							if (@grouptest==1)
								@groups=["C-Casual_Timesheet-Accounts"]
							end
							if (@grouptest==2)
								@groups=["C-Casual_Timesheet-Approver_BC"]
							end
							if (@grouptest==3)
								@groups=["C-Casual_Timesheet-Approver_BC","C-Casual_Timesheet-Approver_StudyTours","C-Casual_Timesheet-Approver_ELICOS"]  #make all groups for now
							end
							if (@grouptest==4)
								@groups=["C-Casual_Timesheet-Approver_BC","C-Casual_Timesheet-Approver_StudyTours"]  #make all groups for now
							end
							@name=useritem["displayname"]
							puts " : #{@first_name}"
							puts " : #{@last_name}"
							puts " : #{@group}"
							puts " : #{@groups}"
						end
					end
				end
				puts
				#this must appear as last line
				true
			rescue Exception => e
				puts e.to_s
				false
			end

			def initialize(entry)
        		@entry = entry
        		@name="Fred"
        		@group=["other"]
        		puts "About to read and update Groups for this User. initiliase function for #{entry}"
        		read_AD(entry)
        		#I am not sure what 'entry' value would be used, but hardcoded in login file for now.  Craig 18/9/16
       		puts "------------------------------"
       		puts "Initialized User object with #{@entry} as ID"
       		# update the groups data for the new object
     	 	end

      	def authenticate(logstring, pass)  #if you put self prefix they are private and can't be called from another file
       		return nil if logstring.empty? or pass.empty?

        		filename="ldap.yaml"
        		puts "Created instance of User; authenticate method running"
        		#this finds the configuration (socket) details
        		read_conf(filename)
        		# in the actual program it then binds to socket and finds the user details, then uses that to create new User object.
        		# here we just do a simple hardcode check and then create the new User object from that
        		puts "Testing login: #{logstring} pass: #{pass}"
        		if read_users(logstring,pass)
        			#return User.new(user)  #this should be self.new in original but we want to call this from outside so use User for now
        			puts "past the users--- returning object User"
							return ADUser.new(logstring)
        		else
							puts "failed login"
        			return nil
        		end
        		#original code has Net LDAP rescue erro handling here
        		end

			#functions to return fullname from the information provided by users
			def fullname
         fn=@first_name + ' ' + @last_name
				 return fn
      end

      def name
        nm= (@first_name.gsub("[", "").gsub("]", "").gsub("\"", ""))
				return nm
      end

        		# Read connection details found in YAML configuration file that is hardcoded
			def read_conf(conf)
				config= YAML.load_file(conf)
				@@server=config['ldap']['server']
				@@port=config['ldap']['port']
				@@base=config['ldap']['base']
				@@domain=config['ldap']['domain']
				print "your server is: ",@@server
				puts
				print "your port is: ",@@port
				puts
				print "your base is: ",@@base
				puts
				print "your domain is: ",@@port
				puts
				#this must appear as last line
				true
			rescue Exception => e
				puts e.to_s
				false
			end

			#method to check logged in user has password in our offline file
			def read_users(logstring, password)
				userfile="users.yaml"
				ud= YAML.load_file(userfile)
				puts "done YAML read"
				ud.each do |key|
					key.each do |useritem|
						lgt=useritem["sAMAccountName"]
						pwt=useritem["password"]
						if (lgt.to_s==logstring.to_s && pwt.to_s==password)
							puts "Passed login authentication:"
							puts useritem["sAMAccountName"]
							return true
						end
					end
				end
				puts
				#this must appear as last line
				false
			rescue Exception => e
				puts e.to_s
				false
			end


			#method to add a group to this user for testing
			def add_group(item)
				groups.push(item)
			end

			#method to test if user is in a group
			def member_of?(group)
        			self.groups.include?(group)
      		end

			#----my new simpler methods (i.e. not self-generated methods as per original file) ---
			def first_name
				puts " returning : #{@first_name}"
			return @first_name.to_s
			end

			def last_name
				puts " returning : #{@last_name}"
				return @last_name.to_s
			end

			def displayname
			return @name.to_s
			end

			def groups
			return @groups
			end

			def group
			return @group.to_s
			end
			#----

		end
	end
end
