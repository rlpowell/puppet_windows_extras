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

def get_file_obj( name )
  require 'pathname'
  sh = WIN32OLE.new('Shell.Application')
  pn = Pathname.new( name )
  dir = pn.dirname
  file = pn.basename
  dirspace = sh.NameSpace(fix_path(dir))
  fileobj = dirspace.ParseName(fix_path(file))
  raise "Bad file #{fix_path(pn)} in windows_pin" unless fileobj
  return fileobj
end

def do_verb(name, verb)
  fileobj = get_file_obj( name )
  fileobj.Verbs.each do |x|
    y = x.name.gsub('&','').chomp
    # info("y: #{y}")
    if y =~ verb or y == verb
      # info("match found")
      return x.DoIt
    end

    # If we're still here, no match was found
    raise "Could not find verb \"#{verb}\" on item #{name}"
  end
end

$syspin=%q{C:\Windows\System32\syspin.exe}

Puppet::Type.newtype(:windows_pin) do
  desc "Pins items in Windows to the task bar or start menu"

  autorequire(:file) do
    [ self[:path], $syspin ]
  end

  newparam(:path) do
    desc "The full path to the file"
    isnamevar
  end

  newparam(:type) do
    desc "Taskbar (anything with \"task\" in it) or start menu (anything with \"start\")"
  end

  newproperty(:ensure) do
    desc "Whether to make or remove the pin."

    defaultto :present

    def retrieve
      typere="[tT]askbar"
      if resource[:type] =~ %r{start}i
        typere="[sS]tart"
      end

      fileobj = get_file_obj( resource[:name] )
      names = []
      fileobj.Verbs.each { |x| y = x.name.gsub('&','').chomp ; names << y }

      # info("verb names: #{names.join("\n")}")

      if Facter.value(:operatingsystemmajrelease).to_i == 10
        if names.grep( %r{^\s*Unpin (from)? #{typere}\s*$} ).length > 0
          # info("pinned")
          return :present
        else
          return :absent
        end
      else
        if names.grep( %r{^\s*Pin to #{typere}\s*$} ).length > 0
          # info("unpinned")
          return :absent
        end
        if names.grep( %r{^\s*Unpin (from)? #{typere}\s*$} ).length > 0
          # info("pinned")
          return :present
        end
        raise "Can't determine taskbar pin status of #{resource[:path]} in windows_pin_taskbar"
      end
    end

    newvalue :present do
      typere="[tT]askbar"
      cmdval="c:5386"
      if resource[:type] =~ %r{start}i
        typere="[sS]tart"
        cmdval="c:51201"
      end

      # info("pinning")
      if Facter.value(:operatingsystemmajrelease).to_i == 10
        cmd = "#{$syspin} \"#{fix_path resource[:name]}\" #{cmdval}"
        notice("cmd: #{cmd}")
        notice("output: " + %x{#{cmd}})
      else
        do_verb( resource[:name], %r{Pin to #{typere}} )
      end
    end

    newvalue :absent do
      typere="[tT]askbar"
      cmdval="c:5387"
      if resource[:type] =~ %r{start}i
        typere="[sS]tart"
        cmdval="c:51394"
      end

      # info("unpinning")
      if Facter.value(:operatingsystemmajrelease).to_i == 10
        cmd = "#{$syspin} \"#{fix_path resource[:name]}\" #{cmdval}"
        notice("cmd: #{cmd}")
        notice("output: " + %x{#{cmd}})
      else
        do_verb( resource[:name], %r{Unpin (from)? #{typere}} )
      end
    end
  end
end
