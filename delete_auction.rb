require File.dirname(__FILE__) + '/helpers/bidio.rb'
require File.dirname(__FILE__) + '/helpers/config_table.rb'
require File.dirname(__FILE__) + '/helpers/data_default.rb'
require "must_be"

require "test/unit"
require "rubygems"
gem "selenium-client"
require "selenium/client"


@@selenium = Selenium::Client::Driver.new \
	    :host => "localhost",
	    :port => 4444,
	    :browser => "*chrome",
	    :url => "http://localhost:3000/",
	    :timeout_in_second => 60
@@selenium.start_new_browser_session

class Submit_bids < Test::Unit::TestCase

	def teardown
	  # @selenium.close_current_browser_session
	end
      
    $real_server = "http://vip.bid.io"
    $local = "http://localhost:3000"
    # $target_server = $real_server 
    $target_server = $local

	  $admin_mail = "c@bidiodev.com"
	  $admin_pw = "a"
	  $admin2_mail = "d@bidiodev.com"
	  $admin2_pw = "a"
	  $user1_mail = "z@bidiodev.com"
	  $user1_pw = "a"
	  $seller1_mail = "k@bidiodev.com"
	  $seller1_pw = "a"
  
	  $auction_title = "13-inch: 2.7 GHz MacBook Pro"
	  $auction_link = "//a[contains(text(),'13-inch: 2.7 GHz MacB')]"
	  $detail_link = "link=See bid details"
	  $delete_link = "link=Delete this auction."

  def test_a_delete_unpublished_auction
    bidio = Bidio.new
    
    @@selenium.open $target_server
    @@selenium.open "#{$target_server}/sign_in"
    # bidio.sign_out(@@selenium) if @@selenium.element?("link=Sign Out")
    bidio.sign_in(@@selenium,"#{$admin_mail}","#{$admin_pw}")
    bidio.create_auction_step_1(@@selenium, $auction_title, "")
    bidio.create_auction_step_2(@@selenium, "Clock Auction")
    assert_equal(@@selenium.get_text("css=#auction_status h3"), "UNPUBLISHED")
    assert @@selenium.element?("link=delete this auction.")
    assert @@selenium.element?($detail_link)
    
    bidio.click_link(@@selenium, "delete this auction.")
    pop_text = @@selenium.get_confirmation()
    assert_equal(pop_text, "Are you sure you wish to delete #{$auction_title}?")

    bidio.goto_dashboard(@@selenium)
    assert !@@selenium.text?("13-inch: 2.7 GHz MacB")
    assert !@@selenium.element?($auction_link)
  end


   

	  def test_b_delete_unpublished_auction_in_detail_page
	    bidio = Bidio.new
	   
	    # @@selenium.open "#{$target_server}/sign_in"
	    bidio.sign_out(@@selenium) if @@selenium.element?("link=Sign Out")
	    bidio.sign_in(@@selenium,"#{$admin_mail}","#{$admin_pw}")
	    bidio.create_auction_step_1(@@selenium, $auction_title, "")
	    bidio.create_auction_step_2(@@selenium, "Clock Auction")
	
	    bidio.click_link(@@selenium, "See bid details")
	    assert @@selenium.element?($delete_link)
	    assert @@selenium.element?("link=Audit")
	    
	    bidio.click(@@selenium, $delete_link)
	    pop_text = @@selenium.get_confirmation()
	    assert_equal(pop_text, "Are you sure you wish to delete #{$auction_title}?")
	
	    bidio.goto_dashboard(@@selenium)
	    assert !@@selenium.text?("13-inch: 2.7 GHz MacB")
	    assert !@@selenium.element?($auction_link)
	  end
	
	  
	
	  def test_c_delete_published_auction
	    bidio = Bidio.new
	   
	    # @@selenium.open "#{$target_server}/sign_in"
	    bidio.sign_out(@@selenium) if @@selenium.element?("link=Sign Out")
	    bidio.sign_in(@@selenium,"#{$admin_mail}","#{$admin_pw}")
	    bidio.create_auction_step_1(@@selenium, $auction_title, "")
	    bidio.create_auction_step_2(@@selenium, "Clock Auction")
	    bidio.click(@@selenium,"//input[@value='Publish']")
    	assert !@@selenium.text?("UNPUBLISHED")
    	assert @@selenium.text?("Note that as a seller, you are not allowed to bid.")
      # assert @@selenium.element?("link=start auction now!") if @@selenium.get_location() =~ /localhost/   # This link only available in development mode
    	assert @@selenium.element?($detail_link)
    	assert_equal(@@selenium.get_text("css=#auction_status h3"), "PUBLIC\nnot yet started")
	    
	    bidio.click(@@selenium, $detail_link)
	    assert @@selenium.element?($delete_link)
	    assert @@selenium.element?("link=Audit")
	    
	    bidio.click(@@selenium, $delete_link)
	    pop_text = @@selenium.get_confirmation()
	    assert_equal(pop_text, "Are you sure you wish to delete #{$auction_title}?")
	
	    bidio.goto_dashboard(@@selenium)
	    assert !@@selenium.text?("13-inch: 2.7 GHz MacB")
	    assert !@@selenium.element?($auction_link)
	    bidio.goto_browse_auctions(@@selenium)
	    assert !@@selenium.text?("13-inch: 2.7 GHz MacB")
	    assert !@@selenium.element?($auction_link)
	  end
	
	
	
	  # def test_d_delete_live_auction
	  # 
	  # end
	
	
	
	
	
	  def test_e_delete_over_auction
	    bidio = Bidio.new
	
	    # @@selenium.open "#{$target_server}/sign_in"
	    bidio.sign_out(@@selenium) if @@selenium.element?("link=Sign Out")
	    if @@selenium.get_location() =~ /localhost/
  	    bidio.sign_in(@@selenium,"#{$admin_mail}","#{$admin_pw}")
  	    bidio.create_auction_step_1(@@selenium, $auction_title, "")
  	    bidio.create_auction_step_2(@@selenium, "Clock Auction")
  	    bidio.click(@@selenium,"//input[@value='Publish']")
  		  bidio.click(@@selenium, "link=start auction now!")
	
  	    assert_equal(@@selenium.get_text("css=#auction_status h3"), "OVER")
  	    assert @@selenium.text?("There was no winner.")
  	    # assert @@selenium.text?("This Auction is OVER.") # This text is for the bidders, not for creater.
  	    assert @@selenium.element?($detail_link)
	
  	    bidio.goto_dashboard(@@selenium)
  	    assert @@selenium.text?("13-inch: 2.7 GHz MacB")
  	    assert @@selenium.element?($auction_link)
  	    bidio.goto_browse_auctions(@@selenium)
  	    assert @@selenium.text?("13-inch: 2.7 GHz MacB")
  	    assert @@selenium.element?($auction_link)
	
  	    bidio.click(@@selenium, $auction_link)
  	    bidio.click(@@selenium, $detail_link)
  	    assert @@selenium.element?($delete_link)
  	    assert @@selenium.element?("link=Audit")
	
  	    bidio.click(@@selenium, $delete_link)
  	    pop_text = @@selenium.get_confirmation()
  	    assert_equal(pop_text, "Are you sure you wish to delete #{$auction_title}?")
	
  	    bidio.goto_dashboard(@@selenium)
  	    assert !@@selenium.text?("13-inch: 2.7 GHz MacB")
  	    assert !@@selenium.element?($auction_link)
  	    bidio.goto_browse_auctions(@@selenium)
  	    assert !@@selenium.text?("13-inch: 2.7 GHz MacB")
  	    assert !@@selenium.element?($auction_link)
	
  	    bidio.sign_out(@@selenium)
	
  	    [$user1_mail, $seller1_mail, $admin2_mail].each { |user|
  		  bidio.sign_in(@@selenium,"#{user}","a")
  		  bidio.goto_dashboard(@@selenium)
  		  assert !@@selenium.text?("13-inch: 2.7 GHz MacB")
  		  assert !@@selenium.element?($auction_link)
  		  bidio.goto_browse_auctions(@@selenium)
  		  assert !@@selenium.text?("13-inch: 2.7 GHz MacB")
  		  assert !@@selenium.element?($auction_link)
  		  bidio.sign_out(@@selenium)
  	    }
	    end
	  end
  
end
