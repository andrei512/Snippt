NAME = 'snippt'
VERSION = '0.0.1'

require 'plist'

class Snippt 
	attr_accessor :triggers, :name, :snippt

	def initialize name = nil, triggers = [], snippt = ""
		@name = name
		@triggers = triggers
		@snippt = snippt
	end

	def tokenized_snippt
		h = {
			"<#" => :open,
			"#>" => :close
		}

		# tokenize
		tokens = snippt.split(/(\<#)|(#\>)/).inject([]) { |tokens, part|
			part = h[part] if h[part]
			tokens << part
		}


		# check if valid
		cnt = 0
		stack = []
		tokens.each do |token|
			case token
			when :close
				cnt -= 1
				if cnt < 0
					puts "noooo"
				else
					puts "tag = #{stack.join}"
					stack = []
				end
			when :open
				cnt += 1
				if cnt > 1
					puts "noooo"
				end				
			else
				if cnt == 1
					stack << token	
				end
			end
		end
	end

	def as_hash
		{
			triggers: triggers,
			name: name,
			snippt: tokenized_snippt
		}
	end

	def make_plist
		puts "#{as_hash.to_plist}"
	end
end

def snippt snippt_name
	s = Snippt.new(snippt_name)
	yield s

	# make snippt pretty
	s.snippt = s.snippt.mtlp

	# create snippt_plist
	s.make_plist
end

class String
	def mtlp
		min_space = nil
		re = /^\s+/
		lines.each do |line|
			match = line.match(re)
			if min_space == nil or match.length < min_space.length 
				min_space = match
			end
		end
		lines.map { |line|
			line.gsub(/^#{min_space}/, "")
		}.join
	end
end

class String 
  def all_matches pattern, &callback
	  all_matches = []

	  string = self

	  while string != nil and string.length > 0                        
	    match_data = string.match(pattern)
	    if match_data.captures.count == 0
	            break
	    end

	    if match_data.pre_match.length > 0
        all_matches << {
          untagged: match_data.pre_match
        }
	    end

	    match_data.names.zip(match_data.captures).each do |k,v| 
        if v 
          all_matches << {
	          name: k.to_sym,
	          value: v
          }
        end
	    end
	    string = match_data.post_match                        
	  end        

	  all_matches
  end
end

def load_snippt snippt_file
	puts "loading #{snippt_file}"
	begin
		load snippt_file
	rescue Exception => e
		puts "Exception: #{e.inspect}"
	end
end

if ARGV.count > 0
	ARGV.each do |snippt_file|
		load_snippt snippt_file
	end
else
	help = <<-EOF
		#{NAME} #{VERSION} help:
		snippt
	EOF
	help = help.mtlp
	puts help
end
