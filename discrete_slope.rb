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
  :browser => "*chrome",
  :url => "http://localhost:3000/",
  :timeout_in_second => 60
@@page.start_new_browser_session

@@page2 = Selenium::Client::Driver.new \
  :host => "localhost",
  :port => 4444,
  :browser => "*chrome",
  :url => "http://localhost:3000/",
  :timeout_in_second => 60
@@page2.start_new_browser_session



class Submit_bids < Test::Unit::TestCase
  
  def teardown
    # page.close_current_browser_session
  end
  
  $real_server = "http://vip.bid.io"
  $local = "http://localhost:3000"
  
  $target_server = $local #$real_server

  $auction_1 = "21.5-inch iMac 2.7GHz Quad-Core Intel Core i5"
  $auction_qty_1 = 1
  $auction_start_price_1 = 1799
  $auction_2 = "27-inch iMac 2.7GHz Quad-Core Intel Core i5"
  $auction_qty_2 = 5
  $auction_start_price_2 = 2099
  $auction_3 = "30-inch Cinema HD"
  $auction_qty_3 = 1
  $auction_start_price_3 = 1299
  # $auctions = [$auction_1, $auction_2, $auction_3]
  $auctions = [$auction_1, $auction_2]
  # $auctions = [$auction_1]

  $admin = "c@bidiodev.com"
  $admin2 = "b@bidiodev.com"
  $user1 = "z@bidiodev.com"
  $seller1 = "k@bidiodev.com"

  $users = [$admin2, $user1, $seller1]

  $slope_amount = "clock_auction_slope_amount_holder"
  $slope_interval = "slope_interval_selector"
  $slope_interval_field = "slope_interval_field"
  $slope_type = "slope_type"

  def test_a_setting_slope
	bidio = Bidio.new
	     
	@@page.open "#{$target_server}/sign_in"
	bidio.sign_in(@@page,"#{$admin}","#{$test_pw}")
	bidio.create_auction_step_1(@@page, "Mac mini 2.66GHz 500GB", "")
	slope_element = [$slope_amount, $slope_interval, $slope_interval_field, $slope_type]
	slope_element.each { |element|
	  if element == $slope_interval_field
		assert !@@page.element?(element)
	  else
		assert @@page.element?(element)
	  end
	}
	
	assert_equal(@@page.get_attribute("css=#slope_type > option:nth_child(2)@selected"), "selected")
	
	@@page.select slope_interval, "Other..."
	sleep 1
	assert @@page.element?($slope_interval_field)
	asseet !@@page.element?($slope_interval)
	
	# type some invalid in the slope interval field. should not able to save!
	
	@@page.type $slope_interval_field, 1
	@@page.type $slope_amount, 10
	bidio.click(@@page,"auction_submit")
	
	assert_equal(@@page.get_table("//tbody.0.2"), "$10 per 1 mins")
	assert_equal(@@page.get_table("//tbody.1.2"), "Increase Rate")
	
  end


  def test_b_setting_match_displays
    bidio = Bidio.new
    
    5.times {
	  bidio.click(@@page,"//input[@value='Edit']")  
	  interval = rand(20)+1
	  amount = rand(100)+1
	  @@page.type $slope_interval_field, interval
	  @@page.type $slope_amount, amount
	  bidio.click(@@page,"auction_submit")

	  assert_equal(@@page.get_table("//tbody.0.2"), "$#{amount} per #{interval} mins")
	  assert_equal(@@page.get_table("//tbody.1.2"), "Increase Rate")
    }
  end



  def test_c_check_slope_increment_in_live_auction
    bidio = Bidio.new

    
    for auction in $auctions
      bidio.create_auction_step_1(@@page, auction, "")
	  if auction =~ /21.5-inch/
	    bidio.create_auction_step_2(@@page, "Clock Auction", $auction_start_price_1)
	  elsif auction =~ /27-inch/
	    bidio.create_auction_step_2(@@page, "Clock Auction", $auction_start_price_2)
	  end
	
	  bidio.click(@@page,"//input[@value='Edit']")
	  
	  

    end

     
    interval = 1
	amount = 4
	@@page.type $slope_interval_field, interval
	@@page.type $slope_amount, amount
	bidio.click(@@page,"auction_submit")
    bidio.click(@@page,"//input[@value='Publish']")

    for user in $users
      bidio.sign_in(@@page2, user, "#{$test_pw}")
      bidio.join_auction(@@page2, "21.5-inch iMac")
      bid = bidio.generate_bid(@@page2)
      bidio.placed_bid(@@page2, bid)
      bidio.sign_out(@@page2)
    end

    if @@page.get_location() =~ /localhost/
	  bidio.click_link(@@page,"start auction now!")
	  sleep 30
	  bidio.refresh_page(@@page)
	  
	end

  end




  
  def test_d_auction_start_and_submit_bids
    bidio = Bidio.new

  end
  
  # def test_e_
  # 
  # end
  # 
  # def test_f_
  # 
  # end
  # 
  # def test_g_
  # 
  # end
end
