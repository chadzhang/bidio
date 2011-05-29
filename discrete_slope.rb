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

class Submit_bids < Test::Unit::TestCase
  
  def teardown
    # page.close_current_browser_session
  end
  
  $real_server = "http://vip.bid.io"
  $local = "http://localhost:3000"
  # $target_server = $real_server
  $target_server = $local 

  $auction_1 = "27-inch iMac"
  $auction_2 = "Apple Displays"
  $auctions = [$auction_1, $auction_2]

  $admin2 = "a@bidiodev.com"
  $user1 = "z@bidiodev.com"
  $seller1 = "k@bidiodev.com"
  $test_pw = "a"

  $users = [$admin2, $user1, $seller1]

  $slope_amount = "clock_auction_slope_amount_holder"
  $slope_interval = "slope_interval_selector"
  $slope_interval_field = "slope_interval_field"
  $slope_type = "slope_type"

  def test_a_setting_slope
  	bidio = Bidio.new
	     
  	@@page.open "#{$target_server}/sign_in"
  	bidio.sign_in(@@page,"#{$admin2}","#{$test_pw}")
    bidio.create_auction_step_1(@@page, "Mac mini 2.66GHz 500GB", "")
    slope_element = [$slope_amount, $slope_interval, $slope_interval_field, $slope_type]
    slope_element.each { |element|
      if element == $slope_interval_field
      assert !@@page.visible?(element)
      else
      assert @@page.element?(element)
      end
    }
      
    assert_equal(@@page.get_attribute("//select[@id='slope_type']/option[2]@selected"), "selected")
    
    @@page.select $slope_interval, "Other..."
    sleep 1
    assert @@page.element?($slope_interval_field)
    assert !@@page.visible?($slope_interval)
      
    # type some invalid in the slope interval field. should not able to save!
      
    @@page.type $slope_interval_field, 1
    @@page.type $slope_amount, 10
    bidio.click(@@page,"auction_submit")
      
    assert_equal(@@page.get_table("//tbody.0.2"), "$10 per 1 min")
    assert_equal(@@page.get_table("//tbody.1.2"), "Increase Rate")
  
  end


  def test_b_setting_match_displays
    bidio = Bidio.new
    slope_amount = "auction_slope_amount_holder"
    slope_field = "auction_slope_interval_holder"
    
    5.times {
      bidio.click(@@page,"//input[@value='Edit']")  
      interval = rand(20)+1
      amount = rand(100)+1
      puts "\ninterval is:#{interval}, amount is:#{amount}\n"
      @@page.select $slope_interval, "Other..."
      sleep 1
      @@page.type slope_field, interval
      @@page.type slope_amount, amount
      sleep 1
      bidio.click(@@page,"listing_submit")
      if interval == 1
        assert_equal(@@page.get_table("//tbody.0.2"), "$#{amount} per #{interval} min")
      else
        assert_equal(@@page.get_table("//tbody.0.2"), "$#{amount} per #{interval} mins") # bug3494
      end
      assert_equal(@@page.get_table("//tbody.1.2"), "Increase Rate")
    }
    
    bidio.sign_out(@@page)
  end
  
  
  
  def test_c_check_slope_increment_in_live_auction
    bidio = Bidio.new
    
    bidio.sign_out(@@page) if @@page.element?("link=Sign Out")
    
    for user in $users
      bidio.sign_in(@@page, user, "a")
      
      for auction in $auctions
        bidio.goto_browse_auctions(@@page)
        bidio.click_link(@@page, auction)
        2.times {
          @@page.get_table("//tbody.0.2") =~ /\$(.*) per (.*) min/
          slope_inc = $1.to_i
          slope_interval = $2.to_i
          previous_price = bidio.get_price(@@page)
          expected_inc = previous_price + slope_inc
          time = 60*slope_interval
          puts "\nslope_inc is : #{slope_inc}, slope_interval is : #{slope_interval}, previous_price is : #{previous_price}, expected_inc is:#{expected_inc}, time is: #{time}\n"
          sleep time
          current_price = bidio.get_price(@@page)
          puts "current_price is : #{current_price}"
          assert_equal(current_price, expected_inc)    
        }
      end
      
      bidio.sign_out(@@page)
    end
  end




  
  def test_d_auction_start_and_submit_bids
    bidio = Bidio.new

  end

end
