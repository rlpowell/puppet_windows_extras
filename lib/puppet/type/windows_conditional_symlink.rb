Puppet::Type.newtype(:windows_conditional_symlink) do
  desc "Makes a symlink from the name to the target if the directory named by onlyifexists exists.  It also moves the previous file named by name, if any, out of the way (it appends -OLD to the file name)."

  autorequire(:file) do
	  self[:name]
  end

  newparam(:name) do
	  desc "The symlink file to make."
  end

  newparam(:target) do
	  desc "The file the symlink points to."
  end

  newparam(:onlyifexists) do
	  desc "The directory to check."
  end

   newproperty(:ensure) do
      desc "Please do not use the ensure property yourself."

      defaultto :condition_not_found_or_symlink_exists

      def retrieve
        unless @resource[:name] && @resource[:target] && @resource[:onlyifexists]
          raise "windows_conditional_symlink requires all of name, target, and onlyifexists"
        end

        if ! File.exists?( @resource[:onlyifexists] )
          return :condition_not_found_or_symlink_exists
        else
          # info "\n#{Puppet::FileSystem.readlink( @resource[:name] )}\n#{@resource[:target]}\n#{Puppet::FileSystem.readlink( @resource[:name] ) == @resource[:target]}\n"
          if File.exists?( @resource[:name] ) && Puppet::FileSystem.symlink?( @resource[:name] ) && Puppet::FileSystem.readlink( @resource[:name] ) == @resource[:target]
            return :condition_not_found_or_symlink_exists
          else
            return :symlink_needed
          end
        end
      end

      newvalue :condition_not_found_or_symlink_exists do
        unless @resource[:name] && @resource[:target] && @resource[:onlyifexists]
          raise "windows_conditional_symlink requires all of name, target, and onlyifexists"
        end

        if File.exists?( @resource[:name] ) && ! File.symlink?( @resource[:name] )
          File.rename( @resource[:name], "#{@resource[:name]}-OLD" )
          warn "windows_conditional_symlink found a bad file; renamed #{@resource[:name]} to #{@resource[:name]}-OLD"
        end

        # raise "got the values: #{@resource[:name]} && #{@resource[:target]} && #{@resource[:onlyifexists]}"

        Puppet::FileSystem.symlink(@resource[:target], @resource[:name])
        return :condition_not_found_or_symlink_exists
      end

   end
end
