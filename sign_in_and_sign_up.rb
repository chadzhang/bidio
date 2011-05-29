require File.dirname(__FILE__) + '/helpers/bidio.rb'
require File.dirname(__FILE__) + '/helpers/config_table.rb'
require File.dirname(__FILE__) + '/helpers/data_default.rb'
require "rubygems"
gem "rspec"
gem "selenium-client"
require "selenium/client"
require "selenium/rspec/spec_helper"

bidio = Bidio.new

page = bidio.create_selenium_browser
page.start_new_browser_session

describe "test" do

  before(:all) do
    @verification_errors = []
  end

  append_after(:each) do
    @verification_errors.should == []
  end
   
  describe "Test Sign In" do

    $test_server = "http://test.bid.io"
    $test_homepage = "http://test.bid.io/home"
    
    $real_server = "http://vip.bid.io"
    $real_homepage = "http://vip.bid.io/home"

    $local_server = "http://localhost:3000"
    $local_homepage = "http://localhost:3000/home"
   
    $local = "http://localhost:3000"
    $target_server = $local 
    # $target_server = $real_server 
    $target_homepage = "#{$target_server}/home"

    page.open $target_server

    it "Should in Bid.io homepage after accessing the popup.(Please check the URL and some features that belong to homepage.)" do
      page.click "link=access the private alpha", :wait_for => :page
      
      home_page = page.get_location()
      # home_page.should eql("#{$target_homepage}")
      # page.is_text_present("Start right now!")
      # page.is_text_present("bid.io is your social commerce solution").should be_true
    end
    
    

    describe "Sign in with email adress" do
      
      it "(1) In the Sign in screen.Make sure the Sign Up link exist." do
        page.click "link=Sign In", :wait_for => :page
        
        page.is_element_present("link=Sign up here!").should be_true
      end
      
      it "(2)	Make sure you cannot sign in with the invalid email address." do
        invalid_email = {"a@" => "a", "abc" => "abc", "ab12" => "23s", "ss@gmail" => "@a", "as@td//" => "//13"}
        
        invalid_email.each { |key, value|
          bidio.sign_in(page,"#{key}","#{value}")
          page.is_text_present("Invalid email or password.").should be_true
          page.is_element_present("link=Sign Out").should be_false
          page.click "link=Sign In", :wait_for => :page
          page.is_text_present("Invalid email or password.").should be_false
        }

      end
      
      it "(3)	Make sure you cannot sign in with the inexistence account." do
        inexistence_email = {"a@gmail.com" => "a", "abc@gmail.com" => "abc", "ab12@163.com" => "23s", "ss@yahoo.com" => "@a", "as@126.com" => "//13"}
        
        inexistence_email.each { |key, value|
          bidio.sign_in(page,"#{key}","#{value}")
          page.is_text_present("Invalid email or password.").should be_true
          page.is_element_present("link=Sign Out").should be_false
          page.click "link=Sign In", :wait_for => :page
          page.is_text_present("Invalid email or password.").should be_false
        }
      end
      
      it "(4) Make sure you cannot sign in with the wrong password." do
        wrong_password = {"a@bidiodev.com" => "aa", "a@bidiodev.com" => "abc", "b@bidiodev.com" => "23s", "c@bidiodev.com" => "@a", "c@bidiodev.com" => "//13"}
        
        wrong_password.each { |key, value|
          bidio.sign_in(page,"#{key}","#{value}")
          page.is_text_present("Invalid email or password.").should be_true
          page.is_element_present("link=Sign Out").should be_false
          page.click "link=Sign In", :wait_for => :page
          page.is_text_present("Invalid email or password.").should be_false
        }
      end
      
      it "(5)	In the sign in screen, make sure the submitted button’s value is Sign In,not Sign up." do
        page.is_element_present("//input[@value='Sign In']").should be_true
        page.is_element_present("//input[@value='Sign Up']").should be_false
      end
      
      it "(6)	Make sure you can sign in different browser.(Safari,FF,IE8,IE7 and IE6)" do
        # Right now,we only check the FF here. 
      end
      
      it "(7)	You should get word verification after login failure for X times." do
        # will check this after bug3690 is fixed.
        
        # 5.times do
        #   bidio.sign_in(page,"a@bidiodev.com","aaa")
        # end
        
      end
      
      it "(8)	After login,make sure the Sign Out link exist." do
        bidio.sign_in(page,"a@bidiodev.com","a")
        page.is_element_present("link=Sign Out").should be_true
      end
    end   
  end  
  
  
  
  
  
  describe "Test Sign Up" do
    
    it "(1)In the sign in screen.Click the “Sign Out here!” link should flow to the sign up screen. Please check the url should be http://test.bid.io/sign_up" do
      page.click "link=Sign Out", :wait_for => :page if page.is_element_present("link=Sign Out")
      page.click "link=Sign up here!", :wait_for => :page
    end
    
    describe "Sign up with email adress" do
      
      it "(1)	In the Sign up screen. Make sure the Sign In link exist." do
        page.is_element_present("link=Sign In").should be_true
        page.is_element_present("link=Sign in here!").should be_true
      end
      
      it "(2) Make sure you cannot sign up with the invalid email address." do
        invalid_email = {"a@" => "a", "abc" => "abc", "ab12" => "23s", "ss@gmail" => "@a", "as@td//" => "//13"}
        
        invalid_email.each { |key, value|
          bidio.sign_up(page,"#{key}","#{value}","#{value}", "1234455")
          page.is_text_present("is invalid").should be_true
          page.is_text_present("doesn't match confirmation").should be_false
        }
      end
      
      it "(3)	Make sure you cannot sign up with the existence account." do
        existence_email = {"a@bidiodev.com" => "a", "b@bidiodev.com" => "b", "c@bidiodev.com" => "c"}
        
        existence_email.each { |key, value|
          bidio.sign_up(page,"#{key}","#{value}","#{value}", "1242144")
          page.is_text_present("has already been taken").should be_true
        }
      end
      
      it "(4) Make sure you cannot sign up if password doesn’t match the confirm password." do
        mail = {"aa@gmail.com" => "aa", "abc@163.com" => "abc", "tt@126.com" => "tt"}
        
        mail.each { |key, value|
          bidio.sign_up(page,"#{key}","#{value}","#{value}ss", "324552")
          page.is_text_present("doesn't match confirmation").should be_true
        }
      end
      
      it "(5) In the Sign up screen, make sure the submited button’s value is Sign up,not Sign in." do
        page.is_element_present("//input[@value='Sign In']").should be_false
        page.is_element_present("//input[@value='Sign Up']").should be_true
      end
      
      it "(6) Make sure you can sign up different browser.(Safari,FF,IE8,IE7 and IE6)" do
        # Right now,we only check the FF here.
      end
    end  
  end
  
     
end