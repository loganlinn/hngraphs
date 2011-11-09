# $: << File.expand_path(File.dirname(__FILE__))
require 'rubygems'
require 'nokogiri'
require 'open-uri'

module HNGraphs
	class HackerNews

		class Story
			attr_accessor \
				:id,
				:rank,
				:title,
				:url,
				:points,
				:domain,
				:user,
				:comments

			def initialize(p)
				@id       = p[:id]
				@rank     = p[:rank]
				@title    = p[:title]
				@url      = p[:url]
				@points   = p[:points]
				@domain   = p[:domain]
				@user     = p[:user]
				@comments = p[:comments]
			end

			def to_s
				"#{@rank}. #{@title}, #{@points} points (#{@domain})"
			end
			def to_i
				@id.to_i
			end
		end

		BASE_URL = 'http://news.ycombinator.com'

		def initialize
			@stories = []
			@pages   = []
		end

		def fetch (n=0)
			@pages[n] ||= Nokogiri::HTML(open(BASE_URL))
		end

		def fetch! (n=0)
			@pages.delete(n)
			fetch!(n)
		end

		def scrape
			page = fetch
			table = page.css('table')[2]
			stories = []
			rows = table.css('tr')

			(0 .. rows.length).step(3).each do |i|
				r1 = rows[i]
				r2 = rows[i+1]

				break if r1.nil?          or r2.nil?             or
						 r1.children.nil? or r1.children[2].nil? or
						 r2.children.nil? or r2.children[1].nil?

				begin
					heading  = r1.children[2].children[0]
					subtext  = r2.children[1].children[0]

					user     = r2.children[1].children[2].content
					domain   = r1.children[2].children[1].content.gsub(/.*\((.*)\).*/, '\1')
					comments = r2.children[1].children[4].content.to_i
				rescue
					next # promoted items (YC listings) dont have authors. omit for now
				end

				story = {
					:id       => subtext['id'].gsub('score_', '').to_i,
					:rank     => (i/3)+1,
					:title    => heading.content,
					:url      => heading['href'],
					:points   => subtext.content.to_i,
					:domain   => domain,
					:user     => user,
					:comments => comments
				}
				@stories << Story.new(story)
			end
			@stories
		end

		def inspect
			if @stories.empty?
				"No Stories"
			else
				@stories.join("\n")
			end
		end
	end
end

