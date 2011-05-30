require File.dirname(__FILE__) + '/helpers/bidio.rb'
require File.dirname(__FILE__) + '/helpers/config_table.rb'
require File.dirname(__FILE__) + '/helpers/data_default.rb'
require "must_be"

require "test/unit"
require "rubygems"
gem "selenium-client"
require "selenium/client"

@@page = Selenium::Client::Driver.new \
  :host => "localhost",
  :port => 4444,
  :browser => "*firefox",
  :url => "http://localhost:3000/",
  :timeout_in_second => 60
@@page.start_new_browser_session

class Submit_bids < Test::Unit::TestCase
  
  def teardown
    # page.close_current_browser_session
  end
  
  $real_server = "http://vip.bid.io"
  $local = "http://localhost:3000"
  # $target_server = $real_server
  $target_server = $local

  $admin = "c@bidiodev.com"
  $user1 = "z@bidiodev.com"
  $seller1 = "k@bidiodev.com"
  $test_pw = "a"

  $users = [$admin, $user1, $seller1]

  def test_a_before_auction_start_and_live_auction
  	bidio = Bidio.new
  	
    text = ["Personal Information", "Email Me Alert", "First Name", "Last Name"]
    email_checkbox = "user_email_alert"
    user_info = { 
      "user_given_name" => ,
      "user_family_name" => ,
      "user_email" => ,
      "user_phone" => 
    }
  	
  	@@page.open $target_server
  	@@page.open "#{$target_server}/sign_in"
  	
  	for user in $users
	    puts "\nRight now testing #{user.inspect} account!"
	    
      bidio.sign_in(@@page, user, "a")
      
      bidio.goto_my_account(@@page)
      text.each { |text| assert @@page.text?(text)}
      assert @@page.checked?(email_checkbox)
      @@page.check email_checkbox
      bidio.click(@@page, "//input[@value='Update']")
      assert !@@page.checked?(email_checkbox)
      
      user_info.each { |k, v| @@page.type k, v }
      bidio.click(@@page, "//input[@value='Update']")
      
      user_info.each { |k, v|
        assert_equal(@@page.get_value(k), v)
      }
      
      bidio.sign_out(@@page)
      
      puts "Testing #{user.inspect} account is finished!"
    end
  end

end
