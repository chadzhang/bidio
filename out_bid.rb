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

  $admin = "c@bidiodev.com"
  $user1 = "z@bidiodev.com"
  $seller1 = "k@bidiodev.com"
  $test_pw = "a"

  $users = [$admin, $user1, $seller1]

  def test_a_before_auction_start_and_live_auction
  	bidio = Bidio.new
  	auction = "27-inch iMac"
  	bid_price_field = "bid_price"
  	bidding_note = "bidding_notice"
  	element = ["place_bid_form", "bid_price", "bid_price_slider", "place_bid_btn"]
  	
    # @@page.open "#{$target_server}/sign_in"
  	@@page.open $target_server
    # bidio.access_private_alpha(@@page)
    
    for user in $users
      # bidio.click_link(@@page, "Sign In")
      
      @@page.open "#{$target_server}/sign_in"
      bidio.sign_in(@@page, user, "a")
      bidio.click_link(@@page, auction)
      
      current_price = bidio.get_current_price(@@page)
      min_price = @@page.get_text("css=div.min_price").delete("$").to_i
      bid_cp_min = if min_price == current_price
        min_price
      else
        current_price+rand(min_price-current_price)
      end
      @@page.type bid_price_field, bid_cp_min
      @@page.click "place_bid_btn"
      bid = bidio.ts(bid_cp_min.to_s)
      bidio.wait_for_text(@@page,"$#{bid}")
      bidio.wait_for_text(@@page, "00:00:")
      sleep 1
      @@page.get_text(bidding_note) =~ /(\d+):(\d+):(\d+)/
      time = $3.to_i
      sleep time+10
      element.each { |element|
        assert !@@page.element?(element)
      }
      assert !@@page.text?("Your Drop Out Price is")
      # assert @@page.text?("You're out! There were too many other people still interested in buying the item when your dropout price was reached. Better luck next time!")
      assert @@page.text?("You're out! There were too many other people still interested in buying the item when your Drop Out Price was reached. Better luck next time!")
      
      bidio.sign_out(@@page)
    end
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
