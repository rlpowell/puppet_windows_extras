# Stolen from http://www.xenuser.org/open-source-development/using-environment-variables-in-puppet/

#Facter.loadfacts()
#if Facter['osfamily'].value == 'windows'
	ENV.each do |k,v|
                k = k.chomp.downcase.gsub(%r{[^a-zA-Z0-9_-]}, '')
                Facter.add("env_#{k}".to_sym) do
			setcode do
				v
			end
		end
	end
#end
