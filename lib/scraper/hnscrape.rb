require 'rubygems'
require 'nokogiri'
require 'open-uri'

module HNScraper

    class Story
        attr_accessor :rank, :title, :url, :points, :domain

        @@instance_count = 0

        def initialize(p)
            @title  = p[:title]
            @url    = p[:url]
            @points = p[:points]
            @domain = p[:domain]

            @@instance_count += 1
            @rank = p[:rank] || @@instance_count
        end

        def to_s
            "#{@rank}. #{@title}, #{@points} points"
        end
    end

    class << self
        HN_URL = 'http://news.ycombinator.com'

        attr_accessor :stories
        attr_reader   :page

        def setup
            @stories = []
        end

        def fetch
            Nokogiri::HTML(open(HN_URL))
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

                heading = r1.children[2].children[0]
                subtext = r2.children[1].children[0]

                title  = heading.content
                url    = heading['href']
                rank   = i/3+1
                points = subtext.content.to_i

                @stories << Story.new(:rank => rank, :title => title, :url => url, :points => points)
            end
            @stories
        end

    end

    self.setup
end
