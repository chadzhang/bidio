require File.dirname(__FILE__) + '/helpers/bidio.rb'
require File.dirname(__FILE__) + '/helpers/config_table.rb'
require File.dirname(__FILE__) + '/helpers/data_default.rb'
require "must_be"

require "test/unit"
require "rubygems"
gem "selenium-client"
require "selenium/client"

$page = Selenium::Client::Driver.new \
  :host => "localhost",
  :port => 4444,
  :browser => "*firefox",
  :url => "http://localhost:3000/",
  :timeout_in_second => 60
$page.start_new_browser_session

class Submit_bids < Test::Unit::TestCase
  
  def teardown
    # page.close_current_browser_session
  end
  
  $real_server = "http://vip.bid.io"
  $local = "http://bidio.local"
  $target_server = $real_server
  # $target_server = $local

  $user = "littlebidio@yahoo.com"
  $test_pw = "animbly"
  
  def test_a_connect_facebook
  	bidio = Bidio.new

    fb_link = "//div[@id='sign-in-twitter']/span/a"
    allow_button = "//input[@value='Allow']"

    $page.open $target_server
    $page.open "#{$target_server}/sign_in"
    # bidio.access_private_alpha($page)
    bidio.click_link($page, "Sign In")
  	
  	assert $page.text?("Sign in with your Facebook account")
  	
  	bidio.click($page, fb_link)
  	assert $page.text?("Facebook Login")
  	assert $page.text?("Log in to use your Facebook account with")
  	
  	bidio.sign_in_fb($page, $user, $test_pw)
  	
  	bidio.click($page, allow_button) if $page.element?(allow_button)
  	
  	texts = ["Hello, ", "© bid.io", "Browse Auctions"]
  	links = ["link=Browse Auctions", "link=Dashboard", "link=Sign Out"]
  	texts.each { |text| assert $page.text?(text)}
  	links.each { |link| assert $page.element?(link)}
  end


  def test_b_login_with_fb_should_be_able_to_submit_bid
    bidio = Bidio.new
    
    auction = "iPad"
    bid_price_field = "bid_price"
  	bidio.join_auction($page, auction)
  	
  	start_price = bidio.get_price($page)
    min_price = $page.get_text("css=div.min_price").delete("$").to_i
    bid_cp_min = if min_price == start_price+1
      min_price
    else
      start_price+rand(min_price-start_price)
    end
    bid_min_max = min_price+rand(10*start_price-min_price)
    bid_more_max = 10*start_price+rand(10*start_price)
    valid_bid = [bid_cp_min, bid_min_max, bid_more_max]
    for bid in valid_bid
      $page.type bid_price_field, bid.to_s
      # puts "bid is : #{bid.to_s}"
      $page.click "place_bid_btn"
      $page.key_press "bid_price", "\\13"
      assert_equal($page.get_value(bid_price_field).to_i, bid)
      bid = bidio.ts(bid.to_s)
      bidio.wait_for_text($page,"$#{bid}")
      sleep 1
      assert $page.text?("Your Drop Out Price is $#{bid}")
      assert $page.text?("Bid submitted successfully!")
      sleep 10
      assert !$page.text?("Bid submitted successfully!")

      # bidio.refresh_page(@@page)
      # assert @@page.element?($bid_table)
      # assert_equal(@@page.get_table("//tbody.0.0"), "#{name} (#{target_user})")
      # assert_equal(@@page.get_table("//tbody.0.2"), "$#{bid}")
      # assert_equal(@@page.get_table("//tbody.0.4"), "IN")
    end
  end
  
  # def test_d_auction_start_and_submit_bids
  #   bidio = Bidio.new
  # 
  # end

end
