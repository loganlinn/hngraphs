$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'hngraphs/hackernews'

if $0 == __FILE__
  hn = HNGraphs::HackerNews.new
  hn.scrape
  p hn
end
