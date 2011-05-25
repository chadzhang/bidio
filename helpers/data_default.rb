# require "config_table.rb"
require File.join(File.dirname(__FILE__), "/config_table.rb")








def_option :sina_mail, "http://mail.sina.com.cn"

# def_option :title, "[TEST] bid.io (alpha)"

def_option :title, "listing_title"
def_option :description, "listing_desc"
def_option :upload_button, "ajax_upload_field_placeholder"
def_option :uplaod_div, "ajax_upload_div"

def_option :setup_1, ["listing_title", "listing_desc", "ajax_upload_div"]
def_option :clock_auction_element, []
def_option :eproxy_auction_element, []

def_option :step_1_subtitle, "Step 1: Describe The Item"
def_option :step_2_subtitle, "Step 2: Auction Setup"

def_option :clock_radio, "auction_type_ClockAuction"
def_option :eproxy_radio, "auction_type_EproxAuction"

def_option :clock_sp_field, "clock_auction_start_price_holder"
def_option :eproxy_sp_field, "eprox_auction_start_price_holder"

def_option :clock_st_date, "clock_auction_clock_start_time_date"
def_option :eproxy_st_date, ""

def_option :clock_qty, "clock_auction_supply"