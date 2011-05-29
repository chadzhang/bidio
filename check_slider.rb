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

  $auction_1 = "27-inch iMac"
  $auction_2 = "Apple Displays"
  $auctions = [$auction_1, $auction_2]

  $admin = "c@bidiodev.com"
  $user1 = "z@bidiodev.com"
  $seller1 = "k@bidiodev.com"
  $test_pw = "a"

  $users = [$admin, $user1, $seller1]

  $slope_amount = "clock_auction_slope_amount_holder"
  $slope_interval = "slope_interval_selector"
  $slope_interval_field = "slope_interval_field"
  $slope_type = "slope_type"

  def test_a_before_auction_start_and_live_auction
  	bidio = Bidio.new
  	auctions = ["iPad", "Cartier Watch"]
  	button_Im_in = "//input[@class='iamin_button']"
  	
  	@@page.open "#{$target_server}/sign_in"
  	
  	for auction in auctions
  	  for user in $users
  	    puts "\nRight now testing #{user.inspect} in #{auction.inspect} Auction.\n"
  	    
        bidio.sign_in(@@page, user, "a")

        bidio.goto_browse_auctions(@@page)
        bidio.click_link(@@page, auction)
        if @@page.element?(button_Im_in)
          @@page.click button_Im_in
          bidio.wait_for_text(@@page,"Your Drop Out Price")
          sleep 1
        end

        max_place = bidio.get_max_slider(@@page)

        min_price = bidio.get_min_price(@@page)
        bidio.placed_bid(@@page, min_price)
        current_place = bidio.get_slider_place(@@page)
        assert_equal(current_place, 0)

        max_price = bidio.get_max_price(@@page)
        new_max_price = max_price+rand(2*max_price-max_price)
        bidio.placed_bid(@@page, new_max_price)
        current_place = bidio.get_slider_place(@@page)
        assert_equal(current_place, max_place)

        5.times {
          min_price = bidio.get_min_price(@@page)
          bid = min_price+rand(max_price-min_price)
          bidio.placed_bid(@@page, bid)
          current_place = bidio.get_slider_place(@@page)
          expected_place = bidio.cal_slider_place(min_price, max_price, bid, max_place)

          assert_equal(current_place, expected_place)
        }

        puts "DONE,Test for user #{user.inspect} in #{auction.inspect} Auction is finished!\n"

        bidio.sign_out(@@page)
      end
  	end
    puts "\nAll the test for Slider pass!\n"
  end


  # def test_b_in_live_auction
  #   bidio = Bidio.new
  #   
  #   for user in $users
  #     bidio.sign_in(@@page, user, "a")
  #     
  #     bidio.goto_browse_auctions(@@page)
  #     bidio.click_link(@@page, auction)
  #     
  #     max_place = bidio.get_max_slider(@@page)
  #     
  #     min_price = bidio.get_min_price(@@page)
  #     bidio.placed_bid(@@page, min_price)
  #     current_place = bidio.get_slider_place(@@page)
  #     assert_equal(current_place, 0)
  #     
  #     max_price = bidio.get_max_price(@@page)
  #     new_max_price = max_price+rand(2*max_price-max_price)
  #     bidio.placed_bid(@@page, new_max_price)
  #     current_place = bidio.get_slider_place(@@page)
  #     assert_equal(current_place, max_place)
  #     
  #     5.times {
  #       min_price = bidio.get_min_price(@@page)
  #       bid = min_price+rand(max_price-min_price)
  #       bidio.placed_bid(@@page, bid)
  #       current_place = bidio.get_slider_place(@@page)
  #       expected_place = bidio.cal_slider_place(min_price, max_price, bid, max_place)
  #       
  #       assert_equal(current_place, expected_place)
  #     }
  #     
  #     puts "\nTest for #{user.inspect} is finish!\n"
  #     
  #     bidio.sign_out(@@page)
  #   end
  # end
  
  # def test_d_auction_start_and_submit_bids
  #   bidio = Bidio.new
  # 
  # end

end
