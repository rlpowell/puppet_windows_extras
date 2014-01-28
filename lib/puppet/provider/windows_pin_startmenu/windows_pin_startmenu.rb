# Depending on puppet version, this feature may or may not include the libraries needed, but
# if some of them are present, the others should be too. This check prevents errors from 
# non Windows nodes that have had this module pluginsynced to them. 
if Puppet.features.microsoft_windows?
  require 'win32ole'  
  require 'win32/dir' 
end

def fix_path(path)
	path.to_s.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR)
end
def get_file_obj
		    require 'pathname'
		    sh = WIN32OLE.new('Shell.Application')
		    pn = Pathname.new( @resource[:name] )
		    dir = pn.dirname
		    file = pn.basename
		    dirspace = sh.NameSpace(fix_path(dir))
		    fileobj = dirspace.ParseName(fix_path(file))
		    raise "Bad file #{fix_path(pn)} in windows_pin" unless fileobj
		    return fileobj
end

def do_verb(verb)
	fileobj = get_file_obj
	fileobj.Verbs.each { |x| y = x.name.gsub('&','').chomp ; (y == verb) and x.DoIt }
end

Puppet::Type.type(:windows_pin_startmenu).provide(:windows_pin_startmenu) do
	desc "Pin items to the start menu"

	confine :osfamily => :windows
	defaultfor :osfamily => :windows

	def create
		do_verb 'Pin to Start Menu'
	end

	def destroy
		do_verb 'Unpin from Start Menu'
	end

	def exists?
		fileobj = get_file_obj
		names = []
		fileobj.Verbs.each { |x| y = x.name.gsub('&','').chomp ; names << y }

		names.include? 'Pin to Start Menu' and return false
		names.include? 'Unpin from Start Menu' and return true
		raise "Can't determine #{@resource[:where]} pin status of #{@resource[:path]} in windows_pin_startmenu"
		raise "Bad value for where in windows_pin_startmenu"
	end
end
