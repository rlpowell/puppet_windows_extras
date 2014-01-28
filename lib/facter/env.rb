# Stolen from http://www.xenuser.org/open-source-development/using-environment-variables-in-puppet/

#Facter.loadfacts()
#if Facter['osfamily'].value == 'windows'
	ENV.each do |k,v|
		Facter.add("env_#{k.downcase}".to_sym) do
			setcode do
				v
			end
		end
	end
#end
