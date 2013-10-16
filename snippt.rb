NAME = 'snippt'
VERSION = '0.0.1'

@@snippts_path = "#{File.expand_path("~")}/Library/Developer/Xcode/UserData/CodeSnippets/"

require 'plist'

class Snippt 
	attr_accessor :triggers, :name, :snippt, :filename

	def initialize name = nil, triggers = [], snippt = ""
		@name = name
		@triggers = triggers
		@snippt = snippt
		@filename = String.random_title
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
	end

	def as_hash
		{
			"IDECodeSnippetCompletionPrefix" => name,
			"IDECodeSnippetCompletionScopes" => [
				# "ClassImplementation",
				# "CodeExpression",
				# "Preprocessor",
				# "ClassInterfaceVariables",
				"All",
				# "TopLevel",
				# "ClassInterfaceMethods",
				# "CodeBlock",
				# "StringOrComment",
			],
			"IDECodeSnippetContents" => snippt,
			"IDECodeSnippetIdentifier" => filename,
			"IDECodeSnippetLanguage" => "Xcode.SourceCodeLanguage.Objective-C",
			"IDECodeSnippetSummary" => "seeds random number generation",
			"IDECodeSnippetTitle" => name,
			"IDECodeSnippetUserSnippet" => true,
			"IDECodeSnippetVersion" => 2
		}
	end

	def make_plist
		plist = as_hash.to_plist
		filepath = @@snippts_path + filename + ".codesnippet"
		File.open(filepath, 'w') { |file| 
			file.write(plist) 
		}
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

	def self.random_hex k
		code = Array('A'..'Z') + Array('0'..'9')
		h = ""
		k.times do 
			h = h + code[rand(code.length)]
		end
		h
	end

	def self.random_title
		"#{random_hex 8}-#{random_hex 4}-#{random_hex 4}-#{random_hex 4}-#{random_hex 12}"
	end

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
	begin
		load snippt_file
	rescue Exception => e
		puts "Exception: #{e}"
		puts "Exception: #{e.backtrace}"
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
