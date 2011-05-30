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
  
  # $target_server = $local 
  $target_server = $real_server 

  $auction_1 = "MacBook Air 11 inch"
  $auction_qty_1 = 1
  $auction_start_price_1 = 899

  $auctions = [$auction_1]

  $admin = "b@bidiodev.com"
  $admin2 = "c@bidiodev.com"
  $admin2_name = "Al Nimbly"
  $user1 = "z@bidiodev.com"
  $user1_name = "Zhong Nimbly"
  $seller1 = "k@bidiodev.com"
  $seller1_name = "Kathy Nimbly"
  $test_pw = "a"
  $phone = "134567890"
  $users = [$admin2, $user1, $seller1]
  
  $set_price_button = "place_bid_btn"

  def test_a_create_auctions
  	bidio = Bidio.new
	      
	  @@page.open $target_server
  	@@page.open "#{$target_server}/sign_in"
  	bidio.sign_in(@@page,"#{$admin}","#{$test_pw}")   
  	$bid_table = "css=table.bids > tbody > tr"
  	for auction in $auctions
  	  bidio.create_auction_step_1(@@page, auction, "")
  	  if auction =~ /11/
  	    bidio.create_auction_step_2(@@page, "Clock Auction", $auction_start_price_1, start_time = "", $auction_qty_1)
  	  elsif auction =~ /17/
  	    bidio.create_auction_step_2(@@page, "Clock Auction", $auction_start_price_2, start_time = "", $auction_qty_2)
  	  else
  	    bidio.create_auction_step_2(@@page, "Clock Auction", $auction_start_price_3, start_time = "", $auction_qty_3)
  	  end
	        
  	  assert_equal(@@page.get_text("css=#auction_status h3"), "UNPUBLISHED")
        bidio.click(@@page,"//input[@value='Publish']")
  	  assert_equal(@@page.get_text("css=#auction_status h3"), "PUBLIC\nnot yet started")
  	end
  	bidio.goto_browse_auctions(@@page)
  	bidio.click_link(@@page, $auction_1)
  	bidio.click_link(@@page, "See bid details")
  	assert !@@page.element?($bid_table)
  end


  def test_b_diffrent_users_submit_bids_before_auction_start
    bidio = Bidio.new
    
    @@page2.open $target_server
    @@page2.open "#{$target_server}/sign_in"
    # button_Im_in =  "//input[@value='I\'m In!']"    # input[@class='iamin_button']
    set_price = "//input[@value='Set Price']"
    button_Im_in = "//input[@class='iamin_button']"
    bid_price_field = "bid_price"
    save_bid_note = "Bid submitted successfully!"

    indicate_text = "Click \"I'm In\" to enter this auction! You will be prompted to set a DropOut price on the next page."
    for user in $users

  	  if user =~ /c@/
  	    target_user, name = $admin2, $admin2_name
  	  elsif user =~ /z@/
  	    target_user, name = $user1, $user1_name
  	  else
  		  target_user, name = $seller1, $seller1_name
  	  end

      bidio.sign_in(@@page2, user, "#{$test_pw}")
      bidio.goto_browse_auctions(@@page2)
      bidio.click_link(@@page2, $auction_1)
      assert @@page2.element?(button_Im_in)
      assert @@page2.is_editable(button_Im_in)
      assert @@page2.text?(indicate_text)
      assert !@@page2.visible?(bid_price_field)
      assert !@@page2.text?("Your Drop Out Price")
      assert_equal(@@page2.get_attribute("css=#place_bid_btn@value"), "I'm In!")
      
      @@page2.click button_Im_in
      bidio.wait_for_text(@@page2,"Your Drop Out Price")
      sleep 1
      assert !@@page2.text?(save_bid_note)
      assert @@page2.text?("Your Drop Out Price hasn't been set yet!")
      assert !@@page2.text?(indicate_text)
      assert !@@page2.element?(button_Im_in) # use visible if fail
      
      # start_price = @@page2.get_table("//tbody.0.1").delete("$").to_i
      start_price = @@page2.get_table("//tfoot.0.1").delete("$").to_i
      # @@page2.get_table("//tbody.0.2") =~ /\$(.*) per (.*) min/
      @@page2.get_table("//tfoot.0.2") =~ /\$(.*) per (.*) min/
      slope_inc = $1.to_i
      assert_equal(start_price, $auction_start_price_1)
      # assert_equal(@@page2.get_table("//tbody.0.3").to_i, $auction_qty_1)
      assert_equal(@@page2.get_value(bid_price_field).to_i, start_price)
      assert_equal(@@page2.get_text("css=div.min_price"), "$#{start_price+slope_inc}")
      assert_equal(@@page2.get_text("max_price"), "$#{10*start_price}")
      assert @@page2.element?(set_price)
      assert @@page2.is_editable(set_price)
      
      bid_min_max = start_price+rand(10*start_price-start_price)
      bid_more_max = 10*start_price+rand(10*start_price)
      a = rand
      valid_decimal_bid =  if (100*a).floor > 0
        start_price+rand(10*start_price-start_price)+(100*a).floor/100
      else
	      start_price+rand(10*start_price-start_price)+(10000*a).floor/10000
      end
      bid_less_sp = rand(start_price)
      invalid_decimal_bid = start_price + (10000*rand).floor/10000

      invalid_bid = ["rvfs", "@@!!", "457dgv","~123", "998j@#", "-#{bid_min_max}"]
      valid_bid = [bid_min_max, valid_decimal_bid, bid_more_max]

      # bidio.refresh_page(@@page)
      # assert @@page.element?($bid_table)
      first_row = {"0" => "#{name} (#{target_user})", "1" => "#{$phone}", "2" => "$#{start_price}", "4" => "IN"}
      
      # CSS already change, will check the following current:
      # first_row.each { |k, v| assert_equal(@@page.get_table("//tbody.0.#{k}"), v) }
      # first_row.each { |k, v| assert_equal(@@page.get_table("//tfoot.0.#{k}"), v) }
      # ===================================================================================
      
      for bid in invalid_bid
        bidio.placed_invalid_bid(@@page2, bid)
        assert_equal(@@page2.get_value(bid_price_field), bid)
        assert_equal(@@page2.get_text("bid_price_error"), "Invalid price.")
        assert @@page2.text?("Your Drop Out Price hasn't been set yet!")

        # bidio.refresh_page(@@page)
        # assert @@page.element?($bid_table)
        # first_row.each { |k, v| assert_equal(@@page.get_table("//tbody.0.#{k}"), v) }
      end

      @@page2.type bid_price_field, bid_less_sp
      @@page2.click $set_price_button
      sleep rand
      assert_equal(@@page2.get_value(bid_price_field).to_i, bid_less_sp)
      assert @@page2.text?("Please bid at least $#{start_price}")
      assert @@page2.text?("Your Drop Out Price hasn't been set yet!")

      # bidio.refresh_page(@@page)
      # assert @@page.element?($bid_table)
      # first_row.each { |k, v| assert_equal(@@page.get_table("//tbody.0.#{k}"), v) }

      @@page2.type bid_price_field, invalid_decimal_bid
      @@page2.click $set_price_button
      sleep rand
      assert_equal(@@page2.get_value(bid_price_field).to_f, invalid_decimal_bid)
      assert @@page2.text?("Your Drop Out Price hasn't been set yet!")
      # assert @@page2.text?("") # Currently,the text is incorrct.

      # bidio.refresh_page(@@page)
      # assert @@page.element?($bid_table)
      # first_row.each { |k, v| assert_equal(@@page.get_table("//tbody.0.#{k}"), v) }

      for bid in valid_bid
        previous_bid = ""
        if @@page2.get_text("bid_price_error") == ""
	        previous_bid = @@page2.get_value("bid_price")
	      end

        @@page2.type bid_price_field, bid
        assert @@page2.is_editable($set_price_button)
        @@page2.click $set_price_button
        assert_equal(@@page2.get_value(bid_price_field).to_i, bid)
        bid = bidio.ts(bid.to_s)
        bidio.wait_for_text(@@page2,"$#{bid}")
        sleep rand
        assert !@@page2.is_editable($set_price_button)
        assert @@page2.text?("Your Drop Out Price is $#{bid}")
        assert @@page2.text?(save_bid_note)
        sleep 10 # 10 seconds later,this msg should fade.
        assert !@@page2.text?(save_bid_note)
      

        #         bidio.refresh_page(@@page)
        #         start_price = bidio.ts(start_price.to_s) if !(start_price =~ /,/)
        #         assert @@page.element?($bid_table)
        #         for i in 0 .. 1
        #           assert_equal(@@page.get_table("//tbody.#{i}.0"), "#{name} (#{target_user})")
        #           assert_equal(@@page.get_table("//tbody.#{i}.1"), "#{$phone}")
        #         end
        # 
        #         assert_equal(@@page.get_table("//tbody.0.2"), "$#{bid}")
        # if previous_bid == ""
        #           assert_equal(@@page.get_table("//tbody.1.2"), "$#{start_price}")
        #         else
        #   previous_bid = bidio.ts(previous_bid.to_s)
        #   assert_equal(@@page.get_table("//tbody.1.2"), "$#{previous_bid}")
        # end
        #   
        # assert_equal(@@page.get_table("//tbody.0.4"), "IN")
        # assert_equal(@@page.get_table("//tbody.1.4"), "REPLACED")
      end
      bidio.sign_out(@@page2)
    end
  end





  def test_c_creater_should_not_able_to_submit_the_bids
    bidio = Bidio.new
    @@page.go_back()
    assert @@page.text?("Note that as a seller, you are not allowed to bid.")
    assert !@@page.element?("//input[@class='iamin_button']")
    bidio.click_link(@@page, "See bid details")
  end




  
  def test_d_auction_start_and_submit_bids
    bidio = Bidio.new
    
    auction = "27-inch iMac"
    start_price = 899
    save_bid_note = "Bid submitted successfully!"
  
    bidio.sign_out(@@page2) if @@page2.element?("link=Sign Out")
    
    for user in $users
      bidio.sign_in(@@page2, user, "#{$test_pw}")
      bidio.goto_browse_auctions(@@page2)
      bidio.click_link(@@page2, auction)
      
      bid = bidio.generate_bid(@@page2)
      bidio.placed_bid(@@page2, bid)
      if user =~ /c@/
          c_first_price = bid
        elsif user =~ /z@/
          z_first_price = bid
        else
          k_first_price = bid
        end
        bidio.sign_out(@@page2)
      end
      
      
      bidio.goto_browse_auctions(@@page)
      bidio.click_link(@@page, auction)
      bidio.click_link(@@page,"See bid details")
      
      @@page2.open "#{$target_server}/sign_in"
  
      set_price = "//input[@value='Set Price']"
      button_Im_in = "//input[@class='iamin_button']"
      bid_price_field = "bid_price"
  
        for user in $users
        if user =~ /c@/
          target_user, name = $admin2, $admin2_name
          first_price = c_first_price
          first_price = bidio.ts(first_price.to_s)
        elsif user =~ /z@/
          target_user, name = $user1, $user1_name
          first_price = z_first_price
          first_price = bidio.ts(first_price.to_s)
        else
          target_user, name = $seller1, $seller1_name
          first_price = k_first_price
          first_price = bidio.ts(first_price.to_s)
        end
  
        bidio.sign_in(@@page2, user, "#{$test_pw}")
        bidio.goto_browse_auctions(@@page2)
        bidio.click_link(@@page2, auction)
        assert !@@page2.element?(button_Im_in) 
        assert @@page2.element?(set_price)
        assert @@page2.is_editable(set_price)
  
        min_price = @@page2.get_text("css=div.min_price").delete("$").to_i
          bid_min_max = min_price+rand(10*start_price-min_price)
        invalid_bid = ["rvfs", "@@!!", "457dgv","~123", "998j@#", "-#{bid_min_max}"]
        for bid in invalid_bid
          bidio.placed_invalid_bid(@@page2, bid)
          assert_equal(@@page2.get_text("bid_price_error"), "Invalid price.")
          assert @@page2.text?("Your Drop Out Price of $#{first_price}")
          
          bidio.refresh_page(@@page)
          assert @@page.element?($bid_table)
          assert !@@page.text?(bid)
        end
        
        invalid_decimal_bid = start_price + (10000*rand).floor/10000.0
        @@page2.type bid_price_field, invalid_decimal_bid
        @@page2.click $set_price_button
        sleep 1
        assert_equal(@@page2.get_value(bid_price_field), invalid_decimal_bid.to_s)
        assert @@page2.text?("Your Drop Out Price of $#{first_price}")       
        bidio.refresh_page(@@page)
        assert @@page.element?($bid_table)
        assert !@@page.text?(invalid_decimal_bid)
        
        current_price = bidio.get_current_price(@@page2) #@@page2.get_table("//tbody.0.1")
        current_price_with_comma = bidio.ts(current_price.to_s)
        bid_less_sp = rand(start_price)
        bid_betw_sp_cp = start_price + rand(current_price-start_price)
        puts "bid_betw_sp_cp is : #{bid_betw_sp_cp}"
        low_bids = [bid_less_sp, bid_betw_sp_cp]
        for bid in low_bids
          @@page2.type bid_price_field, bid
          @@page2.click $set_price_button
          sleep rand
          assert_equal(@@page2.get_value(bid_price_field).to_i, bid)
          # assert @@page2.text?("Please bid at least $#{current_price_with_comma}")  # Probably a bug here!!!
          assert @@page2.text?("Your Drop Out Price of $#{first_price}")
          
          bidio.refresh_page(@@page)
          assert @@page.element?($bid_table)
          assert !@@page.text?(bid)
        end
          
          current_price = bidio.get_current_price(@@page2)
          min_price = @@page2.get_text("css=div.min_price").delete("$").to_i
          bid_cp_min = if min_price == current_price
            min_price
          else
            current_price+rand(min_price-current_price)
          end
          bid_min_max = min_price+rand(10*start_price-min_price)
          bid_more_max = 10*start_price+rand(10*start_price)
          valid_bid = [bid_cp_min, bid_min_max, bid_more_max]
        for bid in valid_bid
          previous_bid = ""
          if @@page2.get_text("bid_price_error") == ""
            previous_bid = @@page2.get_value("bid_price")
          end
  
          @@page2.type bid_price_field, bid
          assert @@page2.is_editable($set_price_button)
          @@page2.click $set_price_button
          assert_equal(@@page2.get_value(bid_price_field).to_i, bid)
          bid = bidio.ts(bid.to_s)
          bidio.wait_for_text(@@page2,"$#{bid}")
          sleep rand
          assert !@@page2.is_editable($set_price_button)
          assert @@page2.text?("Your Drop Out Price of $#{bid}")
          assert @@page2.text?(save_bid_note)
          sleep 11
          assert !@@page2.text?(save_bid_note)
  
          #           bidio.refresh_page(@@page)
          #           assert @@page.element?($bid_table)
          #           assert_equal(@@page.get_table("//tbody.0.0"), "#{name} (#{target_user})")
          #           assert_equal(@@page.get_table("//tbody.0.1"), "#{$phone}")
          #           assert_equal(@@page.get_table("//tbody.0.2"), "$#{bid}")
          # assert_equal(@@page.get_table("//tbody.0.4"), "IN")
          end
        bidio.sign_out(@@page2)
      end
  end
  
  # def test_e_slider_show_in_correct_place
  #   bidio = Bidio.new
  # 
  # 
  # end

end
