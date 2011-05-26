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


page = bidio.create_selenium_browser
page.start_new_browser_session

# page2 = bidio.create_selenium_browser
# page2.start_new_browser_session
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
   
  describe "test" do

    $test_server = "http://test.bid.io"
    $real_server = "http://bid.io"

    $buyer1_mail = "buyer1@sina.cn"
    $buyer1_pw = "buyer1"
    $buyer1_phone = "1234567"
    
    $local_server = 'http://localhost:3000'
    
    $real_server = "http://vip.bid.io"
    $local = "http://localhost:3000"

    $target_server = $local #$real_server
    

    describe "Assumptions" do
      
      it "" do 
       

	
	
	
	
	
	

        # =========================
# 	    page.open $test_server
# 	    page.click "link=access the private alpha", :wait_for => :page
# 	    bidio.sign_in(page,"a@bidiodev.com","a")
# 	    bidio.click_link(page,"Dashboard")
# 	    title = "iPad with Wi-Fi + 3G 64GB"
# 	    description = 
# 	    "The best way to experience the web, email, photos, and video. Hands down.\n
# + Height: 9.56 inches (242.8 mm)\n
# + Width: 7.47 inches (189.7 mm)\n
# + Depth: 0.5 inch (13.4 mm)\n
# + Weight: 1.6 pounds (0.73 kg) Wi-Fi + 3G model\n
# + Capacity: 64GB flash drive\n
# A magical and revolutionary product and cool present for the Chinese Rabbit Year at an unbelievable price.Starting at $200."
#         bidio.create_auction_step_1(page,"#{title}","#{description}")  
#         bidio.create_auction_step_2(page, "Clock Auction", start_price = "", start_time = "", qty = "", reserve_price = "", duration = "")
# 


        # =======================
	    
	
	    
        # page.open opt(:sina_mail)
        # $seller_mail = "bidioseller@sina.com"
        # bidio.login_sina_mail(page,"#{$seller_mail}","seller")
        # sleep 5
        # bidio.read_mail_content(page)
        # page.click "//a[contains(text(),'http://test.bid.io')]", :wait_for => :page  

      end

      
      
      
    end   
    
 
     

  end  
  
     
end