require 'mechanize'

def is_relative_link? link
	link[0] == '/' 
end

def format_relative_link link, domain
	link = domain + link
	link
end

def remove_paramters link
	link = link.split('?')[0] if link.include? "?"
	link
end

def remove_protocol link
	link = link.split('//')[1] if link.include? "//"
	link
end

def remove_www link
	link = link.split('ww.')[1] if link.include? "www"
	link
end

def format_link link, domain, param_flag
	link = format_relative_link link, domain if is_relative_link? link
	#link = remove_protocol link
	link = remove_www link
	link = remove_paramters link if param_flag.to_i == 1
	link
end

def get_domain site
	site = remove_protocol site
	site = remove_paramters site
	site = site.split('/')[0]
	site
end

def get_root_domain site
	site = get_domain site
	site = site.split('.')
	site = site[-2] + "." + site[-1]
	site
end

def get_second_level link
	link = link.split('/')
	link = link[0] + '/' + (link[1] ? link[1] : '')
end

def is_valid_link? link
	link.href.to_s.include? '//'
end

# Command Arguments
site = ARGV[0]
remove_parameters_flag = ARGV[1]

# Link collections
internal_links = []
external_links = []
internal_domains = []
external_domains = []
second_level_links = []

# Page scrape
mech = Mechanize.new
page = mech.get(site)
domain = get_domain site
root_domain = get_root_domain site

# Format and categorize page links
page.links.each do |link|	
	if is_valid_link? link
		link = format_link link.href.to_s, domain, remove_parameters_flag 

		# Compile link collections
		if link.include? root_domain
			internal_links << link
			
			if link.include? '/'
				lev_link = get_second_level link 
				second_level_links << lev_link
			end

			link = get_domain link
			internal_domains << link
		else
			external_links << link
			link = get_domain link
			external_domains << link
		end
	end
end

# Only Unique Results
#internal_links.uniq!
#external_links.uniq!
#internal_domains.uniq!
#external_domains.uniq!
#second_level_links.uniq!

external_links.each { |link| puts link } 