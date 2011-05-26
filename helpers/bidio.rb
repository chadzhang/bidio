require "test/unit"
require "rubygems"
gem "selenium-client"
require "selenium/client"




module Helper

  def create_selenium_browser(opts={})
    Selenium::Client::Driver.new({
        :host => 'localhost',
        :port => 4444,
        :browser => "*chrome",
        :url => "http://192.168.1.4",
        :timeout_in_second => 60
    }.merge!(opts))
  end    


  def page_load(browser)
    browser.wait_for_page_to_load("30000")
  end

  def refresh_page(browser)
    browser.refresh()
    page_load(browser)
  end


  def wait_for_text(browser,text)
    until browser.text?("#{text}") do
      sleep 1
      break if browser.text?("#{text}")
    end
  end
  
  def wait_for_element(browser,element)
    until browser.is_element_present("#{element}") do
      sleep 1
      break if browser.is_element_present("#{element}")
    end
  end       

  def click_contain_text(browser,text)
    browser.click "//a[contains(text(),'#{text}')]", :wait_for => :page
  end
  
  def click_link(browser,link)
    browser.click "link=#{link}", :wait_for => :page
  end
  
  def click(browser,element)
    browser.click "#{element}", :wait_for => :page
  end

  def ts(st)
    st = st.reverse
    r = ""
    max = if st[-1].chr == '-'
      st.size - 1
    else
      st.size
    end
    if st.to_i == st.to_f
      1.upto(st.size) {|i| r << st[i-1].chr ; r << ',' if i%3 == 0 and i < max}
    else
      start = nil
      1.upto(st.size) {|i|
        r << st[i-1].chr
        start = 0 if r[-1].chr == '.' and not start
        if start
          r << ',' if start % 3 == 0 and start != 0  and i < max
          start += 1
        end
      }
    end
    r.reverse
  end

end









module General
  


  def access_private_alpha(browser)
    click_link(browser,"access the private alpha")
  end

  def sign_out(browser) 
   click_link(browser,"Sign Out")
  end
  
  def sign_up(browser, email, password, confirm_password, phone)
    click_link(browser,"Sign up here!") if browser.element?("link=Sign up here!")
    browser.type "user_email", email
    browser.type "user_password", password
    browser.type "user_password_confirmation", confirm_password
    browser.type "user_phone", phone

    browser.click "user_submit", :wait_for => :page
  end
  
  def sign_in(browser,email,password)
    click_link(browser,"Sign In")
    browser.type "session_email", email
    browser.type "session_password", password
    
    browser.click "session_submit", :wait_for => :page
  end
  
  def signin_as_twitter(browser,username,password)
    browser.type "username_or_email", username
    browser.type "session[password]", password
    
    browser.click "allow", :wait_for => :page
  end
  
  def login_sina_mail(browser,username,password)
    browser.type "//input[@class='input_text'][@name='username']", username
    browser.type "//input[@class='input_text'][@name='password']", password
    browser.click "btn_login1", :wait_for => :page
    browser.wait_for_condition("selenium.isTextPresent(\"<#{username}>\")","30000")
  end
  
  def read_mail_content(browser)
    browser.click "link=收件夹", :wait_for => :page
    browser.wait_for_condition("selenium.isElementPresent(\"//div[@id='maillist']/div/table/tbody/tr[1]/td[@class='w_subjet']/p/a\")","30000")
    browser.click "//div[@id='maillist']/div/table/tbody/tr[1]/td[@class='w_subjet']/p/a", :wait_for => :page
    browser.wait_for_condition("selenium.isTextPresent(\"support@bid.io\")","30000")
  end

  def generate_bid(browser)
    start_price = browser.get_table("//tbody.0.1").delete("$")
    if start_price =~ /,/
	  start_price = start_price.delete(",").to_i
	else
	  start_price = start_price.to_i
    end
    bid_min_max = start_price+rand(10*start_price-start_price)
    return bid_min_max
  end
 
end








module Flow_page

  def goto_dashboard(browser)
    click_link(browser,"Dashboard")
  end

  def goto_browse_auctions(browser)
    click_link(browser,"Browse Auctions")
  end

  def goto_admin(browser)
    click_link(browser,"Admin")
  end

  def goto_my_auctions(browser)
    click_link(browser,"My Auctions")
  end

end








module Browser_auctions

  def join_auction(browser, auction_text)
    button_Im_in = "//input[@class='iamin_button']"
    
    goto_browse_auctions(browser)
    click_contain_text(browser, auction_text)
    if browser.element?(button_Im_in)
	  browser.click button_Im_in
	  wait_for_text(browser,"Your Drop Out Price")
	  sleep 1
	else
	  puts "\nMaybe yuou already join this Auction!\n"
	end
  end

  
  def placed_bid(browser,bid)
    browser.type "bid_price", bid
    browser.click "place_bid_btn"
    bid = ts(bid.to_s)
    wait_for_text(browser,"$#{bid}")
    sleep rand
  end

  def placed_invalid_bid(browser, bid)
    browser.type "bid_price", bid
    browser.click "place_bid_btn"
    wait_for_text(browser,"Invalid price.")
    sleep rand
  end



end








module Dashborad

  def delete_public_auction(browser,text)
    goto_dashboard(browser)
    click_contain_text(browser,text)
    click_link(browser,"See bid details")
    click_link(browser,"Delete this auction.")
    browser.get_confirmation()
  end


  def create_auction_step_1(browser,title,description)
    goto_dashboard(browser)
    click(browser,"//input[@value='Sell Item']")
    browser.type "listing_title", title 
    browser.type "listing_desc", description
                                                        
    click(browser,"listing_submit")
  end

  def create_auction_step_2(browser, radio_button, start_price = "", start_time = "", qty = "", reserve_price = "", duration = "")
	clock_radio = "auction_type_ClockAuction"
	eproxy_radio = "auction_type_EproxAuction"  
	    
	auciton_type = radio_button.gsub(/ Auction/,"").downcase
	time_field = "#{auciton_type}_auction_clock_start_time_date"              
	start_price_field = "#{auciton_type}_auction_start_price_holder" 
	
	if radio_button =~ /Clock/ 
	  browser.type "clock_auction_supply", qty if qty != ""       	
	else
	  browser.check eprox_radio  
	  browser.type "eprox_auction_reserve_price_holder", reserve_price if reserve_price != ""
	  browser.type "eprox_auction_duration", duration if duration != ""
	end
	
	browser.type start_price_field, start_price if start_price != ""
	browser.type time_field, start_time if start_time != ""    
	
	click(browser,"auction_submit")
	# click_link(browser,"Continue") if browser.element?("link=Continue")
  end 

  

  def create_clock_auction_step_2(browser, radio_button, start_price = "", start_time = "", qty = "", amount = "", select_interver = "", fill_interval = "", slope_kind = "")
	clock_radio = "auction_type_ClockAuction"
	eproxy_radio = "auction_type_EproxAuction"  
	    
	auciton_type = radio_button.gsub(/ Auction/,"").downcase
	time_field = "#{auciton_type}_auction_clock_start_time_date"              
	start_price_field = "#{auciton_type}_auction_start_price_holder" 
	
	if radio_button =~ /Clock/ 
	       	
	else
	  browser.check eprox_radio  

	end
	
	# browser.type start_price_field, start_price if start_price != ""
	# browser.type time_field, start_time if start_time != ""  
	
	element = {
	  "clock_auction_slope_amount_holder" => amount,
      "clock_auction_slope_interval" => fill_interval,
      "slope_type" => slope_kind,
      "clock_auction_supply" => qty,
      start_price_field => start_price,
	  time_field => start_time
    }    
    
    slope.each { |k, v|
	  browser.type k, v if v!= ""
    }
    browser.select "slope_interval_selector", select_interval if select_interval != ""  
	
	  click(browser,"auction_submit")
  end
	



  def edit_clock_auction(browser, title = "", start_time = "", start_price = "", qty = "")
    listing_edit = {
	  "listing_title" => title,
	  "listing_desc" => description,
	  "auction_clock_start_time_date" => start_time,
	  "auction_start_price_holder" => start_price,
	  "auction_supply" => qty
    }
    
    listing_edit.each { |v, k|
	  browser.type v, k if v != ""
    }
    
    click(browser,"listing_submit")
  end



  def edit_slope(browser, amount = "", select_interver = "", fill_interval = "", slope_kind = "")
    click(browser,"//input[@value='Edit']")
     
    slope = {
	  "clock_auction_slope_amount_holder" => amount,
      "clock_auction_slope_interval" => fill_interval,
      "slope_type" => slope_kind
    }    
    
    slope.each { |k, v|
	  browser.type k, v if v!= ""
    }
    browser.select "slope_interval_selector", select_interval if select_interval != ""
    
    click(browser,"listing_submit")
  end
  
  
  def get_price(browser)
    price = browser.get_table("//tbody.0.1").delete("$")
    price.delete(",") if price =~/,/
    price = price.to_i  
    return price
  end

end






module My_auctions




end











module Admin
  
  def invite_seller(browser,email)
    browser.click "link=Admin", :wait_for => :page
    browser.type "invitation_recipient_email", email
    browser.click "invitation_submit", :wait_for => :page
  end
  
  
  
  
end





class Bidio
  
  include Helper
  include Flow_page
  include Admin
  include General
  include Browser_auctions
  include Dashborad
  include My_auctions
  
end


