

# Options in Alpaca - Changes made by Ulrich, 071212 in Bali
# 
# I added auction.config, which is a new ConfigTable to contain config info that should be saved with the auction state.
# 
# The Server Options are just a subset of the existing $options that is available to admin. The subset is defined in environment.rb


class ConfigTable
   
def initialize
  @h = {}
end

def []=(key,value)
  hash[key] = value
end

def [](key)
  key.must_be_a Symbol
  get_value(key)
end

def keys
  hash.keys
end                   
                                                                 
def get_value(key)
  hash[key][0] if hash[key]
end

def get_where(key)
  hash[key][1] if hash[key]
end

def update(h)
  h.must_be_a Hash
                        
  uname = Thread.current[:user] ? Thread.current[:user].name : "Unknown"
  aname = Thread.current[:auction] ? Thread.current[:auction].area : "Unknown"
  
  h.each_pair do |k,v|
    where_defined = "#{uname} in /#{aname} at #{Time.new.fmt(:geek)}"# this would be useless caller[1] # find the real caller, not this block  
    newval = v.strip 
    oldval = get_value(k.to_sym)
    # only typecast if the orig was not a string
    newval = string2useful(newval) if !oldval.nil? && !oldval.is_a?(String)     
    if oldval != newval
      hash[k.to_sym] = [newval, where_defined]
    end
  end
end   
               
def subset(keys)
  res = ConfigTable.new
  for key in keys
    res[key] = [get_value(key),get_where(key)]
  end          
  return res
end   

def set(what,val,where = nil)
  where ||= caller.first
  @h[what] = [val,where]
end

def string2useful(whatsit)
  return nil unless whatsit
  return whatsit unless whatsit.is_a? String
  return '' if whatsit == '' # 909 070321 ulrich
  return whatsit.to_i unless /[^\d]/.match(whatsit)
  return whatsit.to_f unless /[^\d,.]/.match(whatsit)
  return (whatsit == 'true' || whatsit == 'on') if /^(true|false|on|off)$/.match(whatsit)
  
  whatsit
end  

protected
def hash
  @h
end

end
                                                            
$options = ConfigTable.new
AUCTION_OPTIONS = []
def def_option(key, value)
  where_defined = caller.first
  $options[key] = [value,where_defined]  
  
  if AUCTION_OPTIONS.include?(key)
    puts "*********** WARNING: #{key} is now an auction option, should be in config/auctions/xxx0x0x.rb, not #{caller.first}"
  end
                                                                                                                    
end    

def opt(key)
   
  auction = Thread.current[:auction] 
  if auction
    res = auction.config[key] 
    return res if res
  end
  # not in the context of an auction, so we will take the option, no matter what

  $options[key]                                 
end


# two functions for dumping and loading current values of options listed in SERVER_OPTIONS (see auction_defaults.rb)
def server_options_to_yaml
  auction_opts_hash = {}
  SERVER_OPTIONS.each do |so|
    auction_opts_hash[so] = opt(so)
  end
  yaml_options = auction_opts_hash.to_yaml
  target_file = File.join(RAILS_ROOT,'config','server_options.yml')
  File.open(target_file, "w") do |f|
    f.write(yaml_options)
  end
end

def server_options_from_yaml
  target_file = File.join(RAILS_ROOT,'config','server_options.yml')
  return  unless File.exists?(target_file)  # just continue if no such file
  app_log.info("Previously saved SERVER options found, loading from #{target_file}")
  auction_opts_hash = File.open(target_file, "r") {|f| YAML::load(f)}
  auction_opts_hash.each_pair do |name, value|  # now set all the valid options
    next unless SERVER_OPTIONS.include?(name)
    def_option name, value
  end
  
end


