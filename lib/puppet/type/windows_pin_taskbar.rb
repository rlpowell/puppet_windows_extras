Puppet::Type.newtype(:windows_pin_taskbar) do
  desc "Pins items in Windows to the task bar"

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
