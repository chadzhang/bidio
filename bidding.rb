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

arr_page = [page, page2, page3]

arr_page.each { |browser|
  browser = bidio.create_selenium_browser
  browser.start_new_browser_session
}

# page = bidio.create_selenium_browser
# page.start_new_browser_session
# 
# page2 = bidio.create_selenium_browser
# page2.start_new_browser_session
# 
# page3 = bidio.create_selenium_browser
# page3.start_new_browser_session


# ================================================================================================================================
# This script will use following mail for testing.

# seller email:  bidioseller@sina.com  PW:seller
# buyer email:  (1)buyer1@sina.cn PW:buyer1 (2)bidbuyer2@sina.cn PW:buyer2 (3)buyer3@sina.com PW:buyer3 (4)buyer4@sina.cn PW:buyer4
# =================================================================================================================================

describe "test" do

  before(:all) do
    @verification_errors = []
  end

  append_after(:each) do
    @verification_errors.should == []
  end
   
  describe "General" do

    $test_server = "http://test.bid.io"
    $test_homepage = "http://test.bid.io/home"
    
    $real_server = "http://bid.io"
    $real_homepage = "http://bid.io/home"
    
    $seller_mail = "bidioseller@sina.com"
    $seller_pw = "seller"
    
    $buyer1_mail = "buyer1@sina.cn"
    $buyer1_pw = "buyer1"
    $buyer1_phone = "1234567"
    
    page.open $test_server

    it "Should in Bid.io homepage after accessing the popup.
      (Please check the URL and some features that belong to homepage.)" do
      # page.click "link=access the private alpha", :wait_for => :page
      bidio.access_private_alpha(page) if page.element?("link=access the private alpha")
    end
    
    

    describe "0. Invite seller_email as seller to create an auction" do
      
      it "a) Login as a@bidiodev.com/a, goes to Admin page and invite seller_email as a seller, send the invitation." do
        # page.click "link=Sign In", :wait_for => :page
        bidio.sign_in(page,"a@bidiodev.com","a")
        bidio.invite_seller(page,"#{$seller_mail}")
        
        page.is_text_present("Seller invitation sent to: #{$seller_mail}")
      end
      
      it "b)	seller_email will get an email which includes an invitation link, use that link to sign up an account" do
        page2.open opt(:sina_mail)
        bidio.login_sina_mail(page2,"#{$seller_mail}","$seller_pw")
        sleep 5
        bidio.read_mail_content(page2)
        page2.click "//a[contains(text(),'http://test.bid.io/sign_up/')]", :wait_for => :page
      end
      
      it "c)	After sign_up an account, he will get an confirmation email, confirm it so that he can create an auction later." do
        # fill the username and PW will past the popip window.
        page2.select_window(opt(:title))
        bidio.sign_up(page2,"#{username}","#{seller_pw}","#{seller_pw}")
        
        
      end
      
      it "d) Successfully be an seller account with seller_email." do

      end
      
      it "e) Logout" do

      end
      
    end   
  end  
  
  
  
  
  
  describe "1. Firstly seller should create an auction, and publish it" do
    
    it "a. Login as seller_email, go to /seller/listings and then click the button “New Auction” " do
      bidio.sign_out(page) if page.element?("link=Sign Out")
      bidio.sign_up(page,"a@bidiodev.com", "a")
      bidio.click_link(page,"Dashboard")
    end
    
    describe "Start to create the new auction" do
      
      it "b. Fill with the following textfields:" do
	    title = "iPad with Wi-Fi + 3G 64GB"
	    description = 
	    "The best way to experience the web, email, photos, and video. Hands down.\n
		+ Height: 9.56 inches (242.8 mm)\n
		+ Width: 7.47 inches (189.7 mm)\n
		+ Depth: 0.5 inch (13.4 mm)\n
		+ Weight: 1.6 pounds (0.73 kg) Wi-Fi + 3G model\n
		+ Capacity: 64GB flash drive\n
		A magical and revolutionary product and cool present for the Chinese Rabbit Year at an unbelievable price.Starting at $200."
		bidio.create_auction_step_1(page,"#{title}","#{description}")  
		bidio.create_auction_step_2(page, "Clock Auction", start_price = "", start_time = "", qty = "", reserve_price = "", duration = "")
		
		page.text?(title).should be_true
		page.text?("Starting Price: $10").should be_true
      end
      
      it "c. After create the above auction, you can still edit it as it’s still not published to bidders.  
             Try edit it by changing the Title to “iPad with Wi-Fi + 3G 64GB for Chinese Rabbit Year”, save it and see whether it’s changed successfully. 
             Also change the price to “$288” and save it, check again." do
	    
	    bidio.click(page,"//input[@value='Edit']")
		bidio.edit_clock_auction(page, title = "iPad with Wi-Fi + 3G 64GB for Chinese Rabbit Year", start_time = "", start_price = "288")
		page.text?("iPad with Wi-Fi + 3G 64GB for Chinese Rabbit Year").should be_true
		page.text?("Starting Price: $288").should be_true
      end
      
      it "d. Publish the above auction by clicking “Publish” button in the auction page. 
             Right now bidders see the auction and enter bids." do
	    bidio.click(page,"//input[@value='Publish']")
	    
	    page2.open $test_server
	    bidio.access_private_alpha(page2) if page2.element?("link=access the private alpha")
	    bidio.sign_in(page,"b@bidiodev.com","b") # incorrect PW
	
	
	
	
	    
      end
      
      it "e. Check for seller_email’s email box, he should get email that the auction is published." do
	    # Will check this later
      end
      
      it "f. Logout." do
        bidio.sign_out(page) 
      end
      
      it "(6) Make sure you can sign up different browser.(Safari,FF,IE8,IE7 and IE6)" do
        # Will check this later
      end
    end  
  end



  describe "2. As bidder go to enter bids(not yet sign_up bidder)" do
	
	it "a. Don’t login, go to /listings and click the iPad auction that just created, enter bid “$360” and click “Save”, it will redirect to /sign_in page" do
	  page2.open $test_server
	  bidio.access_private_alpha(page2) if page2.element?("link=access the private alpha")
	  bidio.click_link(page2,"Browser Auctions")	
	  bidio.click_link(page2,"iPad with Wi-Fi + 3G 64GB for Chinese Rabbit Year")
	  bidio.placed_bid(page2,"300")
	  
	  page2.text?("Sign In").should be_true
	  page2.get_location.match(/\/sign_in/).should be_true
	end
	
	it "b. In /sign_in page, click “Sign up here” link, and fill with email_I, then it creates an bidder account. 
	       Check for the email_I mailbox and see the confirmation email, click on it." do
	  bidio.sign_up(page2, "#{$buyer1_mail}", "#{$buyer1_pw}", "#{$buyer1_pw}", "#{$buyer1_phone}")
	  page3.open opt(:sina_mail)
      bidio.login_sina_mail(page3,"#{$buyer1_mail}","#{$buyer1_pw}")
	  
	  
	end
	
	it "c. After email_I confirms his email, he will get a popup with a bid “$360”, click “Confrim bid” button then it will redirect to the auction and successfully entered the bid “$360”" do
		
	end
	
	it "d. email_I check for the email, he will get that he has entered a bid “$360” for the iPad email." do
		
	end
	
	it "e. Logout" do
		
	end	
  end


  describe "3. As bidder to enter bids(existing bidder)" do
	
	it "a. Login as email_II, go to the iPad auction that just created, entered bid “$100” and click “Save”, fail with error tip." do
	  page2.open $test_server
	  bidio.access_private_alpha(page2) if page2.element?("link=access the private alpha")
	  bidio.sign_in(page2,"buyer1@sina.cn","buyer1")	
	  bidio.click(page2,"Browser Auctions")
	  bidio.click_link(page2,"iPad with Wi-Fi + 3G 64GB for Chinese Rabbit Year")
      bidio.placed_bid(page2,"100")
      page2.text?("").should be_true
	end
	
	it "b. Re-enter the bid “$399”, successfully" do
	  bidio.placed_bid(page2,"399")
      page2.text?("").should be_true	
	end
	
	it "c. email_II will get an email that he has entered a bid with “$399”" do
	  
	end
	
	it "d. Logout." do
	  bidio.sign_out(page2)
	end
  end


  describe "4. Sign_up through facebook to enter bids(email_III)" do
	
	it "a. In sign_in page, click “Login with facebook”, then in /missing_email page, enter the email email_III." do
		
	end
	
	it "b. Check for email_III mailbox and confirm the email link." do
		
	end
	
	it "c. After confirm the email, go to the new created iPad page and enter a bid with “$468”, successfully." do
		
	end
	
	it "d. Check for the mail, you will get that you have entered a email with “$468”" do
		
	end
	
	it "e. Logout." do
		
	end
  end


  describe "5. After auction starts, bidder who hasn’t placed bid can’t place bid" do
	
	it "a. Login as seller(seller_email) can check all bidders bids by clicking “See bid details” link, check if the bids are correct:
	       email_I:$360, email_II:$399, email_III:$468" do
		
	end
	
	it "b. Starts auction, in dev, you can make auction starts by clicking “start auction now!” link" do
		
	end
	
	it "c. Check that seller_email and all bidders who have entered bids will get an email that the auction has been started." do
		
	end
	
	it "d. Logout seller_email" do
		
	end
	
	it "e. Login as “c@bidiodev.com/a”(this email is already existing in the system), check that he can’t entered bids as he didn’t entered bids before auction starts. Logout" do
		
	end
  end


  describe "6. After auction starts and price keep going up, the bidder whose bid is OUT can’t place bid" do
	
	it "a. After auction starts, the price will keep going up, waiting for the price reaches $360" do
		
	end
	
	it "b. Login as email_I, he found that his bid is OUT and he can’t place bid anymore" do
		
	end
	
	it "c. Check for email_I email, he will get an email that his bid is OUT." do
		
	end
	
	it "d. Logout" do
		
	end
  end


  describe "7. The bidder who still in can change his bid" do
	
	it "a. Login as email_II, his bid is $399 and still in" do
		
	end
	
	it "b. Change his bid to $419, successfully" do 
	
	end
	
	it "c. Check for email_II, he get an email that has has just placed $419 bid." do
		
	end
	
	it "d. Logout" do
		
	end
  end


  describe "8. Auction is concluded" do
	
	it "a. After price will going and reach $419, the aution is over" do
		
	end
	
	it "b. Login as seller_email, on the iPad aution page, he will get that the auction is over with winner name (facebook account user) 
	       and the winning price($419), check for the email as well, he will get the “Auction concluded” email with above information. Logout." do 
	
	end
	
	it "c. Login as email_I, on the iPad auction page, he will get the auction is over and he is fail in this auction with the winning price. 
	       Check the email as well. Logout." do
		
	end
	
	it "d. Login as email_II, on the iPad auction page, he will get the auction is over and he is fail in this auction with the winning price. 
	       Check the email as well. Logout." do
		
	end
	
	it "e. Loing as facebook account(email_III), on the iPad auction page, he will get that he auction is over and he won in this auction with winning price($419). 
	       Check the email as well. Logout." do
		
	end
  end
  
     
end