Puppet::Type.newtype(:windows_pin_startmenu) do
  desc "Pins items in Windows to the start menu"

  ensurable do
    newvalue(:present) { provider.create }
    newvalue(:absent) { provider.destroy }
    defaultto(:present)
  end

  autorequire(:file) do
	  self[:path]
  end

  newparam(:path) do
	  desc "The full path to the file"
	  isnamevar
  end
end
