require File.dirname(__FILE__) + '/helpers/bidio.rb'
require File.dirname(__FILE__) + '/helpers/config_table.rb'
require File.dirname(__FILE__) + '/helpers/data_default.rb'
require "rubygems"
gem "rspec"
gem "selenium-client"
require "selenium/client"
require "selenium/rspec/spec_helper"
require "must_be"


bidio = Bidio.new

# arr_page = [page, page2]
# 
# arr_page.each { |browser|
#   browser = bidio.create_selenium_browser
#   browser.start_new_browser_session
# }

page = bidio.create_selenium_browser
page.start_new_browser_session

puts "<<<<<<<<< #{page.class}"    # Selenium::Client::Driver

page2 = bidio.create_selenium_browser
page2.start_new_browser_session
# 
# page3 = bidio.create_selenium_browser
# page3.start_new_browser_session


describe "test" do

  before(:all) do
    @verification_errors = []
  end

  append_after(:each) do
    @verification_errors.should == []
  end
   
  describe "test_create_auction" do
	
	describe "Some data." do
	
	  it "test target." do
	    $test_server = "http://test.bid.io"
	    $test_homepage = "http://test.bid.io/home"
	
	    $real_server = "http://vip.bid.io"
	    $real_homepage = "http://vip.bid.io/home"
	
	    $local = "http://localhost:3000"
	    $local_homepage = "http://localhost:3000/home"	
	
      # $target_server = $real_server 
      $target_server = $local 
	  end
	
	  it "User's info" do
	    $admin_mail = "c@bidiodev.com"
	    $admin_pw = "a"
	    $admin2_mail = "d@bidiodev.com"
	    $admin2_pw = "a"
	    $user1_mail = "z@bidiodev.com"
	    $user1_pw = "a"
	    $seller1_mail = "k@bidiodev.com"
	    $seller1_pw = "a"
	  end
	
	  it "Clock Auction info" do
		$auction_title = "27 inch Apple Cinema displays"
	    $clock_sp = "499"
	    $clock_qty = "7"
	    $auction_link = "//a[contains(text(),'27 inch Apple Cinema')]"
	  end
	
	  it "Eproxy Auction info" do
	  	
	  end
	 end

    

	 describe "Login the System." do
	  it "Should in Bid.io homepage after accessing the popup." do
	    page.open $target_server
      $sell_item = "//input[@value='Sell Item']"
      # bidio.access_private_alpha(page) if page.element?("link=access the private alpha")
	  end 
	 end
	

     



    describe "You cannot create the Auction in following conditions: (1) you are not sign in; (2) you are noot seller." do
	
	  it "Not sign in yet." do
	  page.open "#{$target_server}/sign_in"
		bidio.click_link(page,"Create An Auction")
		
		text = [
		"Sorry, seller accounts are invite only.",
		"Thanks so much for your interest in bid.io auctions. During our alpha phase, we are only allowing invited participants to create auctions. If you wish to take part in our private alpha, please contact us.",
		"Feel free to browse the auctions or learn about our auctions."]		
	    text.each { |text|
		  page.text?(text).should be_true
	    }
	  end
	
	  it "Not seller account." do
		bidio.sign_in(page,"#{$user1_mail}","#{$user1_pw}")
	    bidio.click_link(page,"Dashboard")
	    page.element?($sell_item).should be_false
	    bidio.sign_out(page)
	  end
	end

    
    
    
    


    
	 describe "Create Auction: Step 1" do
		
	  it "Sin in as admin and goe to the Dashboard page." do
	    bidio.sign_in(page,"#{$admin_mail}","#{$admin_pw}")
	    bidio.click_link(page,"Dashboard")
	    page.element?($sell_item).should be_true
	    page.is_editable($sell_item).should be_true
	  end
	
	  it "Make sure the Tile and Description fields exsit, and they should be blank." do
		bidio.click(page,"//input[@value='Sell Item']")
		
		page.text?(opt(:step_1_subtitle)).should be_true
		page.element?(opt(:title)).should be_true
		page.element?(opt(:description)).should be_true
	    page.get_value(opt(:title)).should eql("")
	    page.get_value(opt(:description)).should eql("")
	  end
	
	  it "Make sure the button that is used to upload the picture is existed and editable." do
		page.element?(opt(:uplaod_div)).should be_true
		page.is_editable(opt(:upload_button)).should be_true
	  end
	
	  it "You cannot go to next if the Title is blank." do
		bidio.click(page,"listing_submit")
		
		opt(:setup_1).each { |e|
		   page.element?(e).should be_true
		}
	    page.get_value(opt(:title)).should eql("")
	    page.get_value(opt(:description)).should eql("")
		page.is_editable(opt(:upload_button)).should be_true
		page.text?("Title must contain at least 4 characters!").should be_true
	  end
	
	  it "Fill least than 4 characters in the title field, you should not be able to save it!" do
		error_title = "ip"
		page.type opt(:title), error_title
		bidio.click(page,"listing_submit")
	        
	    opt(:setup_1).each { |e|
		   page.element?(e).should be_true
		}
	    page.get_value(opt(:title)).should eql(error_title)
	    page.get_value(opt(:description)).should eql("")
		page.is_editable(opt(:upload_button)).should be_true
		page.text?("Title must contain at least 4 characters!").should be_true
	  end
	  
	  it "Fill more than 3 characters in the title field, you should be able to go to Next now!" do
		page.type opt(:title), $auction_title
		bidio.click(page,"listing_submit")
		
		opt(:setup_1).each { |e|
		   page.element?(e).should be_false
		}
		page.text?("Title must contain at least 4 characters!").should be_false
		page.text?(opt(:step_2_subtitle)).should be_true
	  end
	end
	
	
	
	describe "Test the Clock Auction." do
	  
	 # Right now the VIPAUCTION only use the Clock Auction
		# 	  it "Choose the auction." do
		# page.check opt(:clock_radio)
		# page.checked?(opt(:clock_radio)).should be_true
		# page.checked?(opt(:eproxy_radio)).should be_false
		# 	  end
	
	  it "Check the start price field." do
		page.element?(opt(:clock_sp_field)).should be_true
		b = page.get_value(opt(:clock_sp_field)) == ""
		b.should eql(false)
		page.type opt(:clock_sp_field), $clock_sp
		page.get_value(opt(:clock_sp_field)).should eql("499")
	  end	
	  
	  it "Check the start time field." do
		page.element?(opt(:clock_st_date)).should be_true
		
		# Will write more test ofor the time select
		
	  end
	
	  it "Check the Quantuty field" do
		page.element?(opt(:clock_qty)).should be_true
		page.get_value(opt(:clock_qty)).should eql("1")
		page.type opt(:clock_qty), $clock_qty
		page.get_value(opt(:clock_qty)).should eql("7")
	  end
	
	  it "Save the Auction." do
		bidio.click(page,"auction_submit")
	  end
	 end
	
	
	
	
	describe "Check the page after the new auction is saved." do
	
	  it "Check the text." do
		text = [
		  "UNPUBLISHED", 
		  "Before your auction is made public, you can edit it. You will not be able to edit after it is published",
		  "Make your auction public so anyone can view, and make bids", 
		  "If you no longer wish to sell this item, you may delete this auction.",
		  "27 inch Apple Cinema displays"
		]
		text.each { |text| page.text?(text).should be_true}
		
		page.get_table("//tbody.0.1").should eql("$#{$clock_sp}")
		# page.get_table("//tbody.0.3").should eql($clock_qty)
		
		table_second_row = { "0" => "Bidding Period", "1" => "Start Price", "2" =>"Increase Rate"}
		table_second_row.each { |k, v| 
		   page.get_table("//tbody.1.#{k}").should eql(v)
		}
	  end
	   
	  it "Check the elements." do
		element = ["link=delete this auction.", "//input[@value='Edit']", "//input[@value='Publish']"]
		
		element.each { |element|
		  page.element?(element).should be_true
		}
	  end
    end



    describe "As the Auction is not publish yet, check it isn't in the Browser Auctions." do
	
	  it "The creater checks the Browser Auctions page and Dashboard page." do
		bidio.goto_browse_auctions(page)
		page.element?($auction_link).should be_false
		bidio.goto_dashboard(page)
		page.element?($auction_link).should be_true
	  end
	
	  it "Other Bidder checks the Browser Auctions page and Dashboard page." do
	    page2.open $target_server
	    page2.open "#{$target_server}/sign_in"
	    bidio.access_private_alpha(page2) if page2.element?("link=access the private alpha")
	    [$user1_mail, $seller1_mail, $admin2_mail].each { |user|
		  bidio.sign_in(page2,"#{user}","a")
		  bidio.goto_browse_auctions(page2)
		  page2.element?($auction_link).should be_false
		  bidio.goto_dashboard(page2)
		  page2.element?($auction_link).should be_false
		  bidio.sign_out(page2)
	    }
	  end
	end
	
	
	
	describe "Publish the Auction. Chect it should be visible for everyone." do
		
	  it "Make it publish." do
		bidio.click(page,$auction_link)
		bidio.click(page,"//input[@value='Publish']")
		page.text?("UNPUBLISHED").should be_false
		page.text?("Note that as a seller, you are not allowed to bid.").should be_true
		page.get_text("css=#auction_status h3").should eql("PUBLIC\nnot yet started")
	  end
	  
	  it "Creater checks the Browse Auctions and Dashboard page." do
		  bidio.goto_browse_auctions(page)
		  page.element?($auction_link).should be_true
		  bidio.goto_dashboard(page)
		  page.element?($auction_link).should be_true
	  end
	
	  it "Check this auction available for others users in Browser Auctions page,but not for Dashborad page." do
		[$user1_mail, $seller1_mail, $admin2_mail].each { |user|
		  bidio.sign_in(page2,"#{user}","a")
		  bidio.goto_browse_auctions(page2)
		  page2.element?($auction_link).should be_true
		  bidio.goto_dashboard(page2)
		  page2.element?($auction_link).should be_false
		  bidio.sign_out(page2)
	    }
	  end
	
	  it "The Auction will show in the Dashboard page when click 'I'm In'" do
		# Will Write the Code when the bug is fixed.
		
		
		
	  end
		
    end




    describe "Delete the Auction,so this auction won't available for all the users.'" do
	
	  it "The creater deletes the auction." do
		bidio.delete_public_auction(page,"27 inch Apple Cinema")
		bidio.goto_browse_auctions(page)
		page.element?($auction_link).should be_false
	    bidio.goto_dashboard(page)
		page.element?($auction_link).should be_false
	  end
	
	  it "Check this Won't available for anyone.'" do
		[$user1_mail, $seller1_mail, $admin2_mail].each { |user|
		  bidio.sign_in(page2,"#{user}","a")
		  bidio.goto_browse_auctions(page2)
		  page2.element?($auction_link).should be_false
		  bidio.goto_dashboard(page2)
		  page2.element?($auction_link).should be_false
		  bidio.sign_out(page2)
	    }
	  end
	
    end
	
	
	
	
	
	
	
	
	
	 describe "Create the Auction in Step 2,don't save it and goes to another page.Back to Dashboard and check should not get any exception." do
		# bug3897 about this issue.
	   it "Create the Auction in Step1." do
		 bidio.create_auction_step_1(page,$auction_title,"")
	   end
	
	   it "Flow to anther page and back to Dashboard." do
		 bidio.goto_browse_auctions(page)
		 bidio.goto_dashboard(page)
		 text = ["Current Auctions", "Your Auction History"]
		 element = ["//input[@value='Sell Item']", "link=Account Info", "link=Preferences"]
		 text.each { |text| page.text?(text).should be_true }
		 element.each { |element| page.element?(element).should be_true }
	   end
	 end





 end
  
     
end